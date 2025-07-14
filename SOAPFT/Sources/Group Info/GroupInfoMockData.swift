//
//  GroupInfoMock.swift
//  SOAPFT
//
//  Created by 바견규 on 6/30/25.
//

let GroupInfoMockData = ChallengeDetailResponse(
    id: 1,
    challengeUuid: "mock-challenge-uuid",
    title: "모의 챌린지 제목",
    type: "HEALTH",
    profile: "https://example.com/profile.png",
    banner: "https://example.com/banner.png",
    introduce: "이 챌린지는 건강을 위한 모의 챌린지입니다.",
    verificationGuide: "사진을 인증해주세요.",
    startDate: "2025-07-14T00:00:00.000Z",
    endDate: "2025-08-01T00:00:00.000Z",
    goal: 3,
    startAge: 20,
    endAge: 35,
    gender: "ALL",
    maxMember: 10,
    creatorUuid: "user-1234",
    participantUuid: ["user-1234", "user-5678", "user-9101"],
    coinAmount: 100,
    isStarted: true,
    isFinished: false,
    isParticipated: true,
    successParticipantsUuid: ["user-1234"],
    createdAt: "2025-06-25T00:00:00.000Z",
    updatedAt: "2025-06-30T00:00:00.000Z",
    participants: [
        Participant(userUuid: "user-1234", nickname: "방장", profileImage: "https://example.com/creator.png"),
        Participant(userUuid: "user-5678", nickname: "참가자1", profileImage: "https://example.com/user1.png"),
        Participant(userUuid: "user-9101", nickname: "참가자2", profileImage: "https://example.com/user2.png")
    ]
)

extension ChallengeDetailResponse {
    static var errorMock: ChallengeDetailResponse {
        return ChallengeDetailResponse(
            id: -1,
            challengeUuid: "error",
            title: "불러오기 실패",
            type: "unknown",
            profile: nil,
            banner: nil,
            introduce: "챌린지 데이터를 불러올 수 없습니다.",
            verificationGuide: "",
            startDate: "",
            endDate: "",
            goal: 0,
            startAge: 0,
            endAge: 0,
            gender: "none",
            maxMember: 0,
            creatorUuid: "error",
            participantUuid: [],
            coinAmount: 0,
            isStarted: false,
            isFinished: false,
            isParticipated: false,
            successParticipantsUuid: [],
            createdAt: nil,
            updatedAt: nil,
            participants: []
        )
    }

    var isError: Bool {
        self.challengeUuid == "error"
    }
}
