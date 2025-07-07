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
    let lastMessage: ChatMessage?
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
    let challenge: ChatChallenge?
    let lastMessage: ChatMessage?
    let unreadCount: Int
    let isPinned: Bool
    let isMuted: Bool
    let createdAt: String
    let updatedAt: String
}

struct ChatParticipant: Decodable {
    let userUuid: String
    let nickname: String
    let profileImage: String
    let isOnline: Bool
    let lastSeenAt: String
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
    let content: String
    let type: String
    let imageUrl: String?
    let sender: Sender
    let replyTo: ReplyTo?
    let readByUuids: [String]
    let sentAt: String
    let isEdited: Bool?
    let isDeleted: Bool?
    let editedAt: String?
}

struct ChatMessageListResponse: Decodable {
    let messages: [ChatMessage]
    let pagination: Pagination
}


//MARK: - 메시지 읽음 처리 응답
struct MessageReadResponse: Decodable {
    let lastReadMessageId: Int
}

//MARK: - 채팅방 나가기 응답
struct ChatRoomLeaveResponse: Decodable {
    let message: String
}
