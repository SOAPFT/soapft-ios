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
    @Published var postUIStates: [String: PostUIState] = [:] // key = postUuid
    @Published var isLoading = false
    
    private let postService: PostService
    private let likeService: LikeService
    private let challengeId: String
    private var currentPage: Int = 1
    
    init(postService: PostService, likeServie: LikeService, challengeId: String){
        self.postService = postService
        self.challengeId = challengeId
        self.likeService = likeServie
        fetchPosts()
    }
    

    private var cancellables = Set<AnyCancellable>()

    func fetchPosts() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.postService.getChallengePosts(challengeId: self.challengeId, page: self.currentPage, limit: 10) { [weak self] (result: Result<ChallengePostsResponseDTO, Error>) in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    switch result {
                    case .success(let ChallengePostsResponseDTO):
                        self.posts.append(contentsOf: ChallengePostsResponseDTO.posts)
                        // 상태 초기화는 posts가 업데이트된 이후에 실행
                        self.currentPage += 10
                        let newStates = ChallengePostsResponseDTO.posts.reduce(into: self.postUIStates) { dict, post in
                            dict[post.postUuid] = PostUIState()
                        }
                        self.postUIStates = newStates
                        self.isLoading = false
                    case .failure(let error):
                        print("챌린지 불러오기 실패: \(error)")
                        self.isLoading = false
                    }
                }
            }
            
           
        }
    }

    func toggleLike(for post: ChallengePost) {
        guard let state = postUIStates[post.postUuid] else { return }
        state.isLiked.toggle()
    }

    func toggleSuspicion(for post: ChallengePost) {
        guard let state = postUIStates[post.postUuid] else { return }
        state.isSuspicious.toggle()
    }

    func toggleCommentSheet(for post: ChallengePost) {
        guard let state = postUIStates[post.postUuid] else { return }
        state.showCommentSheet.toggle()
    }
}

// MARK: - 시간 포맷팅 헬퍼
func timeAgoString(from isoDateString: String) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    guard let date = formatter.date(from: isoDateString) else {
        return "알 수 없음"
    }

    let now = Date()
    let secondsAgo = Int(now.timeIntervalSince(date))
    
    switch secondsAgo {
    case ..<60:
        return "방금 전"
    case 60..<3600:
        return "\(secondsAgo / 60)분 전"
    case 3600..<86400:
        return "\(secondsAgo / 3600)시간 전"
    case 86400..<172800:
        return "어제"
    default:
        return "\(secondsAgo / 86400)일 전"
    }
}
