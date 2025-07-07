//
//  LikeResponse.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/7/25.
//

import Foundation

// 게시글에 좋아요 추가 DTO
struct LikeAddResponseDTO: Decodable {
    let id: Int
    let likeCount: Int
}

// 좋아요 취소 DTO
struct LikeCancelResponseDTO: Decodable {
    let success: Bool
    let likeCount: Int
}

// 좋아요 상태 확인 DTO
struct LikeStatusResponseDTO: Decodable {
    let liked: Bool
}
