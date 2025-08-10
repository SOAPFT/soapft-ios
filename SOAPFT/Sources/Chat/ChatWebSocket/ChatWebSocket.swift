//
//  ChatWebSocket.swift
//  SOAPFT
//
//  Created by 바견규 on 8/9/25.
//



import Foundation
import Combine

final class ChatWebSocket: NSObject, ObservableObject {
    // MARK: - Published
    @Published var isConnected = false
    @Published var connectionError: String?
    @Published var currentUserUuid: String?

    // MARK: - Private
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession!
    private let host: String
    private let port: Int
    private let allowInsecureConnections: Bool

    // 재연결 관리
    private var retryCount = 0
    private let maxRetries = 5

    // typing 타이머
    private var typingTimers: [String: Timer] = [:]

    // Socket.IO 상태
    private var socketIOConnected = false
    private var sessionId: String?
    private var pingInterval: TimeInterval = 25
    private var pingTimeout: TimeInterval = 20

    // 인증
    private var jwtToken: String?

    // 플래그
    private var didSendOpen = false

    // 네임스페이스
    private let namespace: String

    // 인스턴스 추적/상태머신
    private let instanceId = String(UUID().uuidString.prefix(8))
    private enum WSState { case idle, connecting, open, closing, closed }
    private var state: WSState = .idle

    private func log(_ msg: String) { print("[WS:\(instanceId)] \(msg)") }

    // MARK: - Callbacks
    var onConnected: ((ConnectedEvent) -> Void)?
    var onJoinedRoom: ((String) -> Void)?
    var onLeftRoom: ((String) -> Void)?
    var onNewMessage: ((ChatMessage) -> Void)?
    var onSystemMessage: ((SystemMessage) -> Void)?
    var onMessagesRead: ((MessagesReadEvent) -> Void)?
    var onUserTyping: ((UserTypingEvent) -> Void)?
    var onError: ((ErrorEvent) -> Void)?
    var onReconnected: (() -> Void)?

    // MARK: - Init
    init(host: String,
         port: Int = 443,
         allowInsecureConnections: Bool = false,
         namespace: String = "/chat") {
        self.host = host
        self.port = port
        self.allowInsecureConnections = allowInsecureConnections
        self.namespace = namespace
        super.init()

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60

        self.urlSession = URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }

    // MARK: - Public
    func connect(with token: String) {
        jwtToken = token
        socketIOConnected = false
        sessionId = nil
        didSendOpen = false

        guard state == .idle || state == .closed else {
            log("⏭️ connect 무시 (state=\(state))")
            return
        }
        state = .connecting
        internalConnect()
    }

    func disconnect() {
        guard state == .connecting || state == .open else {
            log("⏭️ disconnect 무시 (state=\(state))")
            return
        }
        state = .closing

        if socketIOConnected { sendSocketIOMessage("41") }

        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil

        socketIOConnected = false
        sessionId = nil
        didSendOpen = false
        typingTimers.values.forEach { $0.invalidate() }
        typingTimers.removeAll()

        DispatchQueue.main.async {
            self.isConnected = false
            self.currentUserUuid = nil
        }
        state = .closed
        log("📤 채팅 WebSocket 연결 종료")
    }

    func sendMessage(roomUuid: String, type: String, content: String, imageUrl: String? = nil) {
        let payload = SendMessageRequest.MessageRequest(type: type, content: content, imageUrl: imageUrl)
        let request = SendMessageRequest(roomUuid: roomUuid, message: payload)
        sendSocketIOEvent("sendMessage", data: request)
        log("📤 메시지 전송: \(content)")
    }

    func markAsRead(_ roomUuid: String) {
        let request = MarkAsReadRequest(roomUuid: roomUuid)
        sendSocketIOEvent("markAsRead", data: request)
    }

