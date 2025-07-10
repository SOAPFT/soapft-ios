//
//  HomeModel.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import Foundation

struct UserChallenge: Codable, Identifiable {
    let id: Int
    let uuid: String
    let title: String
    let status: Status
    let currentMembers: Int
    let maxMembers: Int
    let startDate: String
    let endDate: String

    enum CodingKeys: String, CodingKey {
        case id = "challengeId"
        case uuid = "challengeUuid"
        case title
        case status
        case currentMembers
        case maxMembers
        case startDate
        case endDate
    }

    enum Status: String, Codable {
        case inProgress = "IN_PROGRESS"
        case completed = "COMPLETED"
        case upcoming = "UPCOMING"
    }
}


//toggle
enum ChallengeTab: String, CaseIterable {
    case inProgress = "진행 중"
    case upcoming = "진행 예정"
}
