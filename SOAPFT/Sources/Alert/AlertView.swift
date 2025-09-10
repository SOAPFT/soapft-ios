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
                // 1. 읽음 처리
                viewModel.markAsRead(alert: alert)
                // 2. 네비게이션용 상태 변경
                selectedAlert = alert
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
}

extension String {
    var byCharWrapping: Self {
        map(String.init).joined(separator: "\u{200B}")
    }
}

#Preview {
    AlertView()
}

