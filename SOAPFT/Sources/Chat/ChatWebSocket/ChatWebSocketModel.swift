//
//  ChatWebSocketModel.swift
//  SOAPFT
//
//  Created by 바견규 on 8/9/25.
//

import Foundation

// MARK: - WebSocket Event Models

struct ConnectedEvent: Codable {
    let message: String
    let userUuid: String
}

struct JoinRoomRequest: Codable {
    let roomUuid: String
}

struct LeaveRoomRequest: Codable {
    let roomUuid: String
}

struct SendMessageRequest: Codable {
    let roomUuid: String
    let message: MessageRequest
    
    struct MessageRequest: Codable {
        let type: String
        let content: String
        let imageUrl: String?
    }
}

struct MarkAsReadRequest: Codable {
    let roomUuid: String
}

struct TypingRequest: Codable {
    let roomUuid: String
    let isTyping: Bool
}

struct MessagesReadEvent: Codable {
    let roomUuid: String
    let userUuid: String
    let timestamp: String
}

struct UserTypingEvent: Codable {
    let roomUuid: String
    let userUuid: String
    let nickname: String?  // 옵셔널로 변경
    let isTyping: Bool
}

struct ErrorEvent: Codable {
    let message: String
    let error: String?
}

struct SystemMessage: Codable {
    let roomUuid: String
    let message: String
    let timestamp: String
}

struct TypingUser: Identifiable, Equatable {
    let id = UUID()
    let userUuid: String
    let nickname: String
    let roomUuid: String
}
