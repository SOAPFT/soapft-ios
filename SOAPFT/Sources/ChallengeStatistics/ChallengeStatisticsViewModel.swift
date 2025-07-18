//
//  ChallengeStatisticsViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 7/3/25.
//

// ChallengeStatisticsViewModel.swift

import Foundation
import SwiftUI

final class ChallengeStatisticsViewModel: ObservableObject {
    // 챌린지 API 서비스
    private let challengeService: ChallengeService

    // 챌린지
    @Published var challenge: ChallengeDetailResponse
    @Published var monthlyVerification: [String: DailyVerification] = [:]
    @Published var data: ChallengeStatisticsData
    @Published var year: Int
    @Published var month: Int
    @Published var progress: Int = 0

    init(challengeService: ChallengeService, challenge: ChallengeDetailResponse) {
        self.challengeService = challengeService
        self.challenge = challenge

        // 날짜 포맷터
        let isoFormatter = ISO8601DateFormatter()
        var certifiedCount: [Date: Int] = [:]
        var certifiedMembers: [Date: [Member]] = [:]

        // 챌린지 상태에 따라 기준 연도와 월 결정
        let calendar = Calendar.current
        let currentDate = Date()


        if challenge.isFinished, let end = isoFormatter.date(from: challenge.endDate) {
            year = calendar.component(.year, from: end)
            month = calendar.component(.month, from: end)
        } else if challenge.isStarted {
            year = calendar.component(.year, from: currentDate)
            month = calendar.component(.month, from: currentDate)
        } else if let start = isoFormatter.date(from: challenge.startDate) {
            year = calendar.component(.year, from: start)
            month = calendar.component(.month, from: start)
        } else {
            year = calendar.component(.year, from: currentDate)
            month = calendar.component(.month, from: currentDate)
        }
        
        
        // 초기값 (로딩 전)
        self.data = ChallengeStatisticsData(
            goalCompletionRate: 0,
            challengeStartDate: challenge.startDate,
            challengeEndDate: challenge.endDate,
            currentMember: challenge.currentMembers,
            goal: challenge.goal,
            certifiedCount: [:],
            certifiedMembers: [:]
        )
        
        //사용자 챌린지 진행률 조회
        self.challengeService.getProgress(id: challenge.challengeUuid) { [weak self] (result: Result<ChallengeProgressResponse, Error>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let ChallengeProgress):
                    self.progress = ChallengeProgress.totalAchievementRate
                case .failure(let error):
                    print("챌린지 진행률 불러오기 실패: \(error)")
                }
            }
        }

        // 월별 인증 현황 요청
        challengeService.getMonthlyVerifications(id: challenge.challengeUuid, year: year, month: month) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let verification):
                    self.monthlyVerification = verification
                    print(verification)

                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.dateFormat = "yyyy-MM-dd"

                    for (dateString, daily) in verification {
                        if let date = formatter.date(from: dateString) {
                            let normalizedDate = Calendar.current.startOfDay(for: date)
                            certifiedCount[normalizedDate] = daily.count
                            certifiedMembers[normalizedDate] = daily.users.map {
                                Member(id: $0.userUuid, name: $0.nickname, profileImage: $0.profileImage ?? "")
                            }
                        } else {
                            print("날짜 파싱 실패: \(dateString)")
                        }
                    }
                    
                    self.data = ChallengeStatisticsData(
                        goalCompletionRate: self.progress,
                        challengeStartDate: challenge.startDate,
                        challengeEndDate: challenge.endDate,
                        currentMember: challenge.currentMembers,
                        goal: challenge.goal,
                        certifiedCount: certifiedCount,
                        certifiedMembers: certifiedMembers
                    )
                    
                    print(self.data)

                case .failure(let error):
                    print("월별 인증 현황 로드 실패: \(error)")
                    self.data = ChallengeStatisticsData(
                        goalCompletionRate: 0,
                        challengeStartDate: challenge.startDate,
                        challengeEndDate: challenge.endDate,
                        currentMember: challenge.currentMembers,
                        goal: challenge.goal,
                        certifiedCount: [:],
                        certifiedMembers: [:]
                    )
                }
            }
        }


    }
}


extension Date {
    var dateOnly: Date {
        Calendar.current.startOfDay(for: self)
    }
}
