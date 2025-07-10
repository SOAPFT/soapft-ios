//
//  NotificationsService.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/8/25.
//

import Foundation
import Moya

final class NotificationService {
    
    static let shared = NotificationService()
    private let provider = MoyaProvider<NotificationAPI>()
    
    init() {}
    
    // MARK: - 알림 생성
    func createNotification(
        recipientUuid: String,
        senderUuid: String,
        type: String,
        title: String,
        content: String,
        data: [String: Any],
        accessToken: String,
        completion: @escaping (Result<NotificationDTO, Error>) -> Void
    ) {
        provider.request(.createNotification(
            recipientUuid: recipientUuid,
            senderUuid: senderUuid,
            type: type,
            title: title,
            content: content,
            data: data,
            accessToken: accessToken
        )) { result in
            self.handleResponse(result, ofType: NotificationDTO.self, completion: completion)
        }
    }
    
    // MARK: - 알림 목록 조회
    func fetchNotifications(
        page: Int,
        limit: Int,
        unreadOnly: Bool,
        accessToken: String,
        completion: @escaping (Result<NotificationsResponseDTO, Error>) -> Void
    ) {
        provider.request(.fetchNotifications(page: page, limit: limit, unreadOnly: unreadOnly, accessToken: accessToken)) { result in
            self.handleResponse(result, ofType: NotificationsResponseDTO.self, completion: completion)
        }
    }
    
    // MARK: - 미읽음 알림 개수 조회
    func fetchUnreadCount(
        accessToken: String,
        completion: @escaping (Result<UnreadCountResponseDTO, Error>) -> Void
    ) {
        provider.request(.fetchUnreadCount(accessToken: accessToken)) { result in
            self.handleResponse(result, ofType: UnreadCountResponseDTO.self, completion: completion)
        }
    }
    
    // MARK: - 특정 알림 읽음 처리
    func markAsRead(
        notificationIds: [Int],
        accessToken: String,
        completion: @escaping (Result<MarkReadResponseDTO, Error>) -> Void
    ) {
        provider.request(.markAsRead(notificationIds: notificationIds, accessToken: accessToken)) { result in
            self.handleResponse(result, ofType: MarkReadResponseDTO.self, completion: completion)
        }
    }
    
    // MARK: - 전체 알림 읽음 처리
    func markAllAsRead(
        notificationIds: [Int],
        accessToken: String,
        completion: @escaping (Result<MarkReadResponseDTO, Error>) -> Void
    ) {
        provider.request(.markAllAsRead(notificationIds: notificationIds, accessToken: accessToken)) { result in
            self.handleResponse(result, ofType: MarkReadResponseDTO.self, completion: completion)
        }
    }
    
    // MARK: - 알림 삭제
    func deleteNotification(
        id: Int,
        accessToken: String,
        completion: @escaping (Result<DeleteNotificationResponseDTO, Error>) -> Void
    ) {
        provider.request(.deleteNotification(id: id, accessToken: accessToken)) { result in
            self.handleResponse(result, ofType: DeleteNotificationResponseDTO.self, completion: completion)
        }
    }
    
    // MARK: - 공통 응답 처리
    private func handleResponse<T: Decodable>(
        _ result: Result<Response, MoyaError>,
        ofType type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        switch result {
        case .success(let response):
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: response.data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
