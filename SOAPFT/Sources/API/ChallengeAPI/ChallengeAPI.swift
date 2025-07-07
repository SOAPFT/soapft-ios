//
//  ChallengeAPI.swift
//  SOAPFT
//
//  Created by 바견규 on 7/7/25.
//

import Moya
import Foundation

enum ChallengeAPI {
    case userChallenges(status: String)
    case successfulChallenges
    case createChallenge(parameters: [String: Any])
    case fetchChallenges(page: Int, limit: Int, type: String, gender: String, status: String)
    case recentChallenges
    case popularChallenges
    case searchChallenges(keyword: String, page: Int, limit: Int)
    case challengeDetail(id: String)
    case updateChallenge(id: String, parameters: [String: Any])
    case joinChallenge(id: String)
    case progress(id: String)
    case leaveChallenge(id: String)
    case monthlyStats(id: String, year: Int, month: Int)
}

extension ChallengeAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("❌ API_URL not found or invalid in Info.plist")
        }
        return url
    }


    var path: String {
        switch self {
        case .userChallenges:
            return "/api/challenge/user"
        case .successfulChallenges:
            return "/api/challenge/successful"
        case .createChallenge:
            return "/api/challenge"
        case .fetchChallenges:
            return "/api/challenge"
        case .recentChallenges:
            return "/api/challenge/recent"
        case .popularChallenges:
            return "/api/challenge/popular"
        case .searchChallenges:
            return "/api/challenge/search"
        case .challengeDetail(let id), .updateChallenge(let id, _):
            return "/api/challenge/\(id)"
        case .joinChallenge(let id):
            return "/api/challenge/\(id)/join"
        case .progress(let id):
            return "/api/challenge/\(id)/progress"
        case .leaveChallenge(let id):
            return "/api/challenge/\(id)/leave"
        case .monthlyStats(let id, _, _):
            return "/api/challenge/\(id)/stats"
        }
    }

    var method: Moya.Method {
        switch self {
        case .createChallenge:
            return .post
        case .updateChallenge:
            return .patch
        case .joinChallenge:
            return .post
        case .leaveChallenge:
            return .delete
        default:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .userChallenges(let status):
            return .requestParameters(parameters: ["status": status], encoding: URLEncoding.queryString)
        case .fetchChallenges(let page, let limit, let type, let gender, let status):
            return .requestParameters(parameters: ["page": page, "limit": limit, "type": type, "gender": gender, "status": status], encoding: URLEncoding.queryString)
        case .searchChallenges(let keyword, let page, let limit):
            return .requestParameters(parameters: ["keyword": keyword, "page": page, "limit": limit], encoding: URLEncoding.queryString)
        case .monthlyStats(_, let year, let month):
            return .requestParameters(parameters: ["year": year, "month": month], encoding: URLEncoding.queryString)
        case .createChallenge(let parameters), .updateChallenge(_, let parameters):
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
