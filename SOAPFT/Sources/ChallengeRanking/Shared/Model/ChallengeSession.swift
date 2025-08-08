//
//  ChallengeSession.swift
//  SOAPFT
//
//  Created by 바견규 on 8/7/25.
//

// Shared/Models/ChallengeSession.swift

import Foundation

public struct ChallengeSession: Codable, Equatable {
    public let duration: Int
    public let missionType: String
    public let top3: [RankUserDTO]
    public let others: [RankUserDTO]
    
    public init(duration: Int, missionType: String, top3: [RankUserDTO], others: [RankUserDTO]) {
        self.duration = duration
        self.missionType = missionType
        self.top3 = top3
        self.others = others
    }
}
