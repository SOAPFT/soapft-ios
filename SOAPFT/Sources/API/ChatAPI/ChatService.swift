//
//  ChatService.swift
//  SOAPFT
//
//  Created by 바견규 on 7/10/25.
//
//


import Foundation
import Moya

final class ChatService {
    private let provider = MoyaProvider<ChatAPI>()

    // MARK: - 채팅방 생성
    func createRoom(type: String, participantUuids: [String], name: String, challengeUuid: String, completion: @escaping (Result<ChatRoomCreationResponse, Error>) -> Void) {
        provider.request(.createRoom(type: type, participantUuids: participantUuids, name: name, challengeUuid: challengeUuid)) { result in
            self.handleResponse(result, type: ChatRoomCreationResponse.self, completion: completion)
        }
    }

    // MARK: - 채팅방 목록
    func getRooms(type: String?, page: Int, limit: Int, completion: @escaping (Result<ChatRoomListResponse, Error>) -> Void) {
        provider.request(.getRooms(type: type, page: page, limit: limit)) { result in
            self.handleResponse(result, type: ChatRoomListResponse.self, completion: completion)
        }
    }

    // MARK: - 채팅방 상세
    func getRoomDetail(uuid: String, completion: @escaping (Result<ChatRoomDetailResponse, Error>) -> Void) {
        provider.request(.getRoomDetail(uuid: uuid)) { result in
            self.handleResponse(result, type: ChatRoomDetailResponse.self, completion: completion)
        }
    }

    // MARK: - 메시지 목록 조회
    func getMessages(roomId: String, page: Int, limit: Int, lastMessageId: Int? = nil, beforeMessageId: Int? = nil, completion: @escaping (Result<ChatMessageListResponse, Error>) -> Void) {
        provider.request(.getMessages(roomId: roomId, page: page, limit: limit, lastMessageId: lastMessageId, beforeMessageId: beforeMessageId)) { (result: Result<Response, MoyaError>) in
            self.handleResponse(result, type: ChatMessageListResponse.self, completion: completion)
        }
    }

    // MARK: - 읽음 처리
    func markAsRead(roomId: String, lastReadMessageId: Int, completion: @escaping (Result<MessageReadResponse, Error>) -> Void) {
        provider.request(.markAsRead(roomId: roomId, lastReadMessageId: lastReadMessageId)) { result in
            self.handleResponse(result, type: MessageReadResponse.self, completion: completion)
        }
    }

    // MARK: - 채팅방 나가기
    func leaveRoom(roomId: String, completion: @escaping (Result<ChatRoomLeaveResponse, Error>) -> Void) {
        provider.request(.leaveRoom(roomId: roomId)) { result in
            self.handleResponse(result, type: ChatRoomLeaveResponse.self, completion: completion)
        }
    }

    // MARK: - 1:1 채팅방 찾기 또는 생성
    func sendDirectChat(userUuid: String, completion: @escaping (Result<SendDirectChatResponse, Error>) -> Void) {
        provider.request(.sendDirectChat(userUuid: userUuid)) { result in
            self.handleResponse(result, type: SendDirectChatResponse.self, completion: completion)
        }
    }

    // MARK: - 공통 응답 처리
    private func handleResponse<T: Decodable>(
        _ result: Result<Moya.Response, MoyaError>,
        type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        switch result {
        case .success(let response):
            do {
                let decoded = try JSONDecoder().decode(T.self, from: response.data)
                completion(.success(decoded))
            } catch {
                print("📦 Raw JSON Response:\n" + (String(data: response.data, encoding: .utf8) ?? "nil"))
                print("❌ Decoding Error: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            print("❌ Network Error: \(error)")
            completion(.failure(error))
        }
    }
    
    // MARK: - WebSocket 통합 채팅 서비스
    
    /// WebSocket 연결된 채팅 서비스 생성
    static func createWebSocketEnabledService(
        webSocketHost: String,
        webSocketPort: Int = 443
    ) -> (ChatService, ChatWebSocket) {
        let chatService = ChatService()
        let webSocket = ChatWebSocket(host: webSocketHost, port: webSocketPort)
        return (chatService, webSocket)
    }
    
    /// 채팅방 입장 (REST API만 사용)
    func enterRoom(
        roomId: String,
        completion: @escaping (Result<ChatRoomDetailResponse, Error>) -> Void
    ) {
        // REST API로 채팅방 정보 조회만 수행
        // WebSocket은 서버에서 자동으로 모든 채팅방에 join하므로 별도 처리 불필요
        getRoomDetail(uuid: roomId, completion: completion)
    }
    
    /// 채팅방 나가기 (REST API + WebSocket)
    func exitRoom(
        roomId: String,
        webSocket: ChatWebSocket?,
        completion: @escaping (Result<ChatRoomLeaveResponse, Error>) -> Void
    ) {
        // 1. WebSocket 채팅방 나가기 (선택적)
        webSocket?.leaveRoom(roomId)
        
        // 2. REST API로 채팅방 나가기
        leaveRoom(roomId: roomId, completion: completion)
    }
}
