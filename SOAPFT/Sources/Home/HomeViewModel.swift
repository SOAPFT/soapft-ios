//
//  HomeViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published var selectedTab: ChallengeTab = .inProgress
    @Published var challenges: [UserChallenge] = []
    @Published var isLoading: Bool = false

    var filteredChallenges: [UserChallenge] {
        switch selectedTab {
        case .inProgress:
            return challenges.filter { $0.status.rawValue == "IN_PROGRESS" }
        case .upcoming:
            return challenges.filter { $0.status.rawValue == "UPCOMING" }
        }
    }
    
    init(useMock: Bool = false) {
        if useMock {
            self.challenges = ChallengesMockdata
        }
    }
}
