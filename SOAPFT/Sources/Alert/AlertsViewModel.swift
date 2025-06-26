import Foundation

class AlertsViewModel: ObservableObject {
    @Published var alerts: [AlertsModel] = []
    
    func loadSampleDataIfNeeded() {
        if alerts.isEmpty {
            alerts = [
                AlertsModel(alarm: "홍길동님이 회원님의 게시글에 댓글을 달았습니다.", time: "방금전", isRead: false),
                AlertsModel(alarm: "홍길동님이 회원님의 게시글에 댓글을 달았습니다.", time: "1시간 전", isRead: true),
                AlertsModel(alarm: "홍길동님이 회원님의 게시글에 댓글을 달았습니다.", time: "1주일 전", isRead: false)
            ]
        }
    }
}
