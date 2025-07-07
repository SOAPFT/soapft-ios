//
//  PostAPI.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/7/25.
//

import Foundation
import Moya

enum PostAPI {
    case createPost(title: String, challengeUuid: String, content: String, imageUrls: [String], isPublic: Bool)
    case getMyPosts(page: Int, limit: Int)
    case getCalendar(year: Int, month: Int)
    case getUserCalendar(userUuid: String, year: Int, month: Int)
    case getUserPosts(userId: Int, page: Int, limit: Int)
    case getPostDetail(postId: Int)
    case updatePost(postUuid: String, title: String, content: String, imageUrls: [String], isPublic: Bool)
    case deletePost(postId: Int)
    case getChallengePosts(challengeId: Int, page: Int, limit: Int)
}

extension PostAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://13.125.191.87:7777/api")!
    }

    var path: String {
        switch self {
        case .createPost:
            return "/post"
        case .getMyPosts:
            return "/post/my"
        case .getCalendar:
            return "/post/calendar"
        case .getUserCalendar(let userUuid, _, _):
            return "/post/calendar/\(userUuid)"
        case .getUserPosts(let userId, _, _):
            return "/post/user/\(userId)"
        case .getPostDetail(let postId):
            return "/post/\(postId)"
        case .updatePost(let postUuid, _, _, _, _):
            return "/post/\(postUuid)"
        case .deletePost(let postId):
            return "/post/\(postId)"
        case .getChallengePosts(let challengeId, _, _):
            return "/post/challenge/\(challengeId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .createPost:
            return .post
        case .updatePost:
            return .patch
        case .deletePost:
            return .delete
        default:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .createPost(title, challengeUuid, content, imageUrls, isPublic):
            let params: [String: Any] = [
                "title": title,
                "challengeUuid": challengeUuid,
                "content": content,
                "imageUrl": imageUrls,
                "isPublic": isPublic
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case let .getMyPosts(page, limit),
             let .getUserPosts(_, page, limit),
             let .getChallengePosts(_, page, limit):
            return .requestParameters(parameters: ["page": page, "limit": limit], encoding: URLEncoding.default)

        case let .getCalendar(year, month),
             let .getUserCalendar(_, year, month):
            return .requestParameters(parameters: ["year": year, "month": month], encoding: URLEncoding.default)

        case .getPostDetail, .deletePost:
            return .requestPlain

        case let .updatePost(_, title, content, imageUrls, isPublic):
            let params: [String: Any] = [
                "title": title,
                "content": content,
                "imageUrl": imageUrls,
                "isPublic": isPublic
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? {
        var commonHeaders: [String: String] = [
            "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyVXVpZCI6IjAxSllLVk4xOE1DVzVCOUZaMVBQN1QxNFhTIiwiaWF0IjoxNzUxOTAzNDA0LCJleHAiOjE3NTQ0OTU0MDR9.eeETUYLQy_W14flyNrvkSkJQm4CfqfsbrtfN7dOssl8",
            "accept": "application/json"
        ]

        switch self {
        case .createPost, .updatePost:
            commonHeaders["Content-Type"] = "application/json"
        default:
            break
        }

        return commonHeaders
    }
}
