//
//  PostChatModel.swift
//  SOAPFT
//
//  Created by 바견규 on 7/2/25.
//

struct CommentResponse: Decodable {
    let comments: [Comment]
    let pagination: Pagination
}

struct Comment: Identifiable, Decodable {
    let id: Int
    let content: String
    let author: Author
    let parentCommentId: Int?
    let mentionedUsers: [MentionedUser]
    var replies: [Reply]
    var replyCount: Int
    let createdAt: String
    let updatedAt: String
}

struct Reply: Identifiable, Decodable {
    let id: Int
    let content: String
    let author: Author
    let parentCommentId: Int
    let createdAt: String
}

struct Author: Decodable {
    let userUuid: String
    let nickname: String
    let profileImage: String
}

struct MentionedUser: Decodable {
    let userUuid: String
    let nickname: String
}
