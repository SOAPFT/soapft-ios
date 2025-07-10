//
//  ChallengeResponse.swift
//  SOAPFT
//
//  Created by 바견규 on 7/7/25.
//

import Foundation

// MARK: -  공통 챌린지 모델
struct Challenge: Decodable {
    let id: Int?
    let challengeUuid: String
    let title: String
    let type: String?
    let profile: String?
    let banner: String?
    let introduce: String?
    let verificationGuide: String?
    let startDate: String
    let endDate: String
    let goal: Int?
    let startAge: Int?
    let endAge: Int?
    let gender: String?
    let maxMember: Int?
    let currentMember: Int?
    let creatorUuid: String?
    let participantUuid: [String]?
    let coinAmount: Int?
    let isStarted: Bool
    let isFinished: Bool
    let isParticipating: Bool?
    let successParticipantsUuid: [String]?
    let createdAt: String?
    let updatedAt: String?
}

// MARK: - 사용자 참여 챌린지 목록 응답

struct ParticipatedChallengesResponse: Decodable {
    let success: Bool
    let data: [ChallengeSummary]
}

struct ChallengeSummary: Decodable {
    let challengeId: Int
    let challengeUuid: String
    let title: String
    let status: String
    let currentMembers: Int
    let maxMembers: Int
    let startDate: String
    let endDate: String
}

// MARK: - 챌린지 생성 응답
struct ChallengeCreationResponse: Decodable {
    let challengeUuid: String
    let message: String
}

// MARK: - 챌린지 목록 조회 + 메타 포함
struct ChallengeListWithMetaResponse: Decodable {
    let data: [Challenge]
    let meta: Meta
}

struct Meta: Decodable {
    let total: Int
    let page: Int
    let limit: Int
    let totalPages: Int
    let hasNextPage: Bool
}

// MARK: - 챌린지 상세 응답
struct ChallengeDetailResponse: Decodable {
    let challengeUuid: String
    let title: String
    let type: String
    let profile: String
    let banner: String
    let introduce: String
    let startDate: String
    let endDate: String
    let goal: Int
    let startAge: Int
    let endAge: Int
    let gender: String
    let maxMember: Int
    let coinAmount: Int
    let isStarted: Bool
    let isFinished: Bool
    let creatorUuid: String
    let isParticipating: Bool
    let createdAt: String
    let updatedAt: String
    
}

// MARK: - 챌린지 수정 응답
struct ChallengeUpdateResponse: Decodable {
    let message: String
    let challenge: Challenge
}
// MARK: - 챌린지 참여 응답
struct ChallengeJoinResponse: Decodable {
    let message: String
    let challengeUuid: String
}
// MARK: - 챌린지 탈퇴 응답
struct ChallengeLeaveResponse: Decodable {
    let message: String
}
// MARK: - 챌린지 진행률 응답
struct ChallengeProgressResponse: Decodable {
    let challengeInfo: ChallengeInfo
    let totalAchievementRate: Int
}

struct ChallengeInfo: Decodable {
    let participantCount: Int
    let startDate: String
    let endDate: String
}

// MARK: - 챌린지 완료 개수 응답
struct CompletedChallengeCountResponse: Decodable {
    let completedChallengeCount: Int
}

// MARK: - 월별 인증 현황 응답
struct MonthlyVerificationResponse: Decodable {
    let data: [String: DailyVerification]
}

struct DailyVerification: Decodable {
    let count: Int
    let users: [VerifiedUser]
}

struct VerifiedUser: Decodable {
    let userUuid: String
    let nickname: String
    let profileImage: String
}


