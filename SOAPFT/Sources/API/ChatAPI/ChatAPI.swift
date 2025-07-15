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
    case getRooms(type: String?, page: Int, limit: Int)
    case getRoomDetail(uuid: String)
    case sendMessage(roomId: String, content: String, type: String, imageUrl: String?, replyTo: Int?)
    case getMessages(roomId: String, page: Int, limit: Int, lastMessageId: Int?, beforeMessageId: Int?)
    case markAsRead(roomId: String, lastReadMessageId: Int)
    case leaveRoom(roomId: String)
}

extension ChatAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("❌ API_URL not found or invalid in Info.plist")
        }
        return url
    }
    

    var path: String {
        switch self {
        case .createRoom:
            return "/api/chat/room"
        case .getRooms:
            return "/api/chat/rooms"
        case let .getRoomDetail(uuid):
            return "/api/chat/room/\(uuid)"
        case let .sendMessage(roomId, _, _, _, _):
            return "/api/chat/room/\(roomId)/message"
        case let .getMessages(roomId, _, _, _, _):
            return "/api/chat/room/\(roomId)/messages"
        case let .markAsRead(roomId, _):
            return "/api/chat/room/\(roomId)/read"
        case let .leaveRoom(roomId):
            return "/api/chat/room/\(roomId)/leave"
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
            var params: [String: Any] = [
                "page": page,
                "limit": limit
            ]
            // type이 nil이면 아예 쿼리 파라미터에 포함 안 됨
            if let type = type {
                params["type"] = type
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

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

    var headers: [String : String]? {
            var headers: [String: String] = [
                "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
                "accept": "application/json",
                "Content-Type": "application/json"
            ]

            if let accessToken = KeyChainManager.shared.readAccessToken() {
                headers["Authorization"] = "Bearer \(accessToken)"
            } else {
                print("❌ accessToken 없음: 인증이 필요한 요청입니다.")
            }

            return headers
        }

    var sampleData: Data {
        return Data()
    }
}
