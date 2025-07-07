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
        switch self {
        case .getOtherUserInfo(let userUUID, _):
            return URL(string: "http://13.125.191.87:7777/api/user/info/\(userUUID)")!
        default:
            return URL(string: "http://13.125.191.87:7777/api/user")!
        }
    }

    var path: String {
        switch self {
        case .onboarding:
            return "/onboarding"
        case .logout:
            return "/logout"
        case .updateProfile:
            return "/profile"
        case .deleteProfile:
            return "/member"
        case .getUserInfo:
            return "/userInfo"
        case .getOtherUserInfo:
            return ""
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
        case let .onboarding(_, _, _, accessToken),
             let .logout(accessToken),
             let .updateProfile(_, _, _, accessToken),
             let .deleteProfile(accessToken),
             let .getUserInfo(accessToken),
             let .getOtherUserInfo(_, accessToken):
            baseHeaders["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyVXVpZCI6IjAxSllLVk4xOE1DVzVCOUZaMVBQN1QxNFhTIiwiaWF0IjoxNzUxOTAzNDA0LCJleHAiOjE3NTQ0OTU0MDR9.eeETUYLQy_W14flyNrvkSkJQm4CfqfsbrtfN7dOssl8"
            baseHeaders["Content-Type"] = "application/json"
            return baseHeaders
        }
    }

    var sampleData: Data {
        return Data()
    }
}
