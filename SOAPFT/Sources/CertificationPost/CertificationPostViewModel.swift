//
//  CertificationViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 7/2/25.
//

// MARK: - ViewModel
import SwiftUI
import Combine

class CertificationPostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var postUIStates: [String: PostUIState] = [:]
    @Published var isLoading = false
    @Published var hasMore = true
    
    private let postService: PostService
    private let likeService: LikeService
    private let challengeId: String
    var currentPage: Int = 1
    private let limit: Int = 10
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var commentCounts: [String: Int] = [:]
    
    init(postService: PostService, likeServie: LikeService, challengeId: String){
        self.postService = postService
        self.challengeId = challengeId
        self.likeService = likeServie
        fetchPosts()
    }
    
    func fetchPosts(refresh: Bool = false) {
        guard let accessToken = KeyChainManager.shared.read(forKey: "accessToken") else {
            print("❌ accessToken 없음")
            return
        }

        if refresh {
            self.currentPage = 1
            self.posts.removeAll()
            self.hasMore = true
        }

        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.postService.getChallengePosts(
                challengeId: self.challengeId,
                page: self.currentPage,
                limit: 10,
                accessToken: accessToken
            ) { [weak self] (result: Result<ChallengePostsResponseDTO, Error>) in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    self.isLoading = false
                    switch result {
                    case .success(let response):
                        self.posts.append(contentsOf: response.posts)

                        // 다음 페이지 증가
                        self.currentPage += 1

                        // 더 가져올 게 없으면 hasMore false
                        self.hasMore = response.posts.count == self.limit

                        // 상태 추가
                        for post in response.posts {
                            if self.postUIStates[post.postUuid] == nil {
                                self.postUIStates[post.postUuid] = PostUIState(
                                    postUuid: post.postUuid,
                                    likeService: self.likeService
                                )
                            }
                        }

                    case .failure(let error):
                        print("챌린지 불러오기 실패: \(error)")
                        self.hasMore = false
                    }
                }
            }
        }
    }


        
    func toggleLike(for post: Post) {
        guard let state = postUIStates[post.postUuid],
              let index = posts.firstIndex(where: { $0.postUuid == post.postUuid }) else { return }

        if state.isLiked {
            likeService.unlike(postId: post.postUuid) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        state.isLiked = false
                        self.posts[index].likeCount = response.likeCount
                    case .failure(let error):
                        print("❌ 좋아요 취소 실패: \(error)")
                    }
                }
            }
        } else {
            likeService.like(postId: post.postUuid) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        state.isLiked = true
                        self.posts[index].likeCount = response.likeCount
                    case .failure(let error):
                        print("❌ 좋아요 추가 실패: \(error)")
                    }
                }
            }
        }
    }
    
        
    func toggleSuspicion(for post: Post) {
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
