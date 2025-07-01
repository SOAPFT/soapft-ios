//
//  Untitled.swift
//  SOAPFT
//
//  Created by 바견규 on 7/2/25.
//

import SwiftUI

class PostChatViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var pagination: Pagination?
    @Published var postUuid: String

    init(postUuid: String) {
        self.postUuid = postUuid
    }

    func loadMockData() {
        let mock = PostChatCommentMockData.sample
        self.comments = mock.comments
        self.pagination = mock.pagination
    }

    func addComment(content: String) {
        let newComment = Comment(
            id: Int.random(in: 1000...9999),
            content: content,
            author: .init(userUuid: "ME", nickname: "나", profileImage: "https://example.com/my-profile.jpg"),
            parentCommentId: nil,
            mentionedUsers: [],
            replies: [],
            replyCount: 0,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
        comments.append(newComment)
    }

    func addReply(to commentId: Int, content: String) {
        guard let index = comments.firstIndex(where: { $0.id == commentId }) else { return }

        let newReply = Reply(
            id: Int.random(in: 10000...99999),
            content: content,
            author: .init(userUuid: "ME", nickname: "나", profileImage: "https://example.com/my-profile.jpg"),
            parentCommentId: commentId,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
        comments[index].replies.append(newReply)
        comments[index].replyCount += 1
    }
}
