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
        let host = Bundle.main.object(forInfoDictionaryKey: "ChatWebSocket_URL") as? String ?? "localhost"
        
        ChatRoomView(
            roomId: roomId,
            currentUserUuid: currentUserUuid,
            chatRoomName: chatRoomName,
            chatService: container.chatService,
            webSocketHost: host
        )
        .navigationBarBackButtonHidden(true)
    }
}

struct ChatRoomView: View {
    @StateObject private var viewModel: ChatRoomViewModel
    let chatRoomName: String
       
    init(
        roomId: String,
        currentUserUuid: String,
        chatRoomName: String,
        chatService: ChatService,
        webSocketHost: String
    ) {
        self.chatRoomName = chatRoomName
        _viewModel = StateObject(
            wrappedValue: ChatRoomViewModel(
                roomId: roomId,
                currentUserUuid: currentUserUuid,
                chatService: chatService,
                webSocketHost: webSocketHost
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 네비게이션 바
            ChatRoomNavBar(chatRoomName: chatRoomName)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
            
            // 연결 상태 표시
            ConnectionStatusView(
                isConnected: viewModel.isConnected,
                isLoading: viewModel.isLoading,
                connectionError: viewModel.connectionError,
                statusText: viewModel.connectionStatusText,
                onRetry: {
                    viewModel.retryConnection()
                }
            )
            
            // 메시지 리스트
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        // 로딩 인디케이터 (상단)
                        if viewModel.isLoading && viewModel.messages.isEmpty {
                            VStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("메시지를 불러오는 중...")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                        } else if viewModel.isLoading && !viewModel.messages.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("이전 메시지 로딩 중...")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // 메시지 리스트
                        ForEach(viewModel.messages, id: \.id) { message in
                            ChatMessageView(
                                message: message,
                                currentUserUuid: viewModel.currentUserUuid
                            )
                            .id(message.id)
                        }
                        
                        // 타이핑 인디케이터
                        if !viewModel.getTypingText().isEmpty {
                            TypingIndicatorView(text: viewModel.getTypingText())
                                .id("typing-indicator") // 고유 ID 추가
                        }
                    }
                    .padding(.top)
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.lastMessageIdToScroll) { _, id in
                    if let id = id {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.getTypingText()) { _, typingText in
                    // 타이핑 상태가 변경될 때도 스크롤
                    if !typingText.isEmpty {
                        // 타이핑 인디케이터로 스크롤
                        withAnimation(.easeInOut(duration: 0.2)) {
                            proxy.scrollTo("typing-indicator", anchor: .bottom)
                        }
                    } else if let lastMessage = viewModel.messages.last {
                        // 타이핑이 끝나면 마지막 메시지로 스크롤
                        withAnimation(.easeInOut(duration: 0.2)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .refreshable {
                    viewModel.fetchMorePreviousMessages()
                }
            }
            
            // 입력창
            ChatInputView(
                messageText: $viewModel.messageText,
                isConnected: viewModel.isConnected && viewModel.serverAutoJoined,
                sendAction: {
                    viewModel.postMessage(type: "TEXT")
                },
                onTypingChanged: { isTyping in
                    viewModel.sendTyping(isTyping)
                }
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.disconnectWebSocket()
        }
        .onAppear {
            // 뷰가 나타날 때 연결 상태 확인
            viewModel.checkConnectionStatus()
        }
    }
}

// MARK: - 연결 상태 뷰 컴포넌트
struct ConnectionStatusView: View {
    let isConnected: Bool
    let isLoading: Bool
    let connectionError: String?
    let statusText: String
    let onRetry: () -> Void
    
    var body: some View {
        if !isConnected || connectionError != nil {
            HStack(spacing: 8) {
                // 상태 아이콘
                Group {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 16, height: 16)
                    } else if connectionError != nil {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                    } else {
                        Image(systemName: "wifi.slash")
                            .foregroundColor(.orange)
                            .font(.system(size: 14))
                    }
                }
                
                // 상태 텍스트
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(connectionError != nil ? .red : .gray)
                
                Spacer()
                
                // 재시도 버튼 (에러가 있을 때만)
                if connectionError != nil && !isLoading {
                    Button("재시도") {
                        onRetry()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                connectionError != nil ? Color.red.opacity(0.1) : Color.yellow.opacity(0.1)
            )
            .transition(.slide)
        }
    }
}

// MARK: - 채팅 입력 뷰
struct ChatInputView: View {
    @Binding var messageText: String
    let isConnected: Bool
    let sendAction: () -> Void
    let onTypingChanged: (Bool) -> Void
    
    @State private var isTyping = false
    @State private var typingTimer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                // 이미지 첨부 버튼
                /*
                Button(action: {
                    // TODO: 이미지 선택 구현
                }) {
                    Image(systemName: "photo")
                        .foregroundColor(isConnected ? .gray : .gray.opacity(0.5))
                        .font(.system(size: 20))
                }
                .disabled(!isConnected)
                */
                
                // 텍스트 입력
                TextField("메시지를 입력하세요", text: $messageText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...4)
                    .onChange(of: messageText) { _, newValue in
                        handleTextChange(newValue)
                    }
                    .disabled(!isConnected)
                    .opacity(isConnected ? 1.0 : 0.6)
                
                // 전송 버튼
                Button(action: {
                    sendAction()
                    stopTyping()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .padding(8)
                        .background(
                            messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !isConnected ?
                            Color.gray.opacity(0.5) : Color.blue
                        )
                        .clipShape(Circle())
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !isConnected)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.white)
    }
    
    private func handleTextChange(_ newValue: String) {
        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmed.isEmpty && !isTyping && isConnected {
            startTyping()
        }
        
        // 타이핑 타이머 리셋
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            stopTyping()
        }
        
        // 빈 텍스트가 되면 즉시 타이핑 중지
        if trimmed.isEmpty {
            stopTyping()
        }
    }
    
    private func startTyping() {
        isTyping = true
        onTypingChanged(true)
    }
    
    private func stopTyping() {
        if isTyping {
            isTyping = false
            onTypingChanged(false)
        }
        typingTimer?.invalidate()
        typingTimer = nil
    }
}



// MARK: - 확장
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    struct PreviewView: View {
        var body: some View {
            NavigationView {
                VStack {
                    ConnectionStatusView(
                        isConnected: false,
                        isLoading: true,
                        connectionError: nil,
                        statusText: "연결 중... (5초)",
                        onRetry: {}
                    )
                    
                    Spacer()
                    
                    ConnectionStatusView(
                        isConnected: false,
                        isLoading: false,
                        connectionError: "네트워크 연결 실패",
                        statusText: "연결 실패: 네트워크 연결 실패",
                        onRetry: {}
                    )
                    
                    Spacer()
                }
            }
        }
    }
    
    return PreviewView()
}
