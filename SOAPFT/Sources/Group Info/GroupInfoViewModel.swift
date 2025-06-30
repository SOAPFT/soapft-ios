//
//  GroupInfoViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 6/30/25.
//

import Foundation
import SwiftUI

final class GroupInfoViewModel: ObservableObject {
    // MARK: - Input
    @Published var searchText: String = ""

    // MARK: - Output
    @Published var challenge: ChallengeDetailResponse
    @Published var filteredParticipants: [Participant] = []

    var hostUuid: String {
        challenge.creator.userUuid
    }

    init(challenge: ChallengeDetailResponse) {
        self.challenge = challenge
        self.filteredParticipants = challenge.participants
    }

    // MARK: - Logic
    func filterMembers() {
        if searchText.isEmpty {
            filteredParticipants = challenge.participants
        } else {
            filteredParticipants = challenge.participants.filter {
                $0.nickname.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
