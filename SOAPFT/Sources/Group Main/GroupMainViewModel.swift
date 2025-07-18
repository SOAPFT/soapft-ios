import Foundation
import SwiftUI

final class GroupMainViewModel: ObservableObject {
    private let challengeService = ChallengeService()
    private let notificationsService = NotificationService()
    
    @Published var hot: [Challenge] = []
    @Published var recent: [Challenge] = []
    @Published var event: [Challenge] = []
    
    @Published var notificationCount: Int = 0
    
    enum ChallengeViewType {
        case hot
        case recent
        case event
        
        var title: String {
            switch self {
            case .hot:
                return "지금 인기있는 챌린지 🔥"
            case .recent:
                return "최근 개설된 챌린지 🌱"
            case .event:
                return "이벤트 챌린지 🎉"
            }
        }
    }
    
    // MARK: - 알림 개수
    func fetchNotificationCount() {
        guard let accessToken = KeyChainManager.shared.read(forKey: "accessToken") else {
            print("❌ accessToken 없음")
            return
        }
        
        notificationsService.fetchUnreadCount(accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let noti):
                    self?.notificationCount = noti.unreadCount
                    print("✅ 알림 개수 fetch 성공: \(noti)")
                case .failure(let error):
                    print("❌ 알림 개수 fetch 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getChallenges(for type: ChallengeViewType) -> [Challenge] {
        switch type {
        case .hot:
            return hot
        case .recent:
            return recent
        case .event:
            return event
        }
    }

    // MARK: - 인기 챌린지
    func fetchHotChallenges() {
        challengeService.getPopularChallenges { [weak self] (result: Result<[Challenge], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let challenges):
                    print("✅ 인기 챌린지 API 호출 성공 - 챌린지 개수: \(challenges.count)")
                    challenges.forEach { print("🔥 인기 챌린지 타이틀: \($0.title)") }
                    self?.hot = challenges
                case .failure(let error):
                    print("🔥 인기 챌린지 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - 최근 챌린지
    func fetchRecentChallenges() {
        challengeService.getRecentChallenges { [weak self] (result: Result<[Challenge], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let challenges):
                    print("✅ 최근 챌린지 API 호출 성공 - 챌린지 개수: \(challenges.count)")
                    challenges.forEach { print("🌱 최근 챌린지 타이틀: \($0.title)") }
                    self?.recent = challenges
                case .failure(let error):
                    print("🌱 최근 챌린지 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - 이벤트 챌린지 (status = EVENT)
    func fetchEventChallenges() {
        print("🚀 이벤트 챌린지 API 호출 시작 - 파라미터: page=1, limit=10, type=EVENT, gender=NONE, status=before")
        
        challengeService.fetchChallenges(page: 1, limit: 10, type: "EVENT", gender: "NONE", status: "before") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let challenges):
                    print("✅ 이벤트 챌린지 API 호출 성공 - 챌린지 개수: \(challenges.count)")
                    self?.event = challenges
                case .failure(let error):
                    print("🎯 이벤트 챌린지 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}
