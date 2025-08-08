//
//  EventAPI.swift
//  SOAPFT
//
//  Created by 바견규 on 8/4/25.
//

import Foundation
import Moya

enum EventAPI {
    case getEventList
    case getEventDetail(id: Int)
    case participateEvent(id: Int)
    case getParticipatedMyEventList
    case certificateEvent(id: String, parameters: [String: Any])
    case cancleParticipateEvent(id: Int)
}

extension EventAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("❌ API_URL not found or invalid in Info.plist")
        }
        return url
    }
    
    
    var path: String {
        switch self {
        case .getEventList:
                return "/api/mission"
        case .getEventDetail(let id):
            return "/api/mission/\(id)"
        case .participateEvent(let id):
            return "/api/mission/\(id)/participate"
        case .getParticipatedMyEventList:
            return "/api/mission/me"
        case .certificateEvent(let id, _):
            return "/api/mission/\(id)/result"
        case .cancleParticipateEvent(let id):
            return "/api/mission/\(id)/participate"
        }

    }
    
    var method: Moya.Method {
        switch self {
        case .participateEvent:
            return .post
        case .certificateEvent:
            return .patch
        case .cancleParticipateEvent:
            return .delete
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getEventDetail(let id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        case .participateEvent(let id):
            return .requestParameters(parameters: ["missionId": id], encoding: URLEncoding.queryString)
        case .certificateEvent(_, let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .cancleParticipateEvent(let id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)

        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        var headers: [String: String] = [
            "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            "accept": "application/json",
//            "Content-Type": "application/json"
//            "Content-Type": "multipart/form-data"
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
