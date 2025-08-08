//
//  EventRankingViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 8/5/25.
//

import Foundation
import SwiftUI
import Combine

final class ChallengeRankingViewModel: ObservableObject {
    @Published var top3: [RankUser] = []
    @Published var others: [RankUser] = []
    @Published var myRank: RankUser?
    @Published var isLoading = true
    @Published var period: String = ""
    @Published var reward: Int = 0
    @Published var isLongTerm: Bool = false
    @Published var missionType: MissionType = .distance
    @Published var durationSeconds: Int = 0
    
    // 참여 상태 관리
    @Published var isParticipating: Bool = false
    @Published var hasResult: Bool = false
    
    // 토스트 메시지
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""

    private let eventService: EventService
    let missionId: Int

    init(eventService: EventService, missionId: Int) {
        self.eventService = eventService
        self.missionId = missionId
        fetchRanking()
        
        // 워치 인증 완료 알림 감지
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWatchChallengeCompleted(_:)),
            name: .watchChallengeCompleted,
            object: nil
        )
    }

    func fetchRanking() {
        isLoading = true
        eventService.getEventDetail(id: missionId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let response):
                    let users = response.rankings.enumerated().map { (index, entry) -> RankUser in
                        var user = RankUser(entry: entry)
                        user.rank = index + 1
                        return user
                    }

                    self.top3 = Array(users.prefix(3))
                    self.others = Array(users.dropFirst(3))

                    // 내 랭킹
                    if let name = response.myName {
                        self.myRank = RankUser(
                            rank: response.myRank ?? 0,
                            name: name,
                            image: response.myProfileImage ?? "",
                            score: response.myResult ?? 0
                        )
                    }

                    let mission = response.mission
                    self.reward = mission.reward
                    self.isLongTerm = mission.isLongTerm ?? false
                    self.missionType = mission.type
                    self.durationSeconds = mission.durationSeconds ?? 0
                    
                    // 참여 상태
                    self.isParticipating = response.isParticipating
                    self.hasResult = (response.myResult ?? 0) > 0

                    // 기간
                    let start = self.formatDateString(response.mission.startTime)
                    let end = self.formatDateString(response.mission.endTime)
                    self.period = "\(start) ~ \(end)"

                case .failure(let error):
                    print("❌ 랭킹 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    // 미션 참여
    func joinMission() {
        eventService.participateEvent(id: missionId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isParticipating = true
                    self?.toastMessage = "미션에 참여했습니다!"
                    self?.showToast = true
                    self?.fetchRanking()
                case .failure(let error):
                    self?.toastMessage = "참여 실패: \(error.localizedDescription)"
                    self?.showToast = true
                }
            }
        }
    }

    private func formatDateString(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "ko_KR")
        displayFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // KST 고정
        displayFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        
        if let date = formatter.date(from: dateString) {
            return displayFormatter.string(from: date) + " (KST)" // 약어 수동 추가
        }
        
        return dateString
    }

    // 인증하기
    func handleCertifyAction() {
        if isLongTerm {
            HealthKitManager.shared.fetchHealthData(
                missionType: missionType,
                durationSeconds: durationSeconds
            ) { result in
                self.certifyMission(resultData: result)
            }
        } else {
            self.sendMissionToWatch()

            // 워치 인증 유도 토스트 메시지 표시
            DispatchQueue.main.async {
                self.toastMessage = "애플워치에서 인증을 진행해주세요."
                self.showToast = true
            }
        }
    }
    
    // 인증하기 API
    func certifyMission(resultData: Int) {
        // 실제 인증 API 연동 시 resultData 포함 필요
        eventService.submitMissionResult(id: "\(missionId)", resultData: resultData) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.hasResult = true
                    self?.toastMessage = "인증이 완료되었습니다."
                    self?.showToast = true
                    self?.fetchRanking()
                case .failure(let error):
                    self?.toastMessage = "인증 실패: \(error.localizedDescription)"
                    self?.showToast = true
                }
            }
        }
    }
    
    
    //애플 워치 인증 감지
    @objc private func handleWatchChallengeCompleted(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let eventId = userInfo["eventId"] as? Int,
              let resultData = userInfo["resultData"] as? Int else {
            return
        }

        // 현재 보고 있는 미션과 동일한 경우에만 처리
        guard eventId == self.missionId else {
            print("ℹ️ 다른 이벤트의 인증 완료 알림 무시")
            return
        }

        print("📲 워치 인증 완료 처리: eventId=\(eventId), result=\(resultData)")
        
        DispatchQueue.main.async {
            self.toastMessage = "워치 인증이 완료되었습니다."
            self.showToast = true
        }

        certifyMission(resultData: resultData)
    }
}
