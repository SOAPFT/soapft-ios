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

    init() {}

    // MARK: - Create Post
    func createPost(title: String, challengeUuid: String, content: String, imageUrls: [String], isPublic: Bool, accessToken: String, completion: @escaping (Result<PostResponseDTO, Error>) -> Void) {
        provider.request(.createPost(title: title, challengeUuid: challengeUuid, content: content, imageUrls: imageUrls, isPublic: isPublic, accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Get My Posts
    func getMyPosts(page: Int, limit: Int, accessToken: String, completion: @escaping (Result<UserPostsResponseDTO, Error>) -> Void) {
        provider.request(.getMyPosts(page: page, limit: limit, accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Get Calendar
//    func getCalendar(year: Int, month: Int, completion: @escaping (Result<MyCalendarResponseDTO, Error>) -> Void) {
//        provider.request(.getCalendar(year: year, month: month)) { result in
//            self.handleResponse(result, completion: completion)
//        }
//    }
    func getCalendar(year: Int, month: Int, accessToken: String, completion: @escaping (Result<MyCalendarResponseDTO, Error>) -> Void) {
        print("📡 [PostService] getCalendar 요청 → year: \(year), month: \(month)")

        provider.request(.getCalendar(year: year, month: month, accessToken: accessToken)) { result in
            switch result {
            case .success(let response):
                // 응답 본문 출력
                if let json = String(data: response.data, encoding: .utf8) {
                    print("📦 [PostService] 응답 JSON:\n\(json)")
                }

                do {
                    let decodedData = try JSONDecoder().decode(MyCalendarResponseDTO.self, from: response.data)
                    print("✅ [PostService] getCalendar 디코딩 성공, 날짜 수: \(decodedData.data.count)")
                    completion(.success(decodedData))
                } catch {
                    // 디코딩 실패 시 상세 에러 출력
                    print("❗️ [PostService] getCalendar 디코딩 실패: \(error)")
                    print("📦 원본 응답: \(String(data: response.data, encoding: .utf8) ?? "nil")")
                    completion(.failure(error))
                }

            case .failure(let error):
                print("❌ [PostService] getCalendar 네트워크 요청 실패: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }


    // MARK: - Get User Calendar
//    func getUserCalendar(userUuid: String, year: Int, month: Int, completion: @escaping (Result<OtherUserCalendarResponseDTO, Error>) -> Void) {
//        provider.request(.getUserCalendar(userUuid: userUuid, year: year, month: month)) { result in
//            self.handleResponse(result, completion: completion)
//        }
//    }
    func getUserCalendar(userUuid: String, year: Int, month: Int, accessToken: String, completion: @escaping (Result<OtherUserCalendarResponseDTO, Error>) -> Void) {
        print("📡 [PostService] getUserCalendar 요청 → userUUID: \(userUuid), year: \(year), month: \(month)")

        provider.request(.getUserCalendar(userUuid: userUuid, year: year, month: month, accessToken: accessToken)) { result in
            switch result {
            case .success(let response):
                if let json = String(data: response.data, encoding: .utf8) {
                    print("📦 [PostService] 응답 JSON:\n\(json)")
                }

                do {
                    let decodedData = try JSONDecoder().decode(OtherUserCalendarResponseDTO.self, from: response.data)
                    print("✅ [PostService] 디코딩 성공, 날짜 수: \(decodedData.data.count)")
                    completion(.success(decodedData))
                } catch {
                    print("❗️ [PostService] 디코딩 실패: \(error)")
                    print("📦 원본 응답: \(String(data: response.data, encoding: .utf8) ?? "nil")")
                    completion(.failure(error))
                }

            case .failure(let error):
                print("❌ [PostService] 네트워크 요청 실패: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }


    // MARK: - Get User Posts
    func getUserPosts(userId: Int, page: Int, limit: Int, accessToken: String, completion: @escaping (Result<UserPostsResponseDTO, Error>) -> Void) {
        provider.request(.getUserPosts(userId: userId, page: page, limit: limit, accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Get Post Detail
    func getPostDetail(postId: Int, accessToken: String, completion: @escaping (Result<PostDetailResponseDTO, Error>) -> Void) {
        provider.request(.getPostDetail(postId: postId, accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Update Post
    func updatePost(postUuid: String, title: String, content: String, imageUrls: [String], isPublic: Bool, accessToken: String, completion: @escaping (Result<UpdatePostResponseDTO, Error>) -> Void) {
        provider.request(.updatePost(postUuid: postUuid, title: title, content: content, imageUrls: imageUrls, isPublic: isPublic, accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Delete Post
    func deletePost(postId: Int, accessToken: String, completion: @escaping (Result<DeletePostResponseDTO, Error>) -> Void) {
        provider.request(.deletePost(postId: postId, accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Get Challenge Posts
    func getChallengePosts(challengeId: String, page: Int, limit: Int, accessToken: String, completion: @escaping (Result<ChallengePostsResponseDTO, Error>) -> Void) {
        provider.request(.getChallengePosts(challengeId: challengeId, page: page, limit: limit, accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Generic Response Handler
    private func handleResponse<T: Decodable>(_ result: Result<Response, MoyaError>, completion: @escaping (Result<T, Error>) -> Void) {
        switch result {
        case .success(let response):
            // 🔍 디버깅 로그 추가
            print("📡 [PostService] 상태 코드: \(response.statusCode)")
            print("📦 [PostService] Raw JSON: \(String(data: response.data, encoding: .utf8) ?? "없음")")

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: response.data)
                completion(.success(decodedData))
            } catch {
                print("❗️ 디코딩 실패: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
