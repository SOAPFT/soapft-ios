//
//  PostDetailViewModel.swift
//  SOAPFT
//
//  Created by 홍지우 on 9/7/25.
//

import Foundation
import Combine

final class PostDetailViewModel : ObservableObject {
    @Published var posts: [Post] = []
    @Published var postUIStates: [String: PostUIState] = [:]
    
    var container: DIContainer!
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var post: PostDetailDTO?
    @Published var message: String = ""

    private var cancellables = Set<AnyCancellable>()
    let postUuid: String
    
    init(container: DIContainer, postUuid: String) {
        self.container = container
        self.postUuid = postUuid
    }
    @Published var commentCounts: [String: Int] = [:]
    
    func fetchDetail() {
        guard let accessToken = KeyChainManager.shared.read(forKey: "accessToken") else {
            self.errorMessage = "로그인이 필요합니다"
            return
        }
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        container.postService.getPostDetail(postUuid: postUuid, accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let dto):
                    self.message = dto.message
                    self.post = dto.post
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }
    
    func toggleLike(for post: PostDetailDTO) {
        guard let state = postUIStates[post.postUuid] else { return }

        if state.isLiked {
            container.likeService.unlike(postId: post.postUuid) { result in
                DispatchQueue.main.async {
                    if case let .success(res) = result {
                        state.isLiked = false
                        // 상세 DTO에 likeCount가 없다면 생략, 있으면 갱신
                        // self.post?.likeCount = res.likeCount
                    } else {
                        // 실패 시 롤백이 필요하면 여기서 처리
                    }
                }
            }
        } else {
            container.likeService.like(postId: post.postUuid) { result in
                DispatchQueue.main.async {
                    if case let .success(res) = result {
                        state.isLiked = true
                        // self.post?.likeCount = res.likeCount
                    }
                }
            }
        }
    }
    
    func toggleSuspicion(for post: PostDetailDTO) {
        print("🔍 의심하기 버튼 클릭 - PostUUID: \(post.postUuid)")
        
        guard let state = postUIStates[post.postUuid] else {
            print("❌ PostUIState가 없음 - PostUUID: \(post.postUuid)")
            return
        }
        
        print("🔍 현재 의심 상태: \(state.isSuspicious)")
        state.isSuspicious.toggle()
        print("🔍 변경된 의심 상태: \(state.isSuspicious)")
    }
        
    func toggleCommentSheet(for post: Post) {
        postUIStates[post.postUuid]?.showCommentSheet.toggle()
    }
}
