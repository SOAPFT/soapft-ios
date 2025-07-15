//
//  Untitled.swift
//  SOAPFT
//
//  Created by 바견규 on 7/2/25.
//

import SwiftUI


class PostChatViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var postUuid: String
    @Published var isLoading = false
    @Published var hasMore = true

    private var currentPage = 1
    private let limit = 10
    private let commentService: CommentService
    
  
    @Published private(set) var commentAddedCount: Int = 0

    init(postUuid: String, commentService: CommentService) {
        self.postUuid = postUuid
        self.commentService = commentService
        fetchComments()
    }

    func fetchComments() {
        guard !isLoading && hasMore else { return }
        isLoading = true

        commentService.getComments(postUuid: postUuid, page: currentPage, limit: limit) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let response):
                    self.comments.append(contentsOf: response.comments)
                    self.currentPage += 1
                    self.hasMore = response.comments.count == self.limit
                case .failure(let error):
                    print("❌ 댓글 불러오기 실패: \(error.localizedDescription)")
                    self.hasMore = false
                }
            }
        }
    }

    func addComment(content: String) {
        commentService.createComment(postUuid: postUuid, content: content, parentCommentId: nil) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    // 새 댓글 작성 후 전체 댓글 새로 불러오기
                    self.comments.removeAll()
                    self.currentPage = 1
                    self.hasMore = true
                    self.fetchComments()
                    // 새 댓글 카운트 증가
                    self.commentAddedCount += 1
                case .failure(let error):
                    print("❌ 댓글 추가 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    func addReply(to commentId: Int, content: String) {
        commentService.createComment(postUuid: postUuid, content: content, parentCommentId: commentId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    // 대댓글 작성 후 전체 댓글 새로 불러오기
                    self.comments.removeAll()
                    self.currentPage = 1
                    self.hasMore = true
                    self.fetchComments()
                    // 새 댓글 카운트 증가
                    self.commentAddedCount += 1
                case .failure(let error):
                    print("❌ 대댓글 추가 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
}
