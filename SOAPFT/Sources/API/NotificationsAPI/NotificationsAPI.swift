//
//  NotificationsAPI.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/7/25.
//

import Foundation
import Moya

enum NotificationAPI {
    case createNotification(
        recipientUuid: String,
        senderUuid: String,
        type: String,
        title: String,
        content: String,
        data: [String: Any],
        accessToken: String
    )
    case fetchNotifications(page: Int, limit: Int, unreadOnly: Bool, accessToken: String)
    case fetchUnreadCount(accessToken: String)
    case markAsRead(notificationIds: [Int], accessToken: String)
    case markAllAsRead(notificationIds: [Int], accessToken: String)
    case deleteNotification(id: Int, accessToken: String)
}

extension NotificationAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://13.125.191.87:7777/api/notifications")!
    }

    var path: String {
        switch self {
        case .fetchUnreadCount:
            return "/unread-count"
        case .markAsRead:
            return "/mark-as-read"
        case .markAllAsRead:
            return "/mark-all-as-read"
        case .deleteNotification(let id, _):
            return "/\(id)"
        default:
            return ""
        }
    }

    var method: Moya.Method {
        switch self {
        case .createNotification:
            return .post
        case .fetchNotifications, .fetchUnreadCount:
            return .get
        case .markAsRead, .markAllAsRead:
            return .patch
        case .deleteNotification:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case let .createNotification(recipientUuid, senderUuid, type, title, content, data, _):
            let params: [String: Any] = [
                "recipientUuid": recipientUuid,
                "senderUuid": senderUuid,
                "type": type,
                "title": title,
                "content": content,
                "data": data
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case let .fetchNotifications(page, limit, unreadOnly, _):
            let params: [String: Any] = [
                "page": page,
                "limit": limit,
                "unreadOnly": unreadOnly
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)

        case let .markAsRead(notificationIds, _),
             let .markAllAsRead(notificationIds, _):
            let params = ["notificationIds": notificationIds]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case .fetchUnreadCount, .deleteNotification:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
        var headers: [String: String] = [
            "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            "accept": "application/json"
        ]

        switch self {
        case let .createNotification(_, _, _, _, _, _, accessToken),
             let .fetchNotifications(_, _, _, accessToken),
             let .fetchUnreadCount(accessToken),
             let .markAsRead(_, accessToken),
             let .markAllAsRead(_, accessToken),
             let .deleteNotification(_, accessToken):
            headers["Authorization"] = "Bearer \(accessToken)"
            headers["Content-Type"] = "application/json"
        }

        return headers
    }

    var sampleData: Data {
        return Data()
    }
}
