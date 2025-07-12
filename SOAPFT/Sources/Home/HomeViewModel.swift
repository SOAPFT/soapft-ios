//
//  HomeViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    // 챌린지 API 서비스
    private let challengeService: ChallengeService

    
    @Published var selectedTab: ChallengeTab = .inProgress
    @Published var challenges: [Challenge] = []
    @Published var isLoading: Bool = false
    

    init(challengeService: ChallengeService) {
        self.challengeService = challengeService

        self.challengeService.getParticipatedChallenges(status: "all") { [weak self] (result: Result<[Challenge], Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let challenges):
                    self.challenges = challenges
                case .failure(let error):
                    print("챌린지 불러오기 실패: \(error)")
                }
            }
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
