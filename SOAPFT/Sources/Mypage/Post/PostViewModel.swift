//
//  PostViewModel.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/3/25.
//

import Foundation

class PostViewModel: ObservableObject {
    @Published var posts: [PostModel] = []
    @Published var page: Int = 1
    @Published var isLoading: Bool = false
    
    let limit = 10
    
    func fetchPosts() {
        guard !isLoading else { return }
        isLoading = true
        
        // MARK: 네트워크 요청
        let urlString = "api/post/my?page=\(page)&limit=\(limit)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                defer { self.isLoading = false }
                
                guard let data = data,
                      let decoded = try? JSONDecoder().decode(PostResponse.self, from: data) else { return }
                        
                        self.posts.append(contentsOf: decoded.posts)
                        self.page += 1
            }
        }.resume()
    }
    
    // MARK: 목업 데이터
    func loadMockData() {
        self.posts = (1...9).map { index in
            PostModel(
                id: UUID().uuidString,
                title: "테스트 게시물 \(index)",
                content: "푸시업 완료! \n푸시업바 뒤에 보이시죠?",
                imageUrl: ["https://velog.velcdn.com/images/mazorika/post/bb01b28d-8759-4846-8550-a7cbccc1a600/image.jpeg"]
            )
        }
    }
}
