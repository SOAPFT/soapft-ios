//
//  LikeAPI.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/7/25.
//

import Foundation
import Moya

enum LikeAPI {
    case like(postId: String, accessToken: String)
    case unlike(postId: String, accessToken: String)
    case checkLikeStatus(postId: String, accessToken: String)
}

extension LikeAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://13.125.191.87:7777/api/like")!
    }

    var path: String {
        switch self {
        case .like(let postId, _), .unlike(let postId, _):
            return "/\(postId)"
        case .checkLikeStatus(let postId, _):
            return "/check/\(postId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .like:
            return .post
        case .unlike:
            return .delete
        case .checkLikeStatus:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .like, .unlike, .checkLikeStatus:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
        var headers: [String: String] = [
            "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            "accept": "application/json",
        ]

        switch self {
        case .like(_, let accessToken),
             .unlike(_, let accessToken),
             .checkLikeStatus(_, let accessToken):
            headers["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyVXVpZCI6IjAxSllLVk4xOE1DVzVCOUZaMVBQN1QxNFhTIiwiaWF0IjoxNzUxOTAzNDA0LCJleHAiOjE3NTQ0OTU0MDR9.eeETUYLQy_W14flyNrvkSkJQm4CfqfsbrtfN7dOssl8"
            headers["Content-Type"] = "application/json"
        }

        return headers
    }

    var sampleData: Data {
        return Data()
    }
}
