//
//  CertificationModel.swift
//  SOAPFT
//
//  Created by 바견규 on 7/2/25.
//

import SwiftUI
import Combine


struct ChallengePostData: Decodable {
    let posts: [ChallengePost]
    let pagination: Pagination
}

struct ChallengePost: Decodable, Identifiable {
    var id: String { postUuid }

    let postUuid: String
    let content: String
    let imageUrl: [String]
    let likeCount: Int
    let commentCount: Int
    let createdAt: String
    let author: PostAuthor
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


//MARK: - 게시물 PostUIState 모델
class PostUIState: ObservableObject {
    @Published var isLiked: Bool = false
    @Published var isSuspicious: Bool = false
    @Published var showCommentSheet: Bool = false
}
