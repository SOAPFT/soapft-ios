//
//  LoginAPI.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/3/25.
//

import Foundation
import Moya

enum KakaoAuthAPI {
    case sendToken(accessToken: String, deviceId: String, deviceType: String, pushToken: String, appVersion: String)
}

extension KakaoAuthAPI: TargetType {
    var baseURL: URL {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_URL") as! String
        return URL(string: baseURL)!
    }
    

    var path: String {
        return "/api/auth/kakao"
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        switch self {
        case let .sendToken(accessToken, deviceId, deviceType, pushToken, appVersion):
            let params: [String: Any] = [
                "accessToken": accessToken,
                "deviceId": deviceId,
                "deviceType": deviceType,
                "pushToken": pushToken,
                "appVersion": appVersion
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "*/*"
        ]
    }
}
