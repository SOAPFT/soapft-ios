//
//  FriendService.swift
//  SOAPFT
//
//  Created by 바견규 on 7/10/25.
//

import Foundation
import Moya

final class FriendService {
    let provider: MoyaProvider<FriendAPI>

    init(provider: MoyaProvider<FriendAPI> = MoyaProvider<FriendAPI>()) {
        self.provider = provider
    }

    // 친구 요청 보내기
    func sendFriendRequest(to addresseeUuid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.sendRequest(addresseeUuid: addresseeUuid)) {
            self.handleEmptyResponse($0, completion: completion)
        }
    }

    // 친구 요청 수락
    func acceptFriendRequest(friendId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.acceptRequest(friendId: friendId)) {
            self.handleEmptyResponse($0, completion: completion)
        }
    }

    // 친구 요청 거절
    func rejectFriendRequest(friendId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.rejectRequest(friendId: friendId)) {
            self.handleEmptyResponse($0, completion: completion)
        }
    }

    // 친구 삭제
    func deleteFriend(friendId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.deleteFriend(friendId: friendId)) {
            self.handleEmptyResponse($0, completion: completion)
        }
    }

    // 친구 목록 조회
    func fetchFriendList(completion: @escaping (Result<[Friend], Error>) -> Void) {
        print("[FriendService] fetchFriendList called")

        provider.request(.friendList) { result in
            switch result {
            case .success(let response):
                print("[FriendService] fetchFriendList response statusCode: \(response.statusCode)")
                print("[FriendService] fetchFriendList response raw JSON:\n\(String(data: response.data, encoding: .utf8) ?? "nil")")

                do {
                    let decoded = try JSONDecoder().decode(FriendListResponse.self, from: response.data)
                    print("[FriendService] fetchFriendList decoded friends count: \(decoded.friends.count)")
                    completion(.success(decoded.friends))
                } catch {
                    print("[FriendService] JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[FriendService] 네트워크 실패: \(error)")
                completion(.failure(error))
            }
        }
    }


    // 받은 친구 요청 목록 조회
    func fetchReceivedRequests(completion: @escaping (Result<[ReceivedFriendRequest], Error>) -> Void) {
        print("[FriendService] fetchReceivedRequests called")
        
        provider.request(.receivedRequests) {
            self.decode($0, as: ReceivedFriendRequestsResponse.self) { result in
                switch result {
                case .success(let decoded):
                    print("[FriendService] receivedRequests decoded count: \(decoded.receivedRequests.count)")
                    completion(.success(decoded.receivedRequests))
                case .failure(let error):
                    print("[FriendService] 받은 요청 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }


    // 보낸 친구 요청 목록 조회
    func fetchSentRequests(completion: @escaping (Result<[SentFriendRequest], Error>) -> Void) {
        provider.request(.sentRequests) {
            self.decode($0, as: SentFriendRequestsResponse.self) { completion($0.map { $0.sentRequests }) }
        }
    }
    
    // 친구 검색
    func searchFriends(keyword: String, completion: @escaping (Result<[SearchedFriend], Error>) -> Void) {
        provider.request(.searchFriend(keyword: keyword)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode([SearchedFriend].self, from: response.data)
                    completion(.success(decoded))
                } catch {
                    print("[FriendService] 디코딩 실패: \(error)")
                    print("[FriendService] 원본 응답: \(String(data: response.data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[FriendService] 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }


    // MARK: - 공통 디코딩 처리

    private func decode<T: Decodable>(
        _ result: Result<Response, MoyaError>,
        as type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        switch result {
        case .success(let response):
            do {
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("[FriendService] 서버 응답 JSON:\n\(jsonString)")
                }
                
                let decoded = try JSONDecoder().decode(T.self, from: response.data)
                completion(.success(decoded))
            } catch {
                print("[FriendService] 디코딩 오류:\n" + (String(data: response.data, encoding: .utf8) ?? "nil"))
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }


    private func handleEmptyResponse(
        _ result: Result<Response, MoyaError>,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        switch result {
        case .success:
            completion(.success(()))
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
