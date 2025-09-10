//
//  PostResponse.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/7/25.
//

import Foundation

// MARK: - 사용자 게시글 생성 응답
struct PostResponseDTO: Decodable {
    let message: String
    let post: Post

    struct Post: Decodable {
        let postUuid: String
        let title: String?
        let userUuid: String
        let challengeUuid: String
        let content: String
        let imageUrl: [String]
        let isPublic: Bool
        let id: Int
        let views: Int
        let createdAt: String
        let updatedAt: String
    }
}

// MARK: - 사용자 게시글 조회 (페이지네이션)
struct UserPostsResponseDTO: Decodable {
    let message: String
    let total: Int
    let page: Int
    let limit: Int
    let posts: [Post]
}

// MARK: - 특정 사용자 게시글 목록 조회
// UserPostsResponseDTO와 동일하므로 재사용 가능

// MARK: - 게시글 상세 조회
struct PostDetailResponseDTO: Decodable {
    let message: String
    let post: PostDetailDTO
}

struct PostDetailDTO: Decodable {
    let id: Int
    let postUuid: String
    let title: String
    let challengeUuid: String
    let content: String
    let imageUrl: [String]
    let isPublic: Bool
    let createdAt: String
    let updatedAt: String
    let userUuid: String
    let isMine: Bool
    let views: Int
    let user: UserDTO
}

struct UserDTO: Decodable {
    let userUuid: String
    let nickname: String
    let profileImage: String
}

// MARK: - 게시글 수정
struct UpdatePostResponseDTO: Decodable {
    let message: String
    let post: PostDTO
}

struct PostDTO: Decodable {
    let id: Int
    let postUuid: String
    let title: String
    let content: String
    let imageUrl: [String]
    let isPublic: Bool
    let createdAt: String
    let updatedAt: String
}

// MARK: - 게시글 삭제
struct DeletePostResponseDTO: Decodable {
    let message: String
}

// MARK: - 내 달력 조회
struct MyCalendarResponseDTO: Decodable {
    let data: [DatePosts]

    struct DatePosts: Decodable, Identifiable {
        var id: String { date }
        let date: String
        let posts: [CalendarPost]

        struct CalendarPost: Decodable {
            let postUuid: String
            let imageUrl: [String]
        }
    }
}

// MARK: - 다른 사용자 달력 조회
struct OtherUserCalendarResponseDTO: Decodable {
    let data: [DatePosts]

    struct DatePosts: Decodable, Identifiable {
        var id: String { date }
        let date: String
        let posts: [CalendarPost]

        struct CalendarPost: Decodable {
            let postUuid: String
            let imageUrl: [String]
        }
    }
}

// MARK: - 챌린지 게시글 목록 조회
struct ChallengePostsResponseDTO: Decodable {
    let message: String
    let total: Int
    let page: Int
    let limit: Int
    let posts: [Post]
}

struct User: Decodable {
    let userUuid: String
    let nickname: String
    let profileImage: String?
}

// MARK: - 공통 Post 모델
// 사용자 게시글 목록 조회, 특정 사용자 게시글 조회 등에서 사용하는 Post 구조체
struct Post: Decodable, Identifiable {
    let id: Int
    let postUuid: String
    let title: String?
    let userUuid: String?
    let challengeUuid: String?
    let content: String
    let imageUrl: [String]
    let isPublic: Bool
    let views: Int?
    let createdAt: String
    let updatedAt: String
    let verificationStatus: String?
    let aiConfidence: String?
    let aiAnalysisResult: String?
    let verifiedAt: String?
    var likeCount: Int?
    let commentCount: Int?
    let user: User?
}

// PostResponse.swift 등 전역 스코프 어딘가
extension Post {
    init(detail: PostDetailDTO) {
        self.id = detail.id
        self.postUuid = detail.postUuid
        self.title = detail.title
        self.userUuid = detail.userUuid
        self.challengeUuid = detail.challengeUuid
        self.content = detail.content
        self.imageUrl = detail.imageUrl
        self.isPublic = detail.isPublic
        self.views = detail.views
        self.createdAt = detail.createdAt
        self.updatedAt = detail.updatedAt
        self.verificationStatus = nil
        self.aiConfidence = nil
        self.aiAnalysisResult = nil
        self.verifiedAt = nil
        self.likeCount = nil
        self.commentCount = nil
        self.user = User(
            userUuid: detail.user.userUuid,
            nickname: detail.user.nickname,
            profileImage: detail.user.profileImage
        )
    }
}
