//
//  ChallengeStatisticsViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 7/3/25.
//

// ChallengeStatisticsViewModel.swift
import Foundation
import SwiftUI

final class ChallengeStatisticsViewModel: ObservableObject {
    @Published var data: ChallengeStatisticsData

    init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let certifiedCount: [Date: Int] = [
            formatter.date(from: "2024-10-04")!: 2,
            formatter.date(from: "2024-10-12")!: 7,
            formatter.date(from: "2024-10-13")!: 1
        ]

        let certifiedMembers: [Date: [Member]] = [
            formatter.date(from: "2024-10-04")!: [
                Member(name: "홍길동", profileImage: "https://randomuser.me/api/portraits/men/1.jpg"),
                Member(name: "김민지", profileImage: "https://randomuser.me/api/portraits/women/1.jpg")
            ],
            formatter.date(from: "2024-10-12")!: [
                Member(name: "이수민", profileImage: "https://randomuser.me/api/portraits/women/2.jpg")
            ],
            formatter.date(from: "2024-10-13")!: [
                Member(name: "최우진", profileImage: "https://randomuser.me/api/portraits/men/2.jpg")
            ]
        ]

        self.data = ChallengeStatisticsData(
            goalCompletionRate: 40,
            challengeStartDate: "2025-07-01",
            challengeEndDate: "2025-07-31",
            currentMember: 30,
            goal: 1,
            certifiedCount: certifiedCount,
            certifiedMembers: certifiedMembers
        )
    }
}
