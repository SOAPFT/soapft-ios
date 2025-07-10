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
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("❌ API_URL not found or invalid in Info.plist")
        }
        return url
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
            "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyVXVpZCI6IjAxSllLVk4xOE1DVzVCOUZaMVBQN1QxNFhTIiwiaWF0IjoxNzUxOTAyODUwLCJleHAiOjE3NTQ0OTQ4NTB9.AWkWZKZ2BcV4w2uubt2pbvcnh00pFLiiGgrkp2J7qwg"
        ]
    }

    var sampleData: Data {
        return Data()
    }
}
