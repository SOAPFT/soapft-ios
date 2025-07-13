//
//  FriendsPostsViewModel.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/13/25.
//

import Foundation

class FriendsPostViewModel: ObservableObject {
    var container: DIContainer!
    private let userUUID: String
    
    @Published var message: String = ""
    @Published var total: Int = 0
    @Published var page: Int = 1
    @Published var limit: Int = 15
    @Published var posts: [Post] = []
    @Published var isLoading: Bool = false
    
    init(container: DIContainer, userUUID: String) {
        self.container = container
        self.userUUID = userUUID
    }
    
    func fetchPosts() {
        guard let accessToken = KeyChainManager.shared.read(forKey: "accessToken") else {
            print("❌ accessToken 없음")
            return
        }
        
        guard !isLoading else { return }
        isLoading = true
         
        container.postService.getMyPosts(page: page, limit: limit, accessToken: accessToken) { [weak self] result in
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
