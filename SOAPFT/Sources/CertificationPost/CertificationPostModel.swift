//
//  CertificationModel.swift
//  SOAPFT
//
//  Created by 바견규 on 7/2/25.
//

import SwiftUI
import Combine

struct ChallengePostData: Decodable {
    let posts: [Post]
    let pagination: Pagination
}

struct PostAuthor: Decodable {
    let userUuid: String
    let nickname: String
    let profileImage: String
}

struct Pagination: Decodable {
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let itemsPerPage: Int
}

// MARK: - 게시물 PostUIState 모델
class PostUIState: ObservableObject {
    @Published var isLiked: Bool = false
    @Published var isSuspicious: Bool = false
    @Published var showCommentSheet: Bool = false
    
    private let postUuid: String
    
    init(postUuid: String, likeService: LikeService) {
        self.postUuid = postUuid
        
        print("🔄 PostUIState 초기화 - PostUUID: \(postUuid)")
        
        // 좋아요 상태 불러오기
        likeService.checkLikeStatus(postId: postUuid, completion: { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.isLiked = response.liked
                    print("✅ 좋아요 상태 로드됨 - PostUUID: \(postUuid), liked: \(response.liked)")
                case .failure(let error):
                    print("❌ 좋아요 상태 조회 실패: \(error)")
                }
            }
        })

        // 의심 상태 불러오기 (API가 있다면)
        // suspiciousService.checkSuspiciousStatus(postId: postUuid) { [weak self] result in
        //     DispatchQueue.main.async {
        //         switch result {
        //         case .success(let response):
        //             self?.isSuspicious = response.suspicious
        //         case .failure(let error):
        //             print("❌ 의심 상태 조회 실패: \(error)")
        //         }
        //     }
        // }
        
        print("✅ PostUIState 초기화 완료 - PostUUID: \(postUuid)")
    }
}
