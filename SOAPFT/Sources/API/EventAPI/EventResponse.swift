//
//  EventResponse.swift
//  SOAPFT
//
//  Created by 바견규 on 8/4/25.
//

import Foundation

// MARK: - 기본 미션 모델
struct Mission: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let description: String
    let type: MissionType
    let startTime: String
    let endTime: String
    let durationSeconds: Int?
    let reward: Int
    let isLongTerm: Bool?
    let createdAt: String
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, type, startTime, endTime, durationSeconds, reward, isLongTerm, createdAt, status
    }
}

// MARK: - 미션 타입
enum MissionType: String, Codable, CaseIterable {
    case distance = "distance"
    case steps = "steps"
    case calories = "calories"
    
    var displayName: String {
        switch self {
        case .distance: return "런닝"
        case .steps: return "걸음 수"
        case .calories: return "칼로리"
        }
    }
    
    var unit: String {
        switch self {
        case .distance: return "km"
        case .steps: return "보"
        case .calories: return "kcal"
        }
    }
}

// MARK: - 1. 전체 이벤트 조회 응답
typealias MissionListResponse = [Mission]

// MARK: - 2. 이벤트 상세 조회 응답
struct MissionDetailResponse: Codable {
    let mission: Mission
    let isParticipating: Bool
    let myResult: Int?
    let myRank: Int?
    let myName: String?
    let myProfileImage: String? 
    let rankings: [RankingEntry]
    let status: String?
}

struct RankingEntry: Codable, Identifiable {
    let id = UUID() // 로컬에서 사용할 ID
    let userUuid: String      // userUuuid → userUuid로 변경
    let name: String          // userNickname → name으로 변경
    let profileImage: String? // profileImageUrl → profileImage로 변경
    let result: Int           // MissionResult → Int로 변경 (300)
    
    enum CodingKeys: String, CodingKey {
        case userUuid, name, profileImage, result
    }
    
    // 편의 프로퍼티: 랭킹 순서는 배열 인덱스 + 1로 계산
    var displayRank: Int {
        // 실제 사용 시에는 배열에서의 인덱스를 기반으로 계산됩니다
        return 1 // 기본값, 실제로는 뷰에서 설정됩니다
    }
}

// MARK: - 3. 이벤트 참여 응답
struct MissionParticipationResponse: Codable {
    let id: Int
    let userUuid: String
    let missionId: Int
    let joinedAt: String
    let completed: Bool
    let resultData: Int?
    let createdAt: String
}

// MARK: - 4. 내 미션목록 조회 응답
struct MyMission: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let type: MissionType
    let startTime: Date
    let endTime: Date
    let reward: Int
    let status: String // 서버에서 한국어로 오는 상태
    
}

typealias MyMissionListResponse = [MyMission]

// MARK: - 5. 미션 결과 제출 응답
struct MissionSubmissionResponse: Codable {
    let id: Int
    let userUuid: String
    let missionId: Int
    let joinedAt: String
    let completed: Bool
    let resultData: Int
    let createdAt: String
}

// MARK: - 6. 미션 참여 취소 응답
struct MissionCancellationResponse: Codable {
    let message: String
}


// MARK: - API 에러 응답
struct APIError: Codable, Error {
    let message: String
    let code: String?
    let details: String?
}



// MARK: - 확장: TimeInterval 포맷팅
extension TimeInterval {
    var formattedTimeRemaining: String {
        let totalSeconds = Int(self)
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if days > 0 {
            return "\(days)일 \(hours)시간"
        } else if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        } else {
            return "\(minutes)분"
        }
    }
}
