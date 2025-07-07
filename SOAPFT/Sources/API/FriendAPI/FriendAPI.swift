//
//  FriendAPI.swift
//  SOAPFT
//
//  Created by 바견규 on 7/7/25.
//

import Moya
import Foundation

enum FriendAPI {
    case sendRequest(addresseeUuid: String)
    case acceptRequest(requestId: String)
    case rejectRequest(requestId: String)
    case deleteFriend(friendId: String)
    case friendList(parameters: [String: Any])
    case receivedRequests
    case sentRequests
}

extension FriendAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://13.125.191.87:7777")!
    }

    var path: String {
        switch self {
        case .sendRequest:
            return "/api/friendship/request"
        case .acceptRequest(let requestId):
            return "/api/friendship/accept/\(requestId)"
        case .rejectRequest(let requestId):
            return "/api/friendship/reject/\(requestId)"
        case .deleteFriend(let friendId):
            return "/api/friendship/\(friendId)"
        case .friendList:
            return "/api/auth/kakao"
        case .receivedRequests:
            return "/api/friendship/received-requests"
        case .sentRequests:
            return "/api/friendship/sent-requests"
        }
    }

    var method: Moya.Method {
        switch self {
        case .sendRequest,
             .acceptRequest,
             .rejectRequest,
             .friendList:
            return .post
        case .deleteFriend:
            return .delete
        case .receivedRequests, .sentRequests:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .sendRequest(let addresseeUuid):
            return .requestParameters(parameters: ["addresseeUuid": addresseeUuid], encoding: JSONEncoding.default)
        case .friendList(let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return [
            "accept": "application/json",
            "Content-Type": "application/json",
            "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7"
        ]
    }

    var sampleData: Data {
        return Data()
    }
}
