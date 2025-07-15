//
//  CommentAPI.swift
//  SOAPFT
//
//  Created by 바견규 on 7/15/25.
//

// CommentAPI.swift
import Foundation
import Moya

enum CommentAPI {
    case createComment(postUuid: String, content: String, parentCommentId: Int?)
    case getComments(postUuid: String, page: Int, limit: Int)
    case updateComment(id: Int, content: String, isDeleted: Bool)
    case deleteComment(id: Int)
}

extension CommentAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("❌ API_URL not found or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .createComment:
            return "/api/comment"
        case .getComments(let postUuid, _, _):
            return "/api/comment/post/\(postUuid)"
        case .updateComment(let id, _, _), .deleteComment(let id):
            return "/api/comment/\(id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .createComment:
            return .post
        case .getComments:
            return .get
        case .updateComment:
            return .patch
        case .deleteComment:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case let .createComment(postUuid, content, parentCommentId):
            var parameters: [String: Any] = [
                "postUuid": postUuid,
                "content": content
            ]
            if let parentId = parentCommentId {
                parameters["parentCommentId"] = parentId
            }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

        case .getComments(_, let page, let limit):
            return .requestParameters(parameters: ["page": page, "limit": limit], encoding: URLEncoding.queryString)

        case let .updateComment(_, content, isDeleted):
            return .requestParameters(parameters: ["content": content, "isDeleted": isDeleted], encoding: JSONEncoding.default)

        case .deleteComment:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(KeyChainManager.shared.read(forKey: "accessToken") ?? "")"
        ]
    }

    var validationType: ValidationType {
        return .successCodes
    }
}
