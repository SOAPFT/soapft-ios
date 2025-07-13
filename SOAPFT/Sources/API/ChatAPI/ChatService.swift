//
//  ChatService.swift
//  SOAPFT
//
//  Created by 바견규 on 7/10/25.
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

    // MARK: - 메시지 전송
    func sendMessage(roomId: String, content: String, type: String, imageUrl: String? = nil, replyTo: Int? = nil, completion: @escaping (Result<ChatMessage, Error>) -> Void) {
        provider.request(.sendMessage(roomId: roomId, content: content, type: type, imageUrl: imageUrl, replyTo: replyTo)) { result in
            self.handleResponse(result, type: ChatMessage.self, completion: completion)
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
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
