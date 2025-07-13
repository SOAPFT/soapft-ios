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
    case acceptRequest(friendId: String)
    case rejectRequest(friendId: String)
    case deleteFriend(friendId: String)
    case friendList
    case receivedRequests
    case sentRequests
    case searchFriend(keyword: String)
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
            return "/api/friendship/list"
        case .receivedRequests:
            return "/api/friendship/received-requests"
        case .sentRequests:
            return "/api/friendship/sent-requests"
        case .searchFriend:
            return "/api/friendship/friends/search"
        }
    }

    var method: Moya.Method {
        switch self {
        case .sendRequest,
             .acceptRequest,
             .rejectRequest:
//             .friendList:
            return .post
        case .deleteFriend:
            return .delete
        case .receivedRequests, .sentRequests, .friendList, .searchFriend:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .sendRequest(let addresseeUuid):
            return .requestParameters(parameters: ["addresseeUuid": addresseeUuid], encoding: JSONEncoding.default)
        case .searchFriend(let keyword):
            return .requestParameters(parameters: ["keyword": keyword], encoding: URLEncoding.default)
        case .friendList:
            return .requestPlain
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var defaultHeaders: [String: String] = [
            "accept": "application/json",
            "Content-Type": "application/json"
        ]

        if let accessToken = KeyChainManager.shared.read(forKey: "accessToken") {
            defaultHeaders["Authorization"] = "Bearer \(accessToken)"
        }

        return defaultHeaders
    }

    var sampleData: Data {
        return Data()
    }
}
