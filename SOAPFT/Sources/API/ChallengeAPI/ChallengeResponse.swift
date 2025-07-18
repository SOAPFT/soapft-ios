//
//  ChallengeResponse.swift
//  SOAPFT
//
//  Created by 바견규 on 7/7/25.
//

import Foundation

// MARK: -  공통 챌린지 모델
struct Challenge: Decodable, Hashable {
    let id: Int
    let challengeUuid: String
    let title: String
    let type: String?
    let profile: String?
    let banner: String?
    let introduce: String?
    let verificationGuide: String?
    let startDate: String
    let endDate: String
    let goal: Int
    let startAge: Int?
    let endAge: Int?
    let gender: String
    let maxMember: Int
    let currentMember: Int?
    let creatorUuid: String?
    let participantUuid: [String]?
    let coinAmount: Int?
    let isStarted: Bool
    let isFinished: Bool
    let isParticipated: Bool?
    let successParticipantsUuid: [String]?
    let createdAt: String?
    let updatedAt: String?
    
    var status: String? {
        if isFinished {
            return "completed"
        } else if isStarted {
            return "ongoing"
        } else {
            return "upcoming"
        }
    }

    var currentMembers: Int? {
        participantUuid?.count
    }
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
    let page: String
    let limit: String
    let totalPages: Int
    let hasNextPage: Bool
}

// MARK: - 챌린지 상세 응답
struct ChallengeDetailResponse: Decodable {
    let id: Int
    let challengeUuid: String
    let title: String
    let type: String
    let profile: String?
    let banner: String?
    let introduce: String
    let verificationGuide: String
    let startDate: String
    let endDate: String
    let goal: Int
    let startAge: Int?
    let endAge: Int?
    let gender: String
    let maxMember: Int
    let creatorUuid: String
    let participantUuid: [String]
    let coinAmount: Int
    let isStarted: Bool
    let isFinished: Bool
    let isParticipated: Bool
    let successParticipantsUuid: [String]
    let createdAt: String?
    let updatedAt: String?
    var participants: [Participant]
    
    var currentMembers: Int {
        participantUuid.count
    }
    
    var status: String {
        if isFinished {
            return "completed"
        } else if isStarted {
            return "ongoing"
        } else {
            return "upcoming"
        }
    }
    
    //날짜 관련 확장
    private var isoFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }

    var startDateValue: Date? {
        isoFormatter.date(from: startDate)
    }

    var endDateValue: Date? {
        isoFormatter.date(from: endDate)
    }

    var startYear: Int? {
        startDateValue.map { Calendar.current.component(.year, from: $0) }
    }

    var startMonth: Int? {
        startDateValue.map { Calendar.current.component(.month, from: $0) }
    }

    var endYear: Int? {
        endDateValue.map { Calendar.current.component(.year, from: $0) }
    }

    var endMonth: Int? {
        endDateValue.map { Calendar.current.component(.month, from: $0) }
    }

    var currentYear: Int? {
        switch status {
        case "ongoing": return Calendar.current.component(.year, from: Date())
        case "upcoming": return startYear
        case "completed": return endYear
        default: return nil
        }
    }

    var currentMonth: Int? {
        switch status {
        case "ongoing": return Calendar.current.component(.month, from: Date())
        case "upcoming": return startMonth
        case "completed": return endMonth
        default: return nil
        }
    }
}

struct Participant: Decodable, Identifiable, Hashable {
    let userUuid: String
    let nickname: String?
    let profileImage: String?
    
    var id: String { userUuid }
}

struct Creator: Decodable {
    let userUuid: String
    let nickname: String?
    let profileImage: String?
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

struct ChallengeJoinErrorResponse: Decodable {
    let success: Bool
    let errorCode: String
    let message: String
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
typealias MonthlyVerificationResponse = [String: DailyVerification]

struct DailyVerification: Decodable {
    let count: Int
    let users: [VerifiedUser]
}

struct VerifiedUser: Decodable {
    let userUuid: String
    let nickname: String
    let profileImage: String?
}

// MARK: - 게시글 신고 응답
struct ReportResponse: Decodable {
    let message: String
}

// MARK: - 이미지 AI 검증 응답
struct PrecheckResponse: Decodable {
    let success: Bool
    let message: String
    let challengeInfo: ChallengeInfo_Precheck
    let verification: VerificationSummary
    let images: [VerifiedImage]
    let verificationToken: String
    let canCreatePost: Bool
    let recommendations: [String]
}


struct ChallengeInfo_Precheck: Decodable {
    let challengeUuid: String
    let title: String
    let verificationGuide: String
}

struct VerificationSummary: Decodable {
    let overallStatus: String
    let averageConfidence: Int
    let totalImages: Int
    let approvedImages: Int
    let rejectedImages: Int
    let reviewImages: Int
}

struct VerifiedImage: Decodable, Identifiable {
    var id: String { imageUrl } // SwiftUI ForEach 지원
    let imageUrl: String
    let originalName: String
    let status: String
    let confidence: Int
    let reasoning: String?
    let isRelevant: Bool
}

// MARK: - 게시글 생성 응답
struct CreatePostResponse: Decodable {
    let success: Bool
    let message: String
    let post: CreatedPost
}

struct CreatedPost: Decodable {
    let postUuid: String
    let userUuid: String
    let challengeUuid: String
    let content: String
    let imageUrl: [String]
    let isPublic: Bool
    let verificationStatus: String
    let aiConfidence: Int?
    let verifiedAt: String?
    let createdAt: String
    let updatedAt: String
    let title: String?
    let aiAnalysisResult: String?
    let id: Int
    let views: Int
}
