//
//  PostService.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/8/25.
//

import Foundation
import Moya

// MARK: - PostService

final class PostService {

    static let shared = PostService()

    private let provider = MoyaProvider<PostAPI>()

    private init() {}

    // MARK: - Create Post
    func createPost(title: String, challengeUuid: String, content: String, imageUrls: [String], isPublic: Bool, completion: @escaping (Result<PostResponseDTO, Error>) -> Void) {
        provider.request(.createPost(title: title, challengeUuid: challengeUuid, content: content, imageUrls: imageUrls, isPublic: isPublic)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Get My Posts
    func getMyPosts(page: Int, limit: Int, completion: @escaping (Result<UserPostsResponseDTO, Error>) -> Void) {
        provider.request(.getMyPosts(page: page, limit: limit)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Get Calendar
    func getCalendar(year: Int, month: Int, completion: @escaping (Result<MyCalendarResponseDTO, Error>) -> Void) {
        provider.request(.getCalendar(year: year, month: month)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Get User Calendar
    func getUserCalendar(userUuid: String, year: Int, month: Int, completion: @escaping (Result<OtherUserCalendarResponseDTO, Error>) -> Void) {
        provider.request(.getUserCalendar(userUuid: userUuid, year: year, month: month)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Get User Posts
    func getUserPosts(userId: Int, page: Int, limit: Int, completion: @escaping (Result<UserPostsResponseDTO, Error>) -> Void) {
        provider.request(.getUserPosts(userId: userId, page: page, limit: limit)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Get Post Detail
    func getPostDetail(postId: Int, completion: @escaping (Result<PostDetailResponseDTO, Error>) -> Void) {
        provider.request(.getPostDetail(postId: postId)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Update Post
    func updatePost(postUuid: String, title: String, content: String, imageUrls: [String], isPublic: Bool, completion: @escaping (Result<UpdatePostResponseDTO, Error>) -> Void) {
        provider.request(.updatePost(postUuid: postUuid, title: title, content: content, imageUrls: imageUrls, isPublic: isPublic)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Delete Post
    func deletePost(postId: Int, completion: @escaping (Result<DeletePostResponseDTO, Error>) -> Void) {
        provider.request(.deletePost(postId: postId)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Get Challenge Posts
    func getChallengePosts(challengeId: Int, page: Int, limit: Int, completion: @escaping (Result<ChallengePostsResponseDTO, Error>) -> Void) {
        provider.request(.getChallengePosts(challengeId: challengeId, page: page, limit: limit)) { result in
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
