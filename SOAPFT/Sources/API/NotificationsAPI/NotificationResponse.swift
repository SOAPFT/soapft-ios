//
//  NotificationsResponse.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/7/25.
//

import Foundation
 
enum JSONValue: Codable {
    case string(String), int(Int), double(Double), bool(Bool)
    case object([String: JSONValue]), array([JSONValue]), null
    
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .null }
        else if let v = try? c.decode(Bool.self) { self = .bool(v) }
        else if let v = try? c.decode(Int.self) { self = .int(v) }
        else if let v = try? c.decode(Double.self) { self = .double(v) }
        else if let v = try? c.decode(String.self) { self = .string(v) }
        else if let v = try? c.decode([String: JSONValue].self) { self = .object(v) }
        else if let v = try? c.decode([JSONValue].self) { self = .array(v) }
        else { throw DecodingError.typeMismatch(JSONValue.self, .init(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON type")) }
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .null: try c.encodeNil()
        case .bool(let v): try c.encode(v)
        case .int(let v): try c.encode(v)
        case .double(let v): try c.encode(v)
        case .string(let v): try c.encode(v)
        case .object(let v): try c.encode(v)
        case .array(let v): try c.encode(v)
        }
    }
}

// MARK: - 알림 모델 (알림 생성 및 알림 목록 조회에 공통 사용)
struct NotificationDTO: Decodable, Identifiable {
    let id: Int
    let recipientUuid: String
    let senderUuid: String?
    let type: String
    let title: String
    let content: String
    let data: [String: JSONValue]?
    let isRead: Bool
    let isSent: Bool
    let createdAt: String
    let updatedAt: String
}

struct NotificationData: Decodable {
    let friendRequestId: Int
}

// MARK: - 알림 목록 조회 응답
struct NotificationsResponseDTO: Decodable {
    let notifications: [NotificationDTO]
    let pagination: Pagination
    let unreadCount: Int
}

// MARK: - 미읽음 알림 개수 조회
struct UnreadCountResponseDTO: Decodable {
    let unreadCount: Int
}

// MARK: - 알림 읽음 처리 (단일 및 전체 공용)
struct MarkReadResponseDTO: Decodable {
    let success: Bool
    let message: String
}

// MARK: - 알림 삭제
struct DeleteNotificationResponseDTO: Decodable {
    let success: Bool
    let message: String
}
