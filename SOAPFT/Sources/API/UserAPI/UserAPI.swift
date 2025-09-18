//
//  UserAPI.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/7/25.
//

import Foundation
import Moya

enum UserAPI {
    case onboarding(nickname: String, gender: String, birthDate: String, accessToken: String)
    case logout(accessToken: String)
    case updateProfile(newNickname: String, newIntroduction: String, newProfileImg: String, accessToken: String)
    case deleteProfile(accessToken: String)
    case getUserInfo(accessToken: String)
    case getOtherUserInfo(userUUID: String, accessToken: String)
}

extension UserAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("❌ API_URL not found or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .onboarding:
            return "/api/user/onboarding"
        case .logout:
            return "/api/user/logout"
        case .updateProfile:
            return "/api/user/profile"
        case .deleteProfile:
            return "/api/user/member"
        case .getUserInfo:
            return "/api/user/userInfo"
        case .getOtherUserInfo(let userUUID, _):
            return "/api/user/info/\(userUUID)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .onboarding, .logout, .updateProfile:
            return .post
        case .deleteProfile:
            return .delete
        case .getUserInfo, .getOtherUserInfo:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .onboarding(nickname, gender, birthDate, _):
            let params: [String: Any] = [
                "nickname": nickname,
                "gender": gender,
                "birthDate": birthDate
            ]
            print("🚀 [Onboarding 요청 파라미터]: nickname=\(nickname), gender=\(gender), birthDate=\(birthDate)")
            
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case let .updateProfile(newNickname, newIntroduction, newProfileImg, _):
            let params: [String: Any] = [
                "newNickname": newNickname,
                "newIntroduction": newIntroduction,
                "newProfileImg": newProfileImg
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case .logout, .deleteProfile:
            return .requestPlain

        case .getUserInfo, .getOtherUserInfo:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
        var baseHeaders: [String: String] = [
            "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            "accept": "application/json"
        ]
        switch self {
        case let .deleteProfile(accessToken):
            baseHeaders["Authorization"] = "Bearer \(accessToken)"
            // Content-Type 제거
            return baseHeaders
        // 나머지 POST/PUT류에서만 Content-Type 추가
        case let .onboarding(_, _, _, accessToken),
             let .logout(accessToken),
             let .updateProfile(_, _, _, accessToken),
             let .getUserInfo(accessToken),
             let .getOtherUserInfo(_, accessToken):
            baseHeaders["Authorization"] = "Bearer \(accessToken)"
            baseHeaders["Content-Type"] = "application/json"
            return baseHeaders
        }
    }

    var sampleData: Data {
        return Data()
    }
}
