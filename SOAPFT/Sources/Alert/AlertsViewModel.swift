import Foundation
import Combine

class AlertsViewModel: ObservableObject {
    @Published var alerts: [NotificationDTO] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    private var currentPage = 1
    private let pageLimit = 20
    
    func fetchAlerts(unreadOnly: Bool = true) {
        guard let accessToken = KeyChainManager.shared.read(forKey: "accessToken") else {
            print("❌ accessToken 없음")
            return
        }
        
        NotificationService.shared.fetchNotifications(
            page: currentPage,
            limit: pageLimit,
            unreadOnly: unreadOnly,
            accessToken: accessToken
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.alerts = response.notifications
                    print("✅ 알림 목록 조회 성공: \(response.notifications.count)건")
                case .failure(let error):
                    print("알림 조회 실패:", error)
                }
            }
        }
    }
    
    // MARK: - 특정 알림 읽음 처리
    func markAsRead(alert: NotificationDTO) {
        guard let accessToken = KeyChainManager.shared.read(forKey: "accessToken") else {
            print("❌ accessToken 없음")
            return
        }
        
        guard !alert.isRead else { return }
        NotificationService.shared.markAsRead(
            notificationIds: [alert.id],
            accessToken: accessToken
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("✅ 알림 읽음 처리 성공 (id: \(alert.id))")
                    self?.fetchAlerts()
                case .failure(let error):
                    print("읽음 처리 실패:", error)
                }
            }
        }
    }
    
    // MARK: - 전체 알림 읽음 처리
    func markAllAsRead() {
        guard let accessToken = KeyChainManager.shared.read(forKey: "accessToken") else {
            print("❌ accessToken 없음")
            return
        }
        
        let unreadIds = alerts.filter { !$0.isRead }.map { $0.id }
        guard !unreadIds.isEmpty else { return }
        
        NotificationService.shared.markAllAsRead(
            notificationIds: unreadIds,
            accessToken: accessToken
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("✅ 전체 알림 읽음 처리 성공 (\(unreadIds.count)건)")
                    self?.fetchAlerts()
                case .failure(let error):
                    print("전체 읽음 처리 실패:", error)
                }
            }
        }
    }
    
    // MARK: - 알림 삭제
    func deleteAlert(alert: NotificationDTO) {
        guard let accessToken = KeyChainManager.shared.read(forKey: "accessToken") else {
            print("❌ accessToken 없음")
            return
        }
        
        NotificationService.shared.deleteNotification(
            id: alert.id,
            accessToken: accessToken
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        self?.alerts.removeAll(where: { $0.id == alert.id })
                        print("🗑️ 알림 삭제 성공 (id: \(alert.id))")
                    } else {
                        print("⚠️ 알림 삭제 실패 (서버 응답 실패)")
                    }
                case .failure(let error):
                    print("삭제 실패:", error)
                }
            }
        }
    }
    
//    // MARK: - 미리보기용 샘플 데이터 로드
//        func loadSampleDataIfNeeded() {
//            if alerts.isEmpty {
//                // 실제 구현 시 서버에서 불러오도록 변경하세요
//                alerts = [
//                    NotificationDTO(id: 1, recipientUuid: "r1", senderUuid: "s1", type: "info", title: "[JIWOO] 새로운 알림", content: "홍길동님이 회원님의 게시글에 댓글을 남겼습니다.", data: NotificationData(friendRequestId: 101), isRead: false, isSent: true, createdAt: "2025-07-11T12:00:00", updatedAt: "2025-07-11T12:00:00"),
//                    NotificationDTO(id: 2, recipientUuid: "r1", senderUuid: "s2", type: "info", title: "[JIWOO] 새로운 알림", content: "오운완 그룹에 가입되었습니다.", data: NotificationData(friendRequestId: 102), isRead: true, isSent: true, createdAt: "2025-07-10T11:00:00", updatedAt: "2025-07-10T11:00:00"),
//                ]
//            }
//        }
}
