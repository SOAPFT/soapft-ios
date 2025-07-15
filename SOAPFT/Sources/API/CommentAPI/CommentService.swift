//
//  CommentService.swift
//  SOAPFT
//
//  Created by 바견규 on 7/15/25.
//

import Moya
import Foundation

// CommentService.swift
final class CommentService {
    private let provider = MoyaProvider<CommentAPI>()

    func createComment(postUuid: String, content: String, parentCommentId: Int?, completion: @escaping (Result<CommentResponse, Error>) -> Void) {
        provider.request(.createComment(postUuid: postUuid, content: content, parentCommentId: parentCommentId)) {
            result in self.handle(result, type: CommentResponse.self, completion: completion)
        }
    }

    func getComments(postUuid: String, page: Int, limit: Int, completion: @escaping (Result<CommentListResponse, Error>) -> Void) {
        provider.request(.getComments(postUuid: postUuid, page: page, limit: limit)) {
            result in self.handle(result, type: CommentListResponse.self, completion: completion)
        }
    }

    func updateComment(id: Int, content: String, isDeleted: Bool, completion: @escaping (Result<CommentResponse, Error>) -> Void) {
        provider.request(.updateComment(id: id, content: content, isDeleted: isDeleted)) {
            result in self.handle(result, type: CommentResponse.self, completion: completion)
        }
    }

    func deleteComment(id: Int, completion: @escaping (Result<BasicResponse, Error>) -> Void) {
        provider.request(.deleteComment(id: id)) {
            result in self.handle(result, type: BasicResponse.self, completion: completion)
        }
    }

    private func handle<T: Decodable>(_ result: Result<Moya.Response, MoyaError>, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        switch result {
        case .success(let response):
            do {
                let decoded = try JSONDecoder().decode(T.self, from: response.data)
                completion(.success(decoded))
            } catch {
                print("📦 Raw JSON Response:\n" + (String(data: response.data, encoding: .utf8) ?? "nil"))
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
