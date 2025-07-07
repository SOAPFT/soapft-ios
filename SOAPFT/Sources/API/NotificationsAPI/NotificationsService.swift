//
//  NotificationsService.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/8/25.
//

import Foundation

final class NotificationService {
    private let networkManager = DefaultNetworkManager<NotificationAPI>()

    // MARK: - 알림 생성
    func createNotification(
        recipientUuid: String,
        senderUuid: String,
        type: String,
        title: String,
        content: String,
        data: [String: Any],
        accessToken: String,
        completion: @escaping (Result<NotificationDTO, NetworkError>) -> Void
    ) {
        let target = NotificationAPI.createNotification(
            recipientUuid: recipientUuid,
            senderUuid: senderUuid,
            type: type,
            title: title,
            content: content,
            data: data,
            accessToken: accessToken
        )
        networkManager.request(target: target, decodingType: NotificationDTO.self, completion: completion)
    }

    // MARK: - 알림 목록 조회
    func fetchNotifications(
        page: Int,
        limit: Int,
        unreadOnly: Bool,
        accessToken: String,
        completion: @escaping (Result<NotificationsResponseDTO, NetworkError>) -> Void
    ) {
        let target = NotificationAPI.fetchNotifications(page: page, limit: limit, unreadOnly: unreadOnly, accessToken: accessToken)
        networkManager.request(target: target, decodingType: NotificationsResponseDTO.self, completion: completion)
    }

    // MARK: - 미읽음 알림 개수 조회
    func fetchUnreadCount(
        accessToken: String,
        completion: @escaping (Result<UnreadCountResponseDTO, NetworkError>) -> Void
    ) {
        let target = NotificationAPI.fetchUnreadCount(accessToken: accessToken)
        networkManager.request(target: target, decodingType: UnreadCountResponseDTO.self, completion: completion)
    }

    // MARK: - 알림 읽음 처리 (단일 또는 복수)
    func markAsRead(
        notificationIds: [Int],
        accessToken: String,
        completion: @escaping (Result<MarkReadResponseDTO, NetworkError>) -> Void
    ) {
        let target = NotificationAPI.markAsRead(notificationIds: notificationIds, accessToken: accessToken)
        networkManager.request(target: target, decodingType: MarkReadResponseDTO.self, completion: completion)
    }

    // MARK: - 모든 알림 읽음 처리
    func markAllAsRead(
        notificationIds: [Int],
        accessToken: String,
        completion: @escaping (Result<MarkReadResponseDTO, NetworkError>) -> Void
    ) {
        let target = NotificationAPI.markAllAsRead(notificationIds: notificationIds, accessToken: accessToken)
        networkManager.request(target: target, decodingType: MarkReadResponseDTO.self, completion: completion)
    }

    // MARK: - 알림 삭제
    func deleteNotification(
        id: Int,
        accessToken: String,
        completion: @escaping (Result<DeleteNotificationResponseDTO, NetworkError>) -> Void
    ) {
        let target = NotificationAPI.deleteNotification(id: id, accessToken: accessToken)
        networkManager.request(target: target, decodingType: DeleteNotificationResponseDTO.self, completion: completion)
    }
}

