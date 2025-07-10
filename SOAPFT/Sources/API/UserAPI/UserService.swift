//
//  UserService.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/8/25.
//

import Foundation
import Moya

// MARK: - UserService

final class UserService {

    static let shared = UserService()

    private let provider = MoyaProvider<UserAPI>()

    init() {}

    // MARK: - Onboarding
    func onboarding(nickname: String, gender: String, birthDate: String, accessToken: String, completion: @escaping (Result<SignupResponseDTO, Error>) -> Void) {
        provider.request(.onboarding(nickname: nickname, gender: gender, birthDate: birthDate, accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Logout
    func logout(accessToken: String, completion: @escaping (Result<LogoutResponseDTO, Error>) -> Void) {
        provider.request(.logout(accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Update Profile
    func updateProfile(newNickname: String, newIntroduction: String, newProfileImg: String, accessToken: String, completion: @escaping (Result<ProfileUpdateResponseDTO, Error>) -> Void) {
        provider.request(.updateProfile(newNickname: newNickname, newIntroduction: newIntroduction, newProfileImg: newProfileImg, accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Delete Profile
    func deleteProfile(accessToken: String, completion: @escaping (Result<UserDeleteResponseDTO, Error>) -> Void) {
        provider.request(.deleteProfile(accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Get My Profile
    func getUserInfo(accessToken: String, completion: @escaping (Result<MyProfileResponseDTO, Error>) -> Void) {
        provider.request(.getUserInfo(accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Get Other User Info
    func getOtherUserInfo(userUUID: String, accessToken: String, completion: @escaping (Result<OtherUserProfileResponseDTO, Error>) -> Void) {
        provider.request(.getOtherUserInfo(userUUID: userUUID, accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Generic Response Handler
    private func handleResponse<T: Decodable>(_ result: Result<Response, MoyaError>, completion: @escaping (Result<T, Error>) -> Void) {
        switch result {
        case .success(let response):
            do {
               if let json = try JSONSerialization.jsonObject(with: response.data) as? [String: Any],
                  let success = json["success"] as? Bool,
                  success == false {
                   // 에러 응답 파싱
                   let errorResponse = try JSONDecoder().decode(ErrorResponseDTO.self, from: response.data)
                   completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])))
               } else {
                   // 성공 응답 파싱
                   let decodedData = try JSONDecoder().decode(T.self, from: response.data)
                   completion(.success(decodedData))
               }
           } catch {
               completion(.failure(error))
           }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
