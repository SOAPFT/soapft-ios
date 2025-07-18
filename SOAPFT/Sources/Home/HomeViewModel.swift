//
//  HomeViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    private let challengeService: ChallengeService

    @Published var selectedTab: ChallengeTab = .inProgress
    @Published var challenges: [Challenge] = []
    @Published var isLoading: Bool = false
    @Published var completedChallengeCount: Int = -1

    init(challengeService: ChallengeService) {
        self.challengeService = challengeService
        fetchChallenges()
    }

    func fetchChallenges() {
        isLoading = true
        
        let group = DispatchGroup()
        
        group.enter()
        challengeService.getParticipatedChallenges(status: "all") { [weak self] result in
            defer { group.leave() }
            DispatchQueue.main.async {
                switch result {
                case .success(let challenges):
                    self?.challenges = challenges
                case .failure(let error):
                    print("챌린지 불러오기 실패: \(error)")
                }
            }
        }

        group.enter()
        challengeService.getCompletedChallengeCount { [weak self] result in
            defer { group.leave() }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.completedChallengeCount = data.completedChallengeCount
                case .failure(let error):
                    print("완료된 챌린지 수 불러오기 실패: \(error)")
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
        }
    }

    var filteredChallenges: [Challenge] {
        switch selectedTab {
        case .inProgress:
            return challenges.filter { $0.status == "ongoing" }
        case .upcoming:
            return challenges.filter { $0.status == "upcoming" }
        }
    }
}

