//
//  ChatRoomView.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI

struct ChatRoomWrapper: View {
    @Environment(\.diContainer) private var container
    let currentUserUuid: String
    let roomId: String
    let chatRoomName: String
    
    var body: some View {
        let viewModel = ChatRoomViewModel(roomId: roomId, currentUserUuid: currentUserUuid,chatService: container.chatService)
        ChatRoomView(viewModel: viewModel, chatRoomName: chatRoomName)
    }
}

struct ChatRoomView: View {
    @StateObject private var viewModel: ChatRoomViewModel
    let chatRoomName: String
    
    
    init(viewModel: ChatRoomViewModel, chatRoomName: String) {
        self.chatRoomName = chatRoomName
        _viewModel = StateObject(wrappedValue:viewModel)
    }
    
    var body: some View {
        VStack {
            ChatRoomNavBar(chatRoomName: chatRoomName)
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages, id: \.id) { message in
                            ChatMessageView(message: message, currentUserUuid: viewModel.currentUserUuid)
                                .id(message.id)
                        }
                    }
                    .padding(.top)
                }
                .onChange(of: viewModel.messages.count) { _, _ in // 메시지 수신 시 스크롤 처리
                    if let last = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.lastMessageIdToScroll) { _, id in // 메시지 전송 시 스크롤 처리
                    if let id = id {
                        withAnimation {
                            proxy.scrollTo(id, anchor: .bottom)
                        }
                    }
                }
            }
            
            
            ChatInputView(
                messageText: $viewModel.messageText,
                sendAction: {
                    viewModel.postMessage(type: "TEXT")
                }
            )
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}



struct ChatInputView: View {
    @Binding var messageText: String  // 입력된 메시지를 외부에서 바인딩
    let sendAction: () -> Void        // 메시지 전송 액션
    
    var body: some View {
        HStack {
            TextEditor(text: $messageText)
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .frame(height: 50)
                .overlay(
                    Text("메시지를 입력하세요")
                        .foregroundStyle(.gray)
                        .padding(.leading, 15)
                        .opacity(messageText.isEmpty ? 1 : 0), alignment: .leading
                )
            
            Button(action: {
                sendAction()
                messageText = ""  // 메시지 전송 후 초기화
                //키보드 내리기
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.white)  // 아이콘 색상 흰색
                    .padding(12)
                    .background(messageText.isEmpty ? Color.gray.opacity(0.5) : Color.orange)  // 배경색 오렌지
                    .clipShape(Circle())  // 동그라미 모양
            }
            .disabled(messageText.isEmpty)  // 메시지가 없으면 버튼 비활성화
            .frame(width: 44, height: 44)  // 버튼 크기 지정
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
}

