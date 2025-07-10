//
//  PostViewModel.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/3/25.
//

import Foundation

class PostViewModel: ObservableObject {
    var container: DIContainer!
    
    @Published var message: String = ""
    @Published var total: Int = 0
    @Published var page: Int = 1
    @Published var limit: Int = 15
    @Published var posts: [Post] = []
    @Published var isLoading: Bool = false
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func fetchPosts() {
        guard !isLoading else { return }
        isLoading = true
        
        guard let accessToken = KeyChainManager.shared.readAccessToken() else {
            print("❌ accessToken 없음")
            isLoading = false
            return
        }
        
//        let accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyVXVpZCI6IjAxSllLVk4xOE1DVzVCOUZaMVBQN1QxNFhTIiwiaWF0IjoxNzUxOTAzNDA0LCJleHAiOjE3NTQ0OTU0MDR9.eeETUYLQy_W14flyNrvkSkJQm4CfqfsbrtfN7dOssl8"
        
        container.postService.getMyPosts(page: page, limit: limit) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let myPost):
                    self.message = myPost.message
                    self.total = myPost.total
                    self.limit = myPost.limit
                    
                    // 중복 방지 필터링
                    let existingIds = Set(self.posts.map { $0.id })
                    let uniquePosts = myPost.posts.filter { !existingIds.contains($0.id)}
                    
                    self.posts.append(contentsOf: uniquePosts)
                    
                    if self.posts.count < myPost.total {
                        self.page += 1
                    }
                    
                    print("✅ 프로필 성공: \(myPost)")
                    print("✅ 게시글 개수: \(self.posts.count)/\(self.total)")
                    
                case .failure(let error):
                    print("❌ 프로필 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: 목업 데이터
//    func loadMockData() {
//        self.posts = (1...9).map { index in
//            PostModel(
//                id: UUID().uuidString,
//                title: "테스트 게시물 \(index)",
//                content: "푸시업 완료! \n푸시업바 뒤에 보이시죠?",
//                imageUrl: ["https://velog.velcdn.com/images/mazorika/post/bb01b28d-8759-4846-8550-a7cbccc1a600/image.jpeg"]
//            )
//        }
//    }
}
