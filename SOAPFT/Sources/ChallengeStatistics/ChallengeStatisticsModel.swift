//
//  ChallengeStatisticsModel.swift
//  SOAPFT
//
//  Created by 바견규 on 7/3/25.
//

// ChallengeStatisticsModel.swift
import Foundation

struct Member: Identifiable {
    let id: String
    let name: String
    let profileImage: String
}

struct ChallengeStatisticsData {
    let goalCompletionRate: Int
    let challengeStartDate: String
    let challengeEndDate: String
    let currentMember: Int
    let goal: Int
    let certifiedCount: [Date: Int]
    let certifiedMembers: [Date: [Member]]
}