    func sendTyping(roomUuid: String, isTyping: Bool) {
        let request = TypingRequest(roomUuid: roomUuid, isTyping: isTyping)
        sendSocketIOEvent("typing", data: request)

        if isTyping {
            typingTimers[roomUuid]?.invalidate()
            typingTimers[roomUuid] = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                self?.sendTyping(roomUuid: roomUuid, isTyping: false)
                self?.typingTimers.removeValue(forKey: roomUuid)
            }
        } else {
            typingTimers[roomUuid]?.invalidate()
            typingTimers.removeValue(forKey: roomUuid)
        }
    }

    func leaveRoom(_ roomUuid: String) {
        let request = LeaveRoomRequest(roomUuid: roomUuid)
        sendSocketIOEvent("leaveRoom", data: request)
        log("🚪 채팅방 나가기 요청: \(roomUuid)")
    }
    
    // MARK: - 테스트 메서드
    func sendTestEvent() {
        guard socketIOConnected else {
            log("⚠️ Socket.IO 연결되지 않음")
            return
        }
        
        log("🧪 연결 상태 확인:")
        log("🧪 - socketIOConnected: \(socketIOConnected)")
        log("🧪 - state: \(state)")
        log("🧪 - sessionId: \(sessionId ?? "nil")")
        log("🧪 - jwtToken 존재: \(jwtToken != nil)")
        
        // 간단한 테스트 이벤트 전송
        let testData = ["message": "test", "timestamp": Date().timeIntervalSince1970] as [String: Any]
        
        do {
            let eventArray: [Any] = ["test", testData]
            let eventData = try JSONSerialization.data(withJSONObject: eventArray)
            let eventString = String(data: eventData, encoding: .utf8)!
            let payload = "42\(eventString)"
            
            log("🧪 테스트 이벤트 전송: \(payload)")
            sendSocketIOMessage(payload)
        } catch {
            log("❌ 테스트 이벤트 전송 실패: \(error)")
        }
    }
    
    // 서버 연결 상태 디버깅
    func debugConnectionStatus() {
        log("🔍 === 연결 상태 디버깅 ===")
        log("🔍 WebSocket 연결: \(webSocketTask != nil)")
        log("🔍 Socket.IO 연결: \(socketIOConnected)")
        log("🔍 상태: \(state)")
        log("🔍 세션 ID: \(sessionId ?? "없음")")
        log("🔍 JWT 토큰: \(jwtToken != nil ? "있음" : "없음")")
        log("🔍 재시도 횟수: \(retryCount)")
        log("🔍 ========================")
    }

    // MARK: - Core Connect
    private func internalConnect() {
        guard let token = jwtToken else { log("❌ JWT 토큰 없음"); return }
        guard retryCount <= maxRetries else {
            log("❌ 최대 재연결 시도 초과")
            DispatchQueue.main.async { self.connectionError = "채팅 서버 연결에 실패했습니다." }
            state = .closed
            return
        }

        let secure = shouldUseSecureConnection()
        let scheme = secure ? "wss" : "ws"
        let defaultPort = secure ? 443 : 80

        let socketURL: String = {
            if port == defaultPort {
                return "\(scheme)://\(host)/socket.io/?EIO=4&transport=websocket&token=\(token)"
            } else {
                return "\(scheme)://\(host):\(port)/socket.io/?EIO=4&transport=websocket&token=\(token)"
            }
        }()

        guard let url = URL(string: socketURL) else { log("❌ 잘못된 URL: \(socketURL)"); return }

        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.timeoutInterval = 30

        webSocketTask = urlSession.webSocketTask(with: req)
        webSocketTask?.resume()
        log("📡 채팅 WebSocket 연결 시도: \(socketURL)")

        listen()
    }

    private func shouldUseSecureConnection() -> Bool {
        if allowInsecureConnections && (host.contains("localhost") || host.contains("127.0.0.1") || host.hasPrefix("192.168.") || host.hasPrefix("10.")) {
            return false
        }
        if retryCount > 0 && allowInsecureConnections {
            log("⚠️ SSL 실패 후 비보안으로 재시도")
            return false
        }
        return true
    }

    private func reconnect() {
        guard state != .closing else {
            log("⏭️ 재연결 생략 (closing)")
            return
        }
        retryCount += 1
        socketIOConnected = false
        sessionId = nil
        didSendOpen = false
        state = .closed

        let delay = min(10.0, pow(2.0, Double(retryCount)))
        log("🔄 재연결 시도 (\(retryCount)/\(maxRetries)) - \(delay)초 후")
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            self.state = .connecting
            self.internalConnect()
        }
    }

    // MARK: - Read Loop
    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                self.handleMessage(message)
                self.listen() // 계속 수신 대기
            case .failure(let error):
                self.log("❌ 메시지 수신 오류: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isConnected = false
                    self.socketIOConnected = false
                }
                self.reconnect()
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            log("💬 [수신] \(text)")
            parseSocketIOMessage(text)
        case .data(let data):
            log("📂 수신된 바이너리 데이터: \(data.count) bytes")
        @unknown default:
            log("❓ 알 수 없는 메시지 타입")
        }
    }

    // MARK: - Parse
    private func parseSocketIOMessage(_ message: String) {
        // Engine.IO 연결 응답
        if message.hasPrefix("0") {
            handleEngineIOConnect(message)
        }
        // Socket.IO 연결 완료 (네임스페이스 없음)
        else if message == "40" {
            handleSocketIOConnect()
        }
        // Socket.IO 연결 완료 (네임스페이스 포함)
        else if message.hasPrefix("40\(namespace)") {
            print("[WS:\(instanceId)] 🔗 Socket.IO 네임스페이스 연결 완료: \(message)")
            handleSocketIOConnect()
        }
        // Socket.IO 연결 완료 with data
        else if message.hasPrefix("40") && message.count > 2 {
            print("[WS:\(instanceId)] 🔗 Socket.IO 연결 with 데이터: \(message)")
            handleSocketIOConnect()
        }
        // Socket.IO 이벤트 (네임스페이스 포함)
        else if message.hasPrefix("42\(namespace),") {
            handleSocketIOEvent(message)
        }
        // Socket.IO 이벤트 (네임스페이스 없음)
        else if message.hasPrefix("42") {
            handleSocketIOEvent(message)
        }
        // Socket.IO ACK 응답
        else if message.hasPrefix("43") {
            print("[WS:\(instanceId)] 📋 ACK 응답 수신: \(message)")
        }
        // Socket.IO 에러
        else if message.hasPrefix("44") {
            print("[WS:\(instanceId)] ❌ Socket.IO 에러: \(message)")
        }
        // Engine.IO ping
        else if message == "2" {
            sendSocketIOMessage("3") // pong 응답
            print("[WS:\(instanceId)] 🏓 Ping → Pong")
        }
        // Engine.IO pong
        else if message == "3" {
            print("[WS:\(instanceId)] 🏓 Pong 수신")
        }
        else {
            print("[WS:\(instanceId)] ❓ 처리되지 않은 메시지: \(message)")
        }
    }

    private func handleEngineIOConnect(_ message: String) {
        print("[WS:\(instanceId)] 🔗 Engine.IO 연결 수신: \(message)")
        let jsonString = String(message.dropFirst(1))
        if let data = jsonString.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let sid = json["sid"] as? String {
                sessionId = sid
                print("[WS:\(instanceId)] ✅ Session ID: \(sid)")
            }
            if let pingInterval = json["pingInterval"] as? TimeInterval { self.pingInterval = pingInterval / 1000 }
            if let pingTimeout = json["pingTimeout"] as? TimeInterval { self.pingTimeout = pingTimeout / 1000 }
        }

        // Socket.IO 연결 요청 전송 (네임스페이스 포함)
        guard !socketIOConnected, !didSendOpen, state == .connecting else {
            print("[WS:\(instanceId)] ⏭️ 40 전송 생략 (connected=\(socketIOConnected), didSendOpen=\(didSendOpen), state=\(state))")
            return
        }
        didSendOpen = true
        
        // 네임스페이스 포함해서 연결 요청
        let connectMessage = "40\(namespace),"
        sendSocketIOMessage(connectMessage)
        print("[WS:\(instanceId)] ✅ Socket.IO 네임스페이스 연결 요청: \(connectMessage)")
    }

    private func handleSocketIOConnect() {
        guard !socketIOConnected else {
            log("⚠️ Socket.IO 이미 연결됨")
            return
        }
        log("✅ Socket.IO 연결 성공")
        socketIOConnected = true
        state = .open

        DispatchQueue.main.async {
            self.isConnected = true
            self.connectionError = nil
            self.retryCount = 0
        }
        
        log("🔄 서버 연결 완료, 이벤트 수신 대기 중...")
    }
    
    // 서버에 인증이나 ping 이벤트 전송
    private func sendAuthOrPingEvent() {
        guard socketIOConnected else { return }
        
        // 1. 간단한 ping 이벤트 시도
        let pingData = ["timestamp": Date().timeIntervalSince1970]
        sendRawEvent("ping", data: pingData)
        
        // 2. 인증 이벤트 시도 (서버가 요구할 수 있음)
        if let token = jwtToken {
            let authData = ["token": token]
            sendRawEvent("authenticate", data: authData)
        }
        
        // 3. 연결 확인 이벤트
        sendRawEvent("hello", data: ["client": "ios"])
    }
    
    // 원시 이벤트 전송 메서드
    private func sendRawEvent(_ eventName: String, data: [String: Any]) {
        do {
            let eventArray: [Any] = [eventName, data]
            let eventData = try JSONSerialization.data(withJSONObject: eventArray)
            let eventString = String(data: eventData, encoding: .utf8)!
            let payload = "42\(eventString)"
            
            log("📤 [원시 이벤트] \(eventName): \(payload)")
            sendSocketIOMessage(payload)
        } catch {
            log("❌ 원시 이벤트 전송 실패 (\(eventName)): \(error)")
        }
    }

    // MARK: - 이벤트 파싱 (개선됨)
    private func handleSocketIOEvent(_ message: String) {
        log("🎯 [원시 이벤트] \(message)")
        
        // "42" 제거 후 네임스페이스/ACK 처리
        var payload = String(message.dropFirst(2))
        
        // 네임스페이스 제거 (예: "/chat," → "")
        if payload.hasPrefix("/") {
            if let commaIndex = payload.firstIndex(of: ",") {
                payload = String(payload[payload.index(after: commaIndex)...])
                log("🏷️ 네임스페이스 제거 후: \(payload)")
            }
        }
        
        // ACK ID 제거 (숫자로 시작하는 경우)
        if let firstChar = payload.first, firstChar.isNumber {
            if let bracketIndex = payload.firstIndex(of: "[") {
                payload = String(payload[bracketIndex...])
                log("🔢 ACK ID 제거 후: \(payload)")
            }
        }
        
        // JSON 배열 파싱
        guard let data = payload.data(using: .utf8),
              let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [Any],
              let eventName = jsonArray.first as? String else {
            log("❌ 이벤트 파싱 실패: \(message)")
            log("❌ 처리된 페이로드: \(payload)")
            return
        }

        let eventData = jsonArray.count > 1 ? (jsonArray[1] as? [String: Any] ?? [:]) : [:]
        log("🎯 [이벤트명] \(eventName)")
        log("📋 [이벤트 데이터] \(eventData)")

        handleParsedEvent(eventName: eventName, data: eventData)
    }

    private func handleParsedEvent(eventName: String, data: [String: Any]) {
        switch eventName {
        case "connected":
            handleConnectedEvent(data)
        case "joinRoom", "joinedRoom":
            handleJoinRoomEvent(data)
        case "leftRoom":
            handleLeftRoomEvent(data)
        case "newMessage":
            handleNewMessageEvent(data)
        case "systemMessage":
            handleSystemMessageEvent(data)
        case "messagesRead":
            handleMessagesReadEvent(data)
        case "userTyping":
            handleUserTypingEvent(data)
        case "error":
            handleErrorEvent(data)
        case "reconnect":
            handleReconnectEvent()
        default:
            log("❓ 처리되지 않은 이벤트: \(eventName)")
        }
    }

    // MARK: - Send
    private func sendSocketIOMessage(_ message: String) {
        guard let webSocketTask = webSocketTask else {
            log("⚠️ WebSocket 연결 없음")
            return
        }
        
        log("📤 [전송] \(message)")
        webSocketTask.send(.string(message)) { [weak self] error in
            if let error = error {
                self?.log("❌ 전송 실패: \(error.localizedDescription)")
            } else {
                self?.log("✅ 전송 성공")
            }
        }
    }

    private func sendSocketIOEvent<T: Codable>(_ eventName: String, data: T) {
        guard socketIOConnected, state == .open else {
            log("⚠️ Socket.IO 미연결 - 이벤트 전송 실패: \(eventName) (connected=\(socketIOConnected), state=\(state))")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(data)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
            let eventArray: [Any] = [eventName, jsonObject]
            let eventData = try JSONSerialization.data(withJSONObject: eventArray)
            let eventString = String(data: eventData, encoding: .utf8)!
            
            // 네임스페이스 포함해서 전송
            let payload = "42\(namespace),\(eventString)"
            
            log("📤 [이벤트 전송] \(eventName)")
            log("📤 [페이로드] \(payload)")
            sendSocketIOMessage(payload)
        } catch {
            log("❌ 이벤트 직렬화 실패 (\(eventName)): \(error)")
        }
    }

    // MARK: - Event Handlers
    private func handleConnectedEvent(_ data: [String: Any]) {
        guard let message = data["message"] as? String,
              let userUuid = data["userUuid"] as? String else {
            log("❌ connected 이벤트 파싱 실패: \(data)")
            return
        }
        let event = ConnectedEvent(message: message, userUuid: userUuid)
        DispatchQueue.main.async {
            self.currentUserUuid = userUuid
        }
        onConnected?(event)
        log("✅ 서버 인증 완료: \(userUuid)")
    }

    private func handleJoinRoomEvent(_ data: [String: Any]) {
        guard let roomUuid = data["roomUuid"] as? String else {
            log("❌ joinRoom 이벤트 파싱 실패: \(data)")
            return
        }
        onJoinedRoom?(roomUuid)
        log("🏠 채팅방 입장 완료: \(roomUuid)")
    }

    private func handleLeftRoomEvent(_ data: [String: Any]) {
        guard let roomUuid = data["roomUuid"] as? String else { return }
        onLeftRoom?(roomUuid)
        log("🚪 채팅방 나감: \(roomUuid)")
    }

    private func handleNewMessageEvent(_ data: [String: Any]) {
        log("📨 [새 메시지] 원시 데이터: \(data)")
        
        // 직접 파싱 시도
        if let id = data["id"] as? Int,
           let roomUuid = data["roomUuid"] as? String,
           let senderUuid = data["senderUuid"] as? String,
           let senderNickname = data["senderNickname"] as? String,
           let type = data["type"] as? String,
           let content = data["content"] as? String,
           let createdAt = data["createdAt"] as? String,
           let isRead = data["isRead"] as? Bool {

            let sender = Sender(userUuid: senderUuid, nickname: senderNickname, profileImage: data["senderProfileImage"] as? String)
            let message = ChatMessage(
                id: id,
                roomUuid: roomUuid,
                type: type,
                content: content,
                imageUrl: data["imageUrl"] as? String,
                sender: sender,
                isRead: isRead,
                readByUuids: data["readByUuids"] as? [String] ?? [],
                isMyMessage: senderUuid == currentUserUuid,
                createdAt: createdAt
            )
            onNewMessage?(message)
            log("✅ 새 메시지 파싱 성공: \(content)")
        } else {
            // 기존 구조로 시도
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let message = try JSONDecoder().decode(ChatMessage.self, from: jsonData)
                onNewMessage?(message)
                log("✅ 새 메시지 파싱 성공 (기존): \(message.content)")
            } catch {
                log("❌ newMessage 파싱 실패: \(error)")
                log("❌ 실패 데이터: \(data)")
            }
        }
    }

    private func handleSystemMessageEvent(_ data: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let systemMessage = try JSONDecoder().decode(SystemMessage.self, from: jsonData)
            onSystemMessage?(systemMessage)
            log("🔔 시스템 메시지: \(systemMessage.message)")
        } catch {
            log("❌ systemMessage 파싱 실패: \(error)")
        }
    }

    private func handleMessagesReadEvent(_ data: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let event = try JSONDecoder().decode(MessagesReadEvent.self, from: jsonData)
            onMessagesRead?(event)
            log("👁️ 메시지 읽음: \(event.userUuid)")
        } catch {
            log("❌ messagesRead 파싱 실패: \(error)")
        }
    }

    private func handleUserTypingEvent(_ data: [String: Any]) {
        // 직접 파싱으로 시도 (nickname이 없을 수 있음)
        if let roomUuid = data["roomUuid"] as? String,
           let userUuid = data["userUuid"] as? String,
           let isTyping = data["isTyping"] as? Bool {
            
            // nickname이 없으면 기본값 사용
            let nickname = data["nickname"] as? String ?? "사용자"
            
            let event = UserTypingEvent(
                roomUuid: roomUuid,
                userUuid: userUuid,
                nickname: nickname,
                isTyping: isTyping
            )
            
            log("⌨️ 타이핑 상태 전달: \(nickname) - \(isTyping)")
            onUserTyping?(event)  // ViewModel로 전달
            
        } else {
            log("❌ userTyping 필수 필드 누락: \(data)")
        }
    }

    private func handleErrorEvent(_ data: [String: Any]) {
        let msg = data["message"] as? String ?? "알 수 없는 서버 에러"
        let detail = data["error"] as? String
        onError?(ErrorEvent(message: msg, error: detail))
        log("❌ 서버 에러: \(msg)")
        if let d = detail { log("❌ 상세: \(d)") }
    }

    private func handleReconnectEvent() {
        onReconnected?()
        log("🔄 재연결 완료")
    }
}

    // MARK: - URLSessionWebSocketDelegate
extension ChatWebSocket: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol `protocol`: String?) {
        log("✅ WebSocket 연결 열림")
    }

    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {
        log("📴 WebSocket 연결 닫힘 - 코드: \(closeCode.rawValue)")
        DispatchQueue.main.async {
            self.isConnected = false
            self.socketIOConnected = false
        }
        if self.state != .closing { self.state = .closed }
        if self.retryCount < self.maxRetries { self.reconnect() }
    }

    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if allowInsecureConnections, let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            log("⚠️ SSL 검증 우회: \(challenge.protectionSpace.host)")
            return
        }
        completionHandler(.performDefaultHandling, nil)
    }
}
