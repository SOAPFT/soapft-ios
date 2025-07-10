//
//  GroupInfoModel.swift
//  SOAPFT
//
//  Created by 바견규 on 6/30/25.
//

import Foundation


struct ChallengeDetail: Decodable {
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
    let currentMember: Int
    let coinAmount: Int
    let isStarted: Bool
    let isFinished: Bool
    let creator: Creator
    let participants: [Participant]
    let isParticipating: Bool
    let createdAt: String
    let updatedAt: String
}


struct Creator: Decodable {
    let userUuid: String
    let nickname: String
    let profileImage: String
}

struct Participant: Decodable {
    let userUuid: String
    let nickname: String
    let profileImage: String
    let joinedAt: String
}
