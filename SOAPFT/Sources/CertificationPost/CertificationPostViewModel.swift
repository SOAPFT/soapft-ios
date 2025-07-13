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
    @Published var posts: [ChallengePost] = []
    @Published var postUIStates: [String: PostUIState] = [:]
    @Published var isLoading = false
    @Published var hasMore = true
    
    private let postService: PostService
    private let likeService: LikeService
    private let challengeId: String
    private var currentPage: Int = 1
    private let limit: Int = 10
    
    private var cancellables = Set<AnyCancellable>()
    
    init(postService: PostService, likeServie: LikeService, challengeId: String){
        self.postService = postService
        self.challengeId = challengeId
        self.likeService = likeServie
        fetchPosts()
    }
    
    func fetchPosts() {
        guard let accessToken = KeyChainManager.shared.read(forKey: "accessToken") else {
            print("❌ accessToken 없음")
            return
        }
        
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.postService.getChallengePosts(challengeId: self.challengeId, page: self.currentPage, limit: 10, accessToken: accessToken) { [weak self] (result: Result<ChallengePostsResponseDTO, Error>) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch result {
                    case .success(let response):
                        self.posts.append(contentsOf: response.posts)
                        
                        // 다음 페이지 요청을 위한 증가
                        self.currentPage += 1
                        
                        // 더 가져올 게 없으면 hasMore false
                        self.hasMore = response.posts.count == self.limit
                        
                        // 상태 추가 (기존 상태는 유지하고 누락된 것만 추가)
                        for post in response.posts {
                            if self.postUIStates[post.postUuid] == nil {
                                self.postUIStates[post.postUuid] = PostUIState()
                            }
                        }
                    case .failure(let error):
                        print("챌린지 불러오기 실패: \(error)")
                        self.hasMore = false
                    }
                }
            }
        }
        
        func toggleLike(for post: ChallengePost) {
            postUIStates[post.postUuid]?.isLiked.toggle()
        }
        
        func toggleSuspicion(for post: ChallengePost) {
            postUIStates[post.postUuid]?.isSuspicious.toggle()
        }
        
        func toggleCommentSheet(for post: ChallengePost) {
            postUIStates[post.postUuid]?.showCommentSheet.toggle()
        }
    }
}
