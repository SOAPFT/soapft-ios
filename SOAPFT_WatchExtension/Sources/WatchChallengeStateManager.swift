//
//  WatchChallengeStateManager.swift
//  SOAPFT
//
//  Created by 바견규 on 8/7/25.
//

import Foundation
import SwiftUI
import Combine

final class WatchChallengeStateManager: ObservableObject {
    @Published var session: ChallengeSession?
    @Published var currentScore: Int = 0
    @Published var currentRank: Int = 0
    @Published var rankEffectTriggered: Bool = false
    @Published var isCompleted: Bool = false  // 추가: 인증 완료 상태

    private var previousRank: Int = Int.max

    /// 세션 설정 (처음 데이터 수신 시)
    func setSession(_ session: ChallengeSession) {
        self.session = session
        self.currentScore = 0
        self.currentRank = session.top3.count + session.others.count + 1 // 꼴등부터 시작
        self.previousRank = self.currentRank
        self.isCompleted = false  // 새 세션 시작 시 완료 상태 초기화
    }

    /// 실시간 측정값 업데이트 (거리, 걸음수 등)
    func updateScore(to newScore: Int) {
        guard let session = session else { return }
        self.currentScore = newScore

        let newRank = calculateCurrentRank(from: newScore, using: session)
        if newRank < currentRank {
            triggerRankEffect()
        }

        self.previousRank = self.currentRank
        self.currentRank = newRank
    }

    /// 인증 완료 상태로 변경
    func markAsCompleted() {
        self.isCompleted = true
    }

    /// 초기 상태로 리셋 (미션 대기 상태)
    func resetToInitialState() {
        self.session = nil
        self.currentScore = 0
        self.currentRank = 0
        self.rankEffectTriggered = false
        self.isCompleted = false
        self.previousRank = Int.max
    }

    /// 현재 측정 점수 기준 순위 계산
    private func calculateCurrentRank(from score: Int, using session: ChallengeSession) -> Int {
        let allUsers = session.top3 + session.others
        let sorted = allUsers.sorted {
            (Int($0.score)) > (Int($1.score))
        }

        for (index, user) in sorted.enumerated() {
            if score >= (Int(user.score)) {
                return index + 1
            }
        }

        return sorted.count + 1
    }

    /// 순위 상승 이펙트 표시
    private func triggerRankEffect() {
        rankEffectTriggered = true

        // 이펙트 잠깐 표시 후 해제
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.rankEffectTriggered = false
        }
    }
}
