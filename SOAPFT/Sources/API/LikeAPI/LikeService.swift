//
//  LikeService.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/8/25.
//

import Foundation
import Moya

// MARK: - LikeService

final class LikeService {

    static let shared = LikeService()

    private let provider = MoyaProvider<LikeAPI>()

    private init() {}

    // MARK: - Add Like
    func like(postId: String, accessToken: String, completion: @escaping (Result<LikeAddResponseDTO, Error>) -> Void) {
        provider.request(.like(postId: postId, accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Cancel Like
    func unlike(postId: String, accessToken: String, completion: @escaping (Result<LikeCancelResponseDTO, Error>) -> Void) {
        provider.request(.unlike(postId: postId, accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Check Like Status
    func checkLikeStatus(postId: String, accessToken: String, completion: @escaping (Result<LikeStatusResponseDTO, Error>) -> Void) {
        provider.request(.checkLikeStatus(postId: postId, accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Generic Response Handler
    private func handleResponse<T: Decodable>(_ result: Result<Response, MoyaError>, completion: @escaping (Result<T, Error>) -> Void) {
        switch result {
        case .success(let response):
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: response.data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
