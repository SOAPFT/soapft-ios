//
//  ChatAPI.swift
//  SOAPFT
//
//  Created by 바견규 on 7/7/25.
//

import Foundation
import Moya

enum ChatAPI {
    case createRoom(type: String, participantUuids: [String], name: String, challengeUuid: String)
    case getRooms(type: String, page: Int, limit: Int)
    case getRoomDetail(uuid: String)
    case sendMessage(roomId: String, content: String, type: String, imageUrl: String?, replyTo: Int?)
    case getMessages(roomId: String, page: Int, limit: Int, lastMessageId: Int?, beforeMessageId: Int?)
    case markAsRead(roomId: String, lastReadMessageId: Int)
    case leaveRoom(roomId: String)
}

extension ChatAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://xxx/api")!
    }

    var path: String {
        switch self {
        case .createRoom:
            return "/chat/room"
        case .getRooms:
            return "/chat/rooms"
        case let .getRoomDetail(uuid):
            return "/chat/room/\(uuid)"
        case let .sendMessage(roomId, _, _, _, _):
            return "/chat/room/\(roomId)/message"
        case let .getMessages(roomId, _, _, _, _):
            return "/chat/room/\(roomId)/messages"
        case let .markAsRead(roomId, _):
            return "/chat/room/\(roomId)/read"
        case let .leaveRoom(roomId):
            return "/chat/room/\(roomId)/leave"
        }
    }

    var method: Moya.Method {
        switch self {
        case .createRoom, .sendMessage:
            return .post
        case .getRooms, .getRoomDetail, .getMessages:
            return .get
        case .markAsRead:
            return .patch
        case .leaveRoom:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case let .createRoom(type, participantUuids, name, challengeUuid):
            return .requestParameters(parameters: [
                "type": type,
                "participantUuids": participantUuids,
                "name": name,
                "challengeUuid": challengeUuid
            ], encoding: JSONEncoding.default)

        case let .getRooms(type, page, limit):
            return .requestParameters(parameters: [
                "type": type,
                "page": page,
                "limit": limit
            ], encoding: URLEncoding.queryString)

        case .getRoomDetail:
            return .requestPlain

        case let .sendMessage(_, content, type, imageUrl, replyTo):
            var params: [String: Any] = [
                "content": content,
                "type": type
            ]
            if let imageUrl = imageUrl {
                params["imageUrl"] = imageUrl
            }
            if let replyTo = replyTo {
                params["replyToMessageId"] = replyTo
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case let .getMessages(_, page, limit, lastMessageId, beforeMessageId):
            var params: [String: Any] = [
                "page": page,
                "limit": limit
            ]
            if let last = lastMessageId {
                params["lastMessageId"] = last
            }
            if let before = beforeMessageId {
                params["beforeMessageId"] = before
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case let .markAsRead(_, lastReadMessageId):
            return .requestParameters(parameters: [
                "lastReadMessageId": lastReadMessageId
            ], encoding: JSONEncoding.default)

        case .leaveRoom:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "accept": "application/json",
            "Accept-Language": "ko-KR",
            "User-Agent": "iOS-App"
        ]
    }

    var sampleData: Data {
        return Data()
    }
}
