//
//  ChatRoomView.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI

struct ChatRoomView: View {
    @StateObject private var viewModel: ChatRoomViewModel

    let chatRoomName: String

    init(messages: [ChatMessageDTO], chatRoomName: String, currentUserUuid: String) {
        self.chatRoomName = chatRoomName
        _viewModel = StateObject(wrappedValue: ChatRoomViewModel(messages: messages, currentUserUuid: currentUserUuid))
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
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let last = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            ChatInputView(messageText: $viewModel.messageText) {
                viewModel.sendMessage()
            }
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
                        .foregroundColor(.gray)
                        .padding(.leading, 15)
                        .opacity(messageText.isEmpty ? 1 : 0), alignment: .leading
                )

            Button(action: {
                            sendAction()
                            messageText = ""  // 메시지 전송 후 초기화
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)  // 아이콘 색상 흰색
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
    NavigationStack {
        ChatRoomView(messages: mockMessages, chatRoomName: "30일 헬스 챌린지", currentUserUuid: me.userUuid)
    }
}

