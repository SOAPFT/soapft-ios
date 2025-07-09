//
//  FriendService.swift
//  SOAPFT
//
//  Created by 바견규 on 7/10/25.
//

import Foundation
import Moya

final class FriendService {
    private let provider: MoyaProvider<FriendAPI>

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
    func acceptFriendRequest(requestId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.acceptRequest(requestId: requestId)) {
            self.handleEmptyResponse($0, completion: completion)
        }
    }

    // 친구 요청 거절
    func rejectFriendRequest(requestId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.rejectRequest(requestId: requestId)) {
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
    func fetchFriendList(parameters: [String: Any], completion: @escaping (Result<[Friend], Error>) -> Void) {
        provider.request(.friendList(parameters: parameters)) {
            self.decode($0, as: FriendListResponse.self) { completion($0.map { $0.friends }) }
        }
    }

    // 받은 친구 요청 목록 조회
    func fetchReceivedRequests(completion: @escaping (Result<[ReceivedFriendRequest], Error>) -> Void) {
        provider.request(.receivedRequests) {
            self.decode($0, as: ReceivedFriendRequestsResponse.self) { completion($0.map { $0.receivedRequests }) }
        }
    }

    // 보낸 친구 요청 목록 조회
    func fetchSentRequests(completion: @escaping (Result<[SentFriendRequest], Error>) -> Void) {
        provider.request(.sentRequests) {
            self.decode($0, as: SentFriendRequestsResponse.self) { completion($0.map { $0.sentRequests }) }
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
                let decoded = try JSONDecoder().decode(T.self, from: response.data)
                completion(.success(decoded))
            } catch {
                print("❗️디코딩 오류:\n" + (String(data: response.data, encoding: .utf8) ?? "nil"))
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
