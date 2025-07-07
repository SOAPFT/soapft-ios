//
//  UserResponse.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/7/25.
//

import Foundation

// 온보딩 정보 입력
struct SignupResponseDTO: Decodable {
    let statusCode: Int
    let message: String
}

// 로그아웃
struct LogoutResponseDTO: Decodable {
    let message: String
}

// 프로필 수정
struct ProfileUpdateResponseDTO: Decodable {
    let message: String
}

// 계정 삭제
struct UserDeleteResponseDTO: Decodable {
    let message: String
}

// 사용자 정보 조회 (본인)
struct MyProfileResponseDTO: Decodable {
    let userName: String?
    let userImage: String?
    let userIntroduction: String
    let userUuid: String
    let coins: Int
    let postCount: Int
    let friendCount: Int
}

// 다른 사용자 정보 조회
struct OtherUserProfileResponseDTO: Decodable {
    let userName: String
    let userImage: String
    let userIntroduction: String
    let userUuid: String
    let postCount: Int
    let friendCount: Int
}

