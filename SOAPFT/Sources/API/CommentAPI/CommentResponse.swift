//
//  CommentResponse.swift
//  SOAPFT
//
//  Created by 바견규 on 7/15/25.
//

import Foundation

// CommentResponse.swift
struct CommentResponse: Decodable {
    let message: String
    let comment: CreatedComment
}
struct CreatedComment: Decodable, Identifiable {
    let id: Int
    let postUuid: String
    let userUuid: String
    let content: String
    let parentCommentId: Int?
    let mentionedUsers: [String]
    let createdAt: String
    let updatedAt: String
}


struct CommentListResponse: Decodable {
    let message: String
    let total: Int // 총 댓글 개수
    let page: Int
    let limit: Int //페이지 당 항목 수
    let comments: [Comment]
}

struct Comment: Decodable, Identifiable {
    let id: Int
    let postUuid: String
    let userUuid: String
    let content: String
    let parentCommentId: Int?
    let mentionedUsers: [String]
    let createdAt: String
    let updatedAt: String
    let isMyComment: Bool
    let user: CommentUser
    var children: [Comment]?
}

struct CommentUser: Decodable {
    let userUuid: String
    let nickname: String
    let profileImage: String?
}

struct BasicResponse: Decodable {
    let message: String
}
