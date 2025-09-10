//
//  ChatRoomNavBar.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI

struct ChatRoomNavBar: View {
    let showToast: (String, Bool) -> Void // 토스트 표시 콜백
    let chatRoomName: String
    let chatRoomId: String
    @Environment(\.diContainer) private var container
    @State private var showLeaveModal = false
    
    var body: some View {
        
        HStack {
            Button(action: { container.router.pop() }) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.black)
                    .font(Font.system(size: 18))
            }
            
            Spacer()
            
            Text(chatRoomName)
                .font(Font.Pretend.pretendardBold(size: 16))
            
            Spacer()
            
            
            Button(action: { showLeaveModal = true }) {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundStyle(.black)
                    .frame(width: 18, height: 24) // 아이콘 크기 조정
                    .contentShape(Rectangle())    // 터치 영역 확장
            }
            
        }.padding()
            .sheet(isPresented: $showLeaveModal) {
                LeaveActionSheet(
                    onLeave: {
                        showLeaveModal = false
                        container.chatService.leaveRoom(roomId: chatRoomId) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let response):
                                    print("성공 응답: \(response.message)")
                                    showToast(response.message, true)
                                    container.chatRefreshSubject.send()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        container.router.pop()
                                    }
                                case .failure(let error):
                                    let errorMessage = (error as? APIError)?.message ?? "오류가 발생했습니다."
                                    print("실패 응답: \(errorMessage)")
                                    showToast(errorMessage, false)
                                }
                            }
                        }
                    },
                    onCancel: {
                        showLeaveModal = false
                    },
                    leaveText: "채팅방 나가기"
                )
            }
    }
    
}

#Preview {
}
