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
    @Published var filteredChallenges: [ChallengSearchModel] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        // 검색어가 변경될 때마다 필터링
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.filterChallenges(by: text)
            }
            .store(in: &cancellables)

        // 초기 값
        filteredChallenges = ChallengSearchMockData
    }

    private func filterChallenges(by keyword: String) {
        if keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filteredChallenges = []  // 검색어 없으면 빈 배열
        } else {
            filteredChallenges = ChallengSearchMockData.filter {
                $0.title.localizedCaseInsensitiveContains(keyword)
            }
        }
    }

}
