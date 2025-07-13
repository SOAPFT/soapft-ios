//
//  FriendResponse.swift
//  SOAPFT
//
//  Created by 바견규 on 7/7/25.
//

//MARK: - 친구 목록 조회 응답
struct FriendListResponse: Decodable {
    let friends: [Friend]
}

struct Friend: Decodable {
    let friendId: Int
    let friendUuid: String
    let nickname: String
    let profileImage: String?
    let status: String  // 예: "ACCEPTED"
    let createdAt: String
}

//MARK: - 받은 친구 요청 목록 조회 응답
struct ReceivedFriendRequestsResponse: Decodable {
    let receivedRequests: [ReceivedFriendRequest]
}

struct ReceivedFriendRequest: Decodable {
    let requestId: Int
    let requesterUuid: String
    let nickname: String
    let profileImage: String?
    let createdAt: String
}


//MARK: - 보낸 친구 요청 목록 조회 응답
struct SentFriendRequestsResponse: Decodable {
    let sentRequests: [SentFriendRequest]
}

struct SentFriendRequest: Decodable {
    let requestId: Int
    let addresseeUuid: String
    let nickname: String
    let profileImage: String
    let createdAt: String
}

// MARK: - 친구 검색 응답
struct SearchedFriend: Decodable {
    let userUuid: String
    let nickname: String
    let profileImage: String
    let isFriend: Bool
}
