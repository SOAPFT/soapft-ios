//
//  PaymentAPI.swift
//  SOAPFT
//
//  Created by 바견규 on 8/10/25.
//

import Moya
import Foundation

enum PaymentAPI {
    case withdraw(amount: Int)
}

extension PaymentAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("❌ API_URL not found or invalid in Info.plist")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .withdraw:
            return "/api/payment/withdraw"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .withdraw:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .withdraw(let amount):
            let parameters = ["amount": amount]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        var headers: [String: String] = [
            "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            "Connection": "keep-alive",
            "Content-Type": "application/json",
            "Origin": "http://13.125.191.87:7777",
            "Referer": "http://13.125.191.87:7777/api/docs",
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36",
            "accept": "application/json"
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
