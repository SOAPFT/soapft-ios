//
//  PostAPI.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/7/25.
//

import Foundation
import Moya

enum PostAPI {
    case createPost(title: String, challengeUuid: String, content: String, imageUrls: [String], isPublic: Bool, accessToken: String)
    case getMyPosts(page: Int, limit: Int, accessToken: String)
    case getCalendar(year: Int, month: Int, accessToken: String)
    case getUserCalendar(userUuid: String, year: Int, month: Int, accessToken: String)
    case getUserPosts(userId: Int, page: Int, limit: Int, accessToken: String)
    case getPostDetail(postId: Int, accessToken: String)
    case updatePost(postUuid: String, title: String, content: String, imageUrls: [String], isPublic: Bool, accessToken: String)
    case deletePost(postId: Int, accessToken: String)
    case getChallengePosts(challengeId: String, page: Int, limit: Int, accessToken: String)
}

extension PostAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("❌ API_URL not found or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .createPost:
            return "/api/post"
        case .getMyPosts:
            return "/api/post/my"
        case .getCalendar:
            return "/api/post/calendar"
        case .getUserCalendar(let userUuid, _, _, _):
            return "/api/post/calendar/\(userUuid)"
        case .getUserPosts(let userId, _, _, _):
            return "/api/post/user/\(userId)"
        case .getPostDetail(let postId, _):
            return "/api/post/\(postId)"
        case .updatePost(let postUuid, _, _, _, _, _):
            return "/api/post/\(postUuid)"
        case .deletePost(let postId, _):
            return "/api/post/\(postId)"
        case .getChallengePosts(let challengeId, _, _, _):
            return "/api/post/challenge/\(challengeId)"
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
        case let .createPost(title, challengeUuid, content, imageUrls, isPublic, _):
            let params: [String: Any] = [
                "title": title,
                "challengeUuid": challengeUuid,
                "content": content,
                "imageUrl": imageUrls,
                "isPublic": isPublic
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case let .getMyPosts(page, limit, _),
             let .getUserPosts(_, page, limit, _),
             let .getChallengePosts(_, page, limit, _):
            return .requestParameters(parameters: ["page": page, "limit": limit], encoding: URLEncoding.default)

        case let .getCalendar(year, month, _),
             let .getUserCalendar(_, year, month, _):
            return .requestParameters(parameters: ["year": year, "month": month], encoding: URLEncoding.default)

        case .getPostDetail, .deletePost:
            return .requestPlain

        case let .updatePost(_, title, content, imageUrls, isPublic, _):
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
        var baseHeaders: [String: String] = [
            "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            "accept": "application/json"
        ]
        
        // accessToken을 각 케이스에서 추출
        let token: String? = {
            switch self {
            case let .createPost(_, _, _, _, _, token),
                 let .getMyPosts(_, _, token),
                 let .getCalendar(_, _, token),
                 let .getUserCalendar(_, _, _, token),
                 let .getUserPosts(_, _, _, token),
                 let .getPostDetail(_, token),
                 let .updatePost(_, _, _, _, _, token),
                 let .deletePost(_, token),
                 let .getChallengePosts(_, _, _, token):
                return token
            }
        }()

        if let token {
            baseHeaders["Authorization"] = "Bearer \(token)"
            baseHeaders["Content-Type"] = "application/json"
        }

        return baseHeaders
    }
}
