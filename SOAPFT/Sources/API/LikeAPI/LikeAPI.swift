//
//  LikeAPI.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/7/25.
//

import Foundation
import Moya

enum LikeAPI {
    case like(postId: String)
    case unlike(postId: String)
    case checkLikeStatus(postId: String)
}

extension LikeAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("❌ API_URL not found or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .like(let postId), .unlike(let postId):
            return "/api/like/\(postId)"
        case .checkLikeStatus(let postId):
            return "/api/like/check/\(postId)"
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
