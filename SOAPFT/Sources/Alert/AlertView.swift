import SwiftUI
import UIKit

struct AlertView: View {
    @Environment(\.diContainer) private var container
//    @Environment(\.dismiss) var dismiss
    @State var showingSheet = false
    @StateObject var viewModel = AlertsViewModel()
    
    // 네비게이션 대상 알림
    @State private var selectedAlert: NotificationDTO? = nil
    
    var body: some View {
        VStack {
            AlertHeader
            Divider()
            ZStack {
                List {
                    if viewModel.alerts.isEmpty {
                        Text("최근 알림이 없습니다")
                            .foregroundStyle(Color.gray)
                            .font(Font.Pretend.pretendardRegular(size: 15))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 32)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } else {
                        AlertCard()
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .onAppear {
//                    viewModel.loadSampleDataIfNeeded() //미리보기용
                    viewModel.fetchAlerts()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private var AlertHeader: some View {
        HStack {
            Button(action: {
                container.router.pop()
            }, label: {
                Image(systemName: "chevron.backward")
                    .foregroundStyle(Color.black)
                    .frame(width: 24, height: 24)
            })
            
            Spacer()
            
            Text("알림 내역")
                .font(Font.Pretend.pretendardSemiBold(size: 16))
            
            Spacer()
            
            Button(action: {
                self.showingSheet = true
            }, label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(Color.black)
                    .rotationEffect(.degrees(90))
                    .frame(width: 24, height: 24)
            })
            .confirmationDialog(
                "최근 알림을 전부 삭제하시겠습니까?",
                isPresented: $showingSheet,
                titleVisibility: .visible
            ) {
                Button("모든 알림 읽음 처리", role: .destructive) {
                    viewModel.markAllAsRead()
                }
                Button("취소", role: .cancel) {}
            }
        }
        .padding()
    }
    
    private func AlertCard() -> some View {
        ForEach(viewModel.alerts, id: \.id) { alert in
            Button(action: {
                handleTap(alert)
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(alert.content.byCharWrapping)
                            .font(Font.Pretend.pretendardRegular(size: 14))
                            .foregroundStyle(alert.isRead ? .gray: .black)
                        Text(alert.createdAt)
                            .font(Font.Pretend.pretendardRegular(size: 12))
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 6)
            }
            .frame(maxWidth: .infinity)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    viewModel.deleteAlert(alert: alert)
                } label: {
                    Label("삭제", systemImage: "trash")
                }
            }
        }
    }
    
    private func handleTap(_ alert: NotificationDTO) {
        // 1) 읽음 처리
        viewModel.markAsRead(alert: alert)
        
        // 2) 타입별 라우팅
        switch alert.type {
        case "friend_request":
            container.router.push(.friendsRequest)
            
        case "friend_accepted":
            container.router.push(.friend)
            
        case "challenge_invite":
            if let challengeUuid = alert.data?.string("challengeUuid") {
                container.router.push(.challengeSignUpWrapper(ChallengeID: challengeUuid))
            } else {
                container.selectedTab = "챌린지"
                container.router.push(.mainTabbar)
            }
            
        case "challenge_start", "challenge_end", "challenge_reminder", "mission_created", "mission_reminder":
            if let challengeUuid = alert.data?.string("challengeUuid") {
                container.router.push(.GroupTabbar(ChallengeID: challengeUuid))
            } else {
                container.selectedTab = "홈"
                container.router.push(.mainTabbar)
            }
            
        case "new_message":
            let currentUserUuid = alert.recipientUuid
            let chatRoomUuid    = alert.data?.string("chatRoomUuid")
            let chatRoomName    = alert.data?.string("senderNickname")

            if let roomId = chatRoomUuid, let name = chatRoomName {
                container.router.push(
                    .ChatRoomWrapper(
                        currentUserUuid: currentUserUuid,
                        roomId: roomId,
                        chatRoomName: name
                    )
                )
            } else {
                container.selectedTab = "채팅"
                container.router.push(.mainTabbar)
            }
            
        case "post_like", "post_comment", "mention":
            if let postUuid = alert.data?.string("postUuid") {
                container.router.push(.postDetail(postUuid: postUuid))
            } else {
                container.selectedTab = "마이"
                container.router.push(.mainTabbar)
            }
            
        default:
            container.router.push(.alert)
        }
    }
}

extension String {
    var byCharWrapping: Self {
        map(String.init).joined(separator: "\u{200B}")
    }
}

private extension Dictionary where Key == String, Value == JSONValue {
    func string(_ key: String) -> String? {
        guard let v = self[key] else { return nil }
        switch v {
        case .string(let s): return s
        case .int(let i): return String(i)
        case .double(let d): return String(d)
        case .bool(let b):   return b ? "true" : "false"
        default: return nil
        }
    }
    
    func int(_ key: String) -> Int? {
        guard let v = self[key] else { return nil }
        switch v {
        case .int(let i): return i
        case .string(let s): return Int(s)
        case .double(let d): return Int(d)
        default: return nil
        }
    }
}

#Preview {
    AlertView()
}

