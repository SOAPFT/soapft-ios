//
//  ChatResponse.swift
//  SOAPFT
//
//  Created by 바견규 on 7/7/25.
//

import Foundation

//MARK: - 공통 구조
struct Sender: Decodable {
    let userUuid: String
    let nickname: String
    let profileImage: String?
}

struct ReplyTo: Decodable {
    let messageId: Int
    let content: String
    let sender: Sender
}

struct Pagination2: Decodable {
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let itemsPerPage: Int
    let hasNext: Bool?
}

//MARK: - 채팅방 생성 응답
struct ChatRoomCreationResponse: Decodable {
    let roomUuid: String
    let type: String
    let name: String
    let participantUuids: [String]
    let challengeUuid: String
    let lastMessage: ChatRoomLastMessage?
    let lastMessageAt: String?
    let unreadCount: Int
    let createdAt: String
}

//MARK: - 채팅방 목록 응답
struct ChatRoomListResponse: Decodable {
    let chatRooms: [ChatRoom]
    let pagination: Pagination
}

struct ChatRoom: Decodable {
    let roomUuid: String
    let type: String
    let name: String
    let participants: [ChatParticipant]
    let challengeUuid: String
    let lastMessage: ChatRoomLastMessage?
    let lastMessageAt: String?
    let unreadCount: Int
    let createdAt: String
}

struct ChatRoomLastMessage: Decodable {
    let id: Int
    let type: String
    let content: String
    let senderUuid: String
    let createdAt: String
}

struct ChatParticipant: Decodable {
    let userUuid: String
    let nickname: String
    let profileImage: String?   
}

struct ChatChallenge: Decodable {
    let challengeUuid: String
    let title: String
}


//MARK: - 채팅방 상세 응답
struct ChatRoomDetailResponse: Decodable {
    let roomUuid: String
    let type: String
    let name: String
    let participants: [ChatParticipantDetail]
    let challenge: ChatChallengeDetail
    let myRole: String
    let settings: ChatRoomSettings
    let createdAt: String
    let updatedAt: String
}

struct ChatParticipantDetail: Decodable {
    let userUuid: String
    let nickname: String
    let profileImage: String
    let isOnline: Bool
    let lastSeenAt: String
    let joinedAt: String
}

struct ChatChallengeDetail: Decodable {
    let challengeUuid: String
    let title: String
    let isActive: Bool
}

struct ChatRoomSettings: Decodable {
    let isPinned: Bool
    let isMuted: Bool
    let notificationEnabled: Bool
}


//MARK: - 메시지 전송/조회 응답
struct ChatMessage: Decodable {
    let id: Int
    let roomUuid: String?
    let type: String
    let content: String
    let imageUrl: String?
    let sender: Sender
    let isRead: Bool
    let readByUuids: [String]
    let isMyMessage: Bool
    let createdAt: String // 또는 Date (추가 설명 아래 참고)
}

struct ChatMessageListResponse: Decodable {
    let messages: [ChatMessage]
    let pagination: ChatPagination
}

struct ChatPagination: Decodable {
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let itemsPerPage: Int
    let hasNext: Bool?
}


//MARK: - 메시지 읽음 처리 응답
struct MessageReadResponse: Decodable {
    let lastReadMessageId: Int
}

//MARK: - 채팅방 나가기 응답
struct ChatRoomLeaveResponse: Decodable {
    let message: String
}
