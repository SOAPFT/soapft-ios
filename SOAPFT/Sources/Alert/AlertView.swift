import SwiftUI
import UIKit

struct AlertView: View {
    @Environment(\.dismiss) var dismiss
    @State var showingSheet = false
    @StateObject var viewModel = AlertsViewModel()
    
    var body: some View {
        VStack {
            AlertHeader
            
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
                .onAppear { //미리보기용
                    viewModel.loadSampleDataIfNeeded()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private var AlertHeader: some View {
        HStack {
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "chevron.backward")
                    .foregroundColor(Color.black)
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
                    .foregroundColor(Color.black)
                    .frame(width: 24, height: 24)
            })
            .confirmationDialog(
                "최근 알림을 전부 삭제하시겠습니까?",
                isPresented: $showingSheet,
                titleVisibility: .visible
            ) {
                Button("모든 알림 삭제", role: .destructive) {
                    viewModel.alerts.removeAll()
                }
                Button("취소", role: .cancel) {}
            }
        }
        .padding(.horizontal, 10)
    }
    
    private func AlertCard() -> some View {
        ForEach(viewModel.alerts, id: \.id) { alert in
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(alert.alarm.byCharWrapping)
                        .font(Font.Pretend.pretendardRegular(size: 14))
                        .foregroundStyle(alert.isRead ? .gray: .black)
                    
                    Text(alert.time)
                        .font(Font.Pretend.pretendardRegular(size: 12))
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    if let index = viewModel.alerts.firstIndex(where: { $0.id == alert.id }) {
                        viewModel.alerts.remove(at: index)
                    }
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

