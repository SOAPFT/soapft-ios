//
//  ChatModel.swift
//  SOAPFT
//
//  Created by 바견규 on 6/28/25.
//

import Foundation

struct ChatMessageListDTO: Codable {
    let messages: [ChatMessageDTO]
    let pagination: PaginationDTO
}

struct ChatMessageDTO: Codable {
    let id: Int
    let content: String
    let type: String          // e.g., "TEXT", "IMAGE"
    let imageUrl: String?     // 이미지 메시지일 경우
    let sender: SenderDTO
    let replyTo: ReplyToDTO?
    let readByUuids: [String]
    let isEdited: Bool
    let isDeleted: Bool
    let sentAt: Date
    let editedAt: Date?
}

struct SenderDTO: Codable {
    let userUuid: String
    let nickname: String
    let profileImage: String?
}

struct ReplyToDTO: Codable {
    let messageId: Int
    let content: String
    let sender: ReplySenderDTO
}

struct ReplySenderDTO: Codable {
    let userUuid: String
    let nickname: String
}

struct PaginationDTO: Codable {
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let itemsPerPage: Int
    let hasNext: Bool
}

