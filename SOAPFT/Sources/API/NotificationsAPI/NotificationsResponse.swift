//
//  NotificationsResponse.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/7/25.
//

import Foundation

// MARK: - 알림 모델 (알림 생성 및 알림 목록 조회에 공통 사용)
struct NotificationDTO: Decodable, Identifiable {
    let id: Int
    let recipientUuid: String
    let senderUuid: String
    let type: String
    let title: String
    let content: String
    let data: NotificationData
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
