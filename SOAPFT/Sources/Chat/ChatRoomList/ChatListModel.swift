    //
    //  ChatModel.swift
    //  SOAPFT
    //
    //  Created by 바견규 on 6/28/25.
    //

    import Foundation

    struct ChatRoomDTO: Codable {
        let roomUuid: String
        let type: String
        let name: String
        let participants: [ParticipantDTO]
        let challenge: ChallengeDTO?
        let myRole: String
        let settings: ChatRoomSettingsDTO
        let createdAt: Date
        let updatedAt: Date
    }

    struct ParticipantDTO: Codable {
        let userUuid: String
        let nickname: String
        let profileImage: String?
        let isOnline: Bool
        let lastSeenAt: Date
        let joinedAt: Date
    }

    struct ChallengeDTO: Codable {
        let challengeUuid: String
        let title: String
        let isActive: Bool
    }

    struct ChatRoomSettingsDTO: Codable {
        let isPinned: Bool
        let isMuted: Bool
        let notificationEnabled: Bool
    }


