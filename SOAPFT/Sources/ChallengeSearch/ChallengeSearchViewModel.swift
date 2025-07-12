//
//  ChallengeSearchViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 7/3/25.
//

import Foundation
import Combine

final class ChallengeSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var filteredChallenges: [Challenge] = []

    private let challengeService: ChallengeService
    private var cancellables = Set<AnyCancellable>()

    init(challengeService: ChallengeService) {
        self.challengeService = challengeService
        
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] keyword in
                self?.fetchChallenges(keyword: keyword)
            }
            .store(in: &cancellables)
    }

    private func fetchChallenges(keyword: String) {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            self.filteredChallenges = []
            return
        }

        challengeService.searchChallenges(keyword: trimmed, page: 1, limit: 15) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let challenges):
                    self?.filteredChallenges = challenges
                case .failure(let error):
                    print("검색 실패: \(error.localizedDescription)")
                    self?.filteredChallenges = []
                }
            }
        }
    }
}

