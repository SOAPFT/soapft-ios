//
//  GroupInfoViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 6/30/25.
//

import Foundation
import SwiftUI

final class GroupInfoViewModel: ObservableObject {
    
    // 챌린지 API 서비스
    private let challengeService: ChallengeService
    
    // 챌린지 ID
    @Published var id: String
    
    // MARK: - 검색 텍스트
    @Published var searchText: String = ""
    
    // MARK: challenge
    @Published var challenge: ChallengeDetailResponse = .errorMock
    @Published var filteredParticipants: [Participant] = []
    @Published var creator: Participant?
    
    init(challengeService: ChallengeService, id: String) {
        self.challengeService = challengeService
        self.id = id
        
        self.challengeService.getChallengeDetail(id: id) { [weak self] (result: Result<ChallengeDetailResponse, Error>) in
                    guard let self = self else { return }

                    DispatchQueue.main.async {
                        switch result {
                        case .success(var challenge):
                            // creatorUuid와 일치하는 participant를 찾아서 pop
                            if let index = challenge.participants.firstIndex(where: { $0.userUuid == challenge.creatorUuid }) {
                                self.creator = challenge.participants.remove(at: index)
                            }

                            self.challenge = challenge
                            self.filterMembers()
                        case .failure(let error):
                            print("챌린지 불러오기 실패: \(error)")
                        }
                    }
                }
    }
    
    // MARK: - Logic
    func filterMembers() {
        if searchText.isEmpty {
            filteredParticipants = challenge.participants
        } else {
            filteredParticipants = challenge.participants.filter {
                ($0.nickname ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    

}
