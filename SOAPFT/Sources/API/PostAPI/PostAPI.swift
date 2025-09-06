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
    case getUserPosts(userId: String, page: Int, limit: Int, accessToken: String)
    case getPostDetail(postUuid: String, accessToken: String)
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
        case .getPostDetail(let postUuid, _):
            return "/api/post/\(postUuid)"
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
}
