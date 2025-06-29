//
//  MockChatRooms.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import Foundation

let mockChatRooms: [ChatRoomDTO] = [
    ChatRoomDTO(
        roomUuid: "01ABCDE1234567890",
        type: "DIRECT",
        name: "운동러버, 헬스마니아",
        participants: [
            ParticipantDTO(
                userUuid: "01USER1",
                nickname: "운동러버",
                profileImage: "https://example.com/profile1.jpg",
                isOnline: true,
                lastSeenAt: Date(),
                joinedAt: Date()
            ),
            ParticipantDTO(
                userUuid: "01USER2",
                nickname: "헬스마니아",
                profileImage: "https://example.com/profile2.jpg",
                isOnline: false,
                lastSeenAt: Date(),
                joinedAt: Date()
            )
        ],
        challenge: ChallengeDTO(
            challengeUuid: "01CHALLENGE1",
            title: "30일 헬스 챌린지",
            isActive: true
        ),
        myRole: "PARTICIPANT",
        settings: ChatRoomSettingsDTO(
            isPinned: false,
            isMuted: false,
            notificationEnabled: true
        ),
        createdAt: Date(),
        updatedAt: Date()
    )
]
