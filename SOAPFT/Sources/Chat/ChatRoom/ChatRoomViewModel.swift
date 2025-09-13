//
//  ChatRoomViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI
import Combine

final class ChatRoomViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var messages: [ChatMessage] = []
    @Published var messageText: String = ""
    @Published var typingUsers: [TypingUser] = []
    @Published var isConnected = false
    @Published var connectionError: String?
    @Published var isLoading = false
    @Published var lastMessageIdToScroll: Int? = nil
    
    // MARK: - Private Properties
    private let chatService: ChatService
    private let chatWebSocket: ChatWebSocket
    private var cancellables = Set<AnyCancellable>()
    
    let currentUserUuid: String
    private let roomId: String
    
    // 페이징 관련
    private var currentPage: Int = 1
    private var hasMore: Bool = true
    private var lastMessageId: Int? = nil
    
    // 연결 상태 추적
    private var connectionStartTime: Date?
    private var connectionTimeoutTimer: Timer?
    
    // 서버 자동 join 상태 추적 (공개)
    @Published var serverAutoJoined = false
    
    // MARK: - Initialization
    init(
        roomId: String,
        currentUserUuid: String,
        chatService: ChatService,
        webSocketHost: String,
        webSocketPort: Int = 443
    ) {
        self.roomId = roomId
        self.currentUserUuid = currentUserUuid
        self.chatService = chatService
        self.chatWebSocket = ChatWebSocket(host: webSocketHost, port: webSocketPort, namespace: "/chat")
        
        setupWebSocketCallbacks()
        bindWebSocketProperties()
        fetchInitialMessages()
        connectWebSocket()
    }
    
    // MARK: - Setup Methods
    private func setupWebSocketCallbacks() {
        chatWebSocket.onConnected = { [weak self] event in
            Task { @MainActor in
                print("WebSocket 연결 및 인증 완료")
                print("사용자: \(event.userUuid)")
                print("서버가 자동으로 모든 채팅방에 join 처리 완료")
                
                self?.connectionTimeoutTimer?.invalidate()
                self?.connectionTimeoutTimer = nil
                self?.isConnected = true
                self?.isLoading = false
                self?.connectionError = nil
                self?.connectionStartTime = nil
                self?.serverAutoJoined = true
                
                print("실시간 메시지 수신 준비 완료")
                
                // WebSocket 연결 완료 후 기존 메시지들 읽음 처리
                self?.markAllMessagesAsReadIfNeeded()
            }
        }
        
        chatWebSocket.onJoinedRoom = { [weak self] roomUuid in
            Task { @MainActor in
                print("채팅방 입장 확인: \(roomUuid)")
                if roomUuid == self?.roomId {
                    print("현재 채팅방 입장 완료")
                }
            }
        }
        
        chatWebSocket.onNewMessage = { [weak self] message in
            Task { @MainActor in
                print("실시간 메시지 수신!")
                print("발신자: \(message.sender?.nickname ?? "알 수 없음")")
                print("내용: \(message.content)")
                print("채팅방: \(message.roomUuid ?? "알 수 없음")")
                
                self?.handleNewWebSocketMessage(message)
            }
        }
        
        chatWebSocket.onSystemMessage = { [weak self] systemMessage in
            Task { @MainActor in
                self?.handleSystemMessage(systemMessage)
            }
        }
        
        chatWebSocket.onMessagesRead = { [weak self] event in
            Task { @MainActor in
                self?.handleMessagesRead(event)
            }
        }
        
        chatWebSocket.onUserTyping = { [weak self] event in
            Task { @MainActor in
                self?.handleUserTyping(event)
            }
        }
        
        chatWebSocket.onError = { [weak self] error in
            Task { @MainActor in
                self?.connectionTimeoutTimer?.invalidate()
                self?.connectionTimeoutTimer = nil
                self?.connectionError = error.message
                self?.isConnected = false
                self?.isLoading = false
                print("채팅 WebSocket 에러: \(error.message)")
            }
        }
        
        chatWebSocket.onReconnected = { [weak self] in
            Task { @MainActor in
                print("재연결 완료 - 모든 채팅방 자동 재입장됨")
                self?.serverAutoJoined = true
                self?.connectionError = nil
            }
        }
    }
    
    private func bindWebSocketProperties() {
        chatWebSocket.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                guard let self = self else { return }
                print("ChatWebSocket isConnected 변경: \(connected)")

                if connected {
                    self.connectionTimeoutTimer?.invalidate()
                    self.connectionTimeoutTimer = nil
                    self.connectionError = nil
                    self.isLoading = false
                    self.isConnected = true
                    self.serverAutoJoined = true
                } else {
                    self.isConnected = false
                    self.serverAutoJoined = false
                    // 로딩 상태는 reconnect 로직에서 관리
                }
            }
            .store(in: &cancellables)

        chatWebSocket.$connectionError
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.connectionError = error
                self?.isConnected = false
                self?.isLoading = false
                self?.connectionTimeoutTimer?.invalidate()
                self?.connectionTimeoutTimer = nil
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Connection Methods
    func connectWebSocket() {
        guard let token = KeyChainManager.shared.read(forKey: KeyChainKey.accessToken) else {
            print("채팅 WebSocket 연결용 토큰 없음")
            connectionError = "인증 토큰이 없습니다."
            isLoading = false
            return
        }
        
        print("WebSocket 연결 시작...")
        connectionStartTime = Date()
        isLoading = true
        isConnected = false
        connectionError = nil
        serverAutoJoined = false
        
        // 연결 타임아웃 설정 (30초)
        connectionTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                
                if !self.isConnected {
                    print("WebSocket 연결 타임아웃")
                    self.connectionError = "채팅 서버 연결 시간이 초과되었습니다."
                    self.isLoading = false
                    self.isConnected = false
                    self.chatWebSocket.disconnect()
                }
            }
        }
        
        chatWebSocket.connect(with: token)
    }
    
    func disconnectWebSocket() {
        print("WebSocket 연결 종료")
        
        connectionTimeoutTimer?.invalidate()
        connectionTimeoutTimer = nil
        
        isConnected = false
        isLoading = false
        connectionStartTime = nil
        serverAutoJoined = false
        
        chatWebSocket.disconnect()
    }
    
    func retryConnection() {
        print("수동 재연결 시도")
        disconnectWebSocket()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.connectWebSocket()
        }
    }
    
    // MARK: - REST API Methods
    func fetchInitialMessages(limit: Int = 15) {
        guard !isLoading else { return }
        print("초기 메시지 로드 시작")
        isLoading = true
        
        chatService.getMessages(
            roomId: roomId,
            page: 1,
            limit: limit,
            lastMessageId: nil,
            beforeMessageId: nil
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let response):
                    self.messages = response.messages
                    print("초기 메시지 \(response.messages.count)개 로드됨")
                    print("페이징 정보: \(response.pagination)")

                    // lastMessageId를 가장 오래된 메시지로 설정 (첫 번째 메시지)
                    if let firstMessage = response.messages.first {
                        self.lastMessageId = firstMessage.id
                        print("초기 lastMessageId 설정: \(firstMessage.id)")
                    }

                    // hasMore 설정 - 더 관대하게 설정
                    if let hasNext = response.pagination.hasNext {
                        self.hasMore = hasNext
                    } else {
                        // hasNext가 nil이면 메시지 개수로 판단
                        self.hasMore = response.messages.count >= limit
                    }
                    
                    self.currentPage = 2
                    print("hasMore: \(self.hasMore), currentPage: \(self.currentPage)")
                    print("totalPages: \(response.pagination.totalPages), currentPage: \(response.pagination.currentPage)")
                    
                    // 메시지 로드 후 자동 읽음 처리
                    self.markAllMessagesAsReadIfNeeded()

                case .failure(let error):
                    print("초기 메시지 불러오기 실패: \(error)")
                }
            }
        }
    }
    
    // 필요시 모든 메시지를 읽음 처리
    private func markAllMessagesAsReadIfNeeded() {
        // 연결이 완료되었고, 읽지 않은 메시지가 있으면 읽음 처리
        if serverAutoJoined {
            let unreadMessages = messages.filter { message in
                if let sender = message.sender, sender.userUuid != currentUserUuid {
                    return !message.isRead || !message.readByUuids.contains(currentUserUuid)
                }
                return false
            }
            
            if !unreadMessages.isEmpty {
                print("읽지 않은 메시지 \(unreadMessages.count)개 자동 읽음 처리")
                markAsReadWebSocket()
            }
        }
    }
    
    func fetchMorePreviousMessages(limit: Int = 15) {
        guard !isLoading else {
            print("이미 로딩 중이므로 이전 메시지 로드 스킵")
            return
        }
        
        // hasMore가 false여도 일단 시도해보기
        print("이전 메시지 로드 시도: hasMore=\(hasMore)")
        
        guard let lastId = lastMessageId else {
            print("lastMessageId가 없어서 이전 메시지 로드 불가")
            return
        }

        print("이전 메시지 로드 시작: page=\(currentPage), lastMessageId=\(lastId)")
        isLoading = true

        chatService.getMessages(
            roomId: roomId,
            page: currentPage,
            limit: limit,
            lastMessageId: lastId,
            beforeMessageId: nil
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let response):
                    let newMessages = response.messages
                    print("새로운 메시지 \(newMessages.count)개 로드됨")
                    print("응답 페이징 정보: \(response.pagination)")
                    
                    if newMessages.isEmpty {
                        print("더 이상 불러올 메시지가 없습니다")
                        self.hasMore = false
                        return
                    }
                    
                    // 기존 메시지 앞에 추가
                    self.messages.insert(contentsOf: newMessages, at: 0)

                    // lastMessageId를 가장 오래된 메시지 ID로 업데이트
                    if let oldestMessage = newMessages.first {
                        self.lastMessageId = oldestMessage.id
                        print("lastMessageId 업데이트: \(oldestMessage.id)")
                    }

                    // hasMore 업데이트
                    if let hasNext = response.pagination.hasNext {
                        self.hasMore = hasNext
                    } else {
                        // hasNext가 nil이면 메시지 개수로 판단
                        self.hasMore = newMessages.count >= limit
                    }
                    
                    self.currentPage += 1
                    print("hasMore: \(self.hasMore), 다음 페이지: \(self.currentPage)")

                case .failure(let error):
                    print("이전 메시지 불러오기 실패: \(error)")
                    // 실패해도 hasMore는 유지 (재시도 가능하도록)
                }
            }
        }
    }
    
    // MARK: - Message Sending
    func postMessage(type: String = "TEXT") {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard isConnected && serverAutoJoined else {
            print("아직 서버에 연결되지 않음 - 메시지 전송 불가")
            connectionError = "서버에 연결 중입니다. 잠시 후 다시 시도해주세요."
            return
        }
        
        let content = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        messageText = ""
        
        // 내가 보낸 메시지는 임시로 추가 (optimistic update)
        let tempMessage = createTempMessage(content: content, type: type)
        messages.append(tempMessage)
        lastMessageIdToScroll = tempMessage.id
        
        // WebSocket으로 전송
        chatWebSocket.sendMessage(roomUuid: roomId, type: type, content: content)
        print("WebSocket으로 메시지 전송: \(content)")
    }
    
    // MARK: - 임시 메시지 생성 (내 메시지용)
    private func createTempMessage(content: String, type: String) -> ChatMessage {
        return ChatMessage(
            id: Int.random(in: 100000...999999),
            roomUuid: roomId,
            type: type,
            content: content,
            imageUrl: nil,
            sender: Sender(
                userUuid: currentUserUuid,  // 내 메시지이므로 currentUserUuid 맞음
                nickname: "나",
                profileImage: nil
            ),
            isRead: false,
            readByUuids: [currentUserUuid],
            isMyMessage: true,  // 내 메시지이므로 true 맞음
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }
    
    // MARK: - WebSocket Event Handlers (핵심 수정)
    private func handleNewWebSocketMessage(_ message: ChatMessage) {
        // 현재 채팅방의 메시지인지 확인
        if message.roomUuid == roomId {
            print("=== 새 메시지 상세 분석 ===")
            print("메시지 ID: \(message.id)")
            print("발신자 UUID: \(message.sender?.userUuid ?? "nil")")
            print("발신자 닉네임: \(message.sender?.nickname ?? "nil")")
            print("현재 사용자 UUID: \(currentUserUuid)")
            print("원본 isMyMessage: \(message.isMyMessage)")
            print("내용: \(message.content)")
            print("===========================")
            
            // 중복 메시지 방지 (임시 메시지와 실제 메시지)
            if !messages.contains(where: { $0.id == message.id }) {
                
                // 핵심 수정: 내가 보낸 메시지인지 정확히 판단
                var processedMessage = message
                if let sender = message.sender {
                    processedMessage.isMyMessage = (sender.userUuid == currentUserUuid)
                    print("메시지 소유자 판단: \(sender.userUuid) == \(currentUserUuid) → \(processedMessage.isMyMessage)")
                } else {
                    processedMessage.isMyMessage = false
                    print("발신자 정보 없음 → 상대방 메시지로 처리")
                }
                
                // 내가 보낸 메시지라면 임시 메시지를 제거하고 실제 메시지로 교체
                if processedMessage.isMyMessage {
                    // 임시 메시지 제거 (내용이 같은 가장 최근 메시지)
                    if let tempIndex = messages.lastIndex(where: {
                        $0.content == processedMessage.content &&
                        $0.sender?.userUuid == currentUserUuid &&
                        $0.id >= 100000 // 임시 메시지 ID 범위
                    }) {
                        print("임시 메시지 제거하고 실제 메시지로 교체")
                        messages.remove(at: tempIndex)
                    }
                }
                
                messages.append(processedMessage)
                lastMessageIdToScroll = processedMessage.id
                
                print("실시간 메시지 UI에 추가됨 (isMyMessage: \(processedMessage.isMyMessage))")
                
                // 다른 사용자의 메시지면 자동 읽음 처리
                if !processedMessage.isMyMessage {
                    print("다른 사용자 메시지 - 자동 읽음 처리")
                    markAsReadWebSocket()
                }
            } else {
                print("중복 메시지 - 무시됨")
            }
        } else {
            handleBackgroundMessage(message)
        }
    }
    
    private func handleSystemMessage(_ systemMessage: SystemMessage) {
        if systemMessage.roomUuid == roomId {
            let message = ChatMessage(
                id: Int.random(in: 100000...999999),
                roomUuid: systemMessage.roomUuid,
                type: "SYSTEM",
                content: systemMessage.message,
                imageUrl: nil,
                sender: nil,
                isRead: true,
                readByUuids: [],
                isMyMessage: false,
                createdAt: systemMessage.timestamp
            )
            messages.append(message)
            lastMessageIdToScroll = message.id
            print("시스템 메시지 추가: \(systemMessage.message)")
        }
    }
    
    private func handleMessagesRead(_ event: MessagesReadEvent) {
        if event.roomUuid == roomId {
            print("메시지 읽음 이벤트: \(event.userUuid) - 전체 메시지 \(messages.count)개 확인 중")
            
            var updatedCount = 0
            
            // 모든 메시지를 확인하여 내가 보낸 메시지의 읽음 상태 업데이트
            for i in messages.indices {
                // 내가 보낸 메시지이고, 아직 해당 사용자가 읽지 않은 메시지라면
                if let sender = messages[i].sender,
                   sender.userUuid == currentUserUuid,
                   !messages[i].readByUuids.contains(event.userUuid) {
                    
                    messages[i].readByUuids.append(event.userUuid)
                    messages[i].isRead = true
                    updatedCount += 1
                    
                    print("메시지 \(messages[i].id) 읽음 상태 업데이트")
                }
            }
            
            print("총 \(updatedCount)개 메시지 읽음 상태 업데이트 완료")
        }
    }
    
    private func handleUserTyping(_ event: UserTypingEvent) {
        print("타이핑 이벤트 수신: roomUuid=\(event.roomUuid), userUuid=\(event.userUuid), isTyping=\(event.isTyping)")
        print("현재 채팅방: \(roomId), 현재 사용자: \(currentUserUuid)")
        
        if event.roomUuid == roomId && event.userUuid != currentUserUuid {
            print("타이핑 이벤트 처리 중...")
            
            if event.isTyping {
                let nickname = event.nickname ?? "사용자"
                let typingUser = TypingUser(
                    userUuid: event.userUuid,
                    nickname: nickname,
                    roomUuid: event.roomUuid
                )
                
                if !typingUsers.contains(where: { $0.userUuid == event.userUuid }) {
                    typingUsers.append(typingUser)
                    print("타이핑 사용자 추가: \(nickname), 총 \(typingUsers.count)명")
                }
            } else {
                let removedCount = typingUsers.count
                typingUsers.removeAll { $0.userUuid == event.userUuid }
                print("타이핑 사용자 제거: \(removedCount) → \(typingUsers.count)명")
            }
            
            print("현재 타이핑 텍스트: '\(getTypingText())'")
        } else {
            print("타이핑 이벤트 무시 - 다른 채팅방이거나 본인")
        }
    }
    
    private func handleBackgroundMessage(_ message: ChatMessage) {
        print("백그라운드 메시지 (다른 채팅방): \(message.content)")
        // TODO: 푸시 알림 로직 구현
    }
    
    // MARK: - WebSocket Actions
    func markAsReadWebSocket() {
        guard serverAutoJoined else {
            print("아직 서버 자동 join 완료되지 않음")
            return
        }
        
        chatWebSocket.markAsRead(roomId)
    }
    
    func sendTyping(_ isTyping: Bool) {
        guard serverAutoJoined else { return }
        
        chatWebSocket.sendTyping(roomUuid: roomId, isTyping: isTyping)
    }
    
    // MARK: - Helper Methods
    func getTypingText() -> String {
        switch typingUsers.count {
        case 0:
            return ""
        case 1:
            return "입력 중..."
        case 2:
            return "2명이 입력 중..."
        default:
            return "\(typingUsers.count)명이 입력 중..."
        }
    }
    
    var connectionStatusText: String {
        if isConnected && serverAutoJoined {
            return "연결됨"
        } else if isConnected {
            return "연결됨 (초기화 중)"
        } else if isLoading {
            if let startTime = connectionStartTime {
                let elapsed = Date().timeIntervalSince(startTime)
                return "연결 중... (\(Int(elapsed))초)"
            } else {
                return "연결 중..."
            }
        } else if let error = connectionError {
            return "연결 실패: \(error)"
        } else {
            return "연결 안됨"
        }
    }
    
    // MARK: - 추가된 메서드들
    func refreshMessages() async {
        await MainActor.run {
            fetchMorePreviousMessages()
        }
    }
    
    func checkConnectionStatus() {
        print("연결 상태 확인: connected=\(isConnected), serverAutoJoined=\(serverAutoJoined)")
        
        // 연결이 끊어져 있으면 재연결 시도
        if !isConnected && !isLoading {
            print("연결이 끊어져 있어 재연결 시도")
            connectWebSocket()
        }
    }

    
    // MARK: - 정리
    deinit {
        connectionTimeoutTimer?.invalidate()
        disconnectWebSocket()
    }
}
