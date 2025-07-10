//
//  C.swift
//  SOAPFT
//
//  Created by 바견규 on 7/1/25.
//

// ChallengeDetailViewModel.swift
import Foundation
import Combine


final class ChallengeSignUpViewModel: ObservableObject {
    @Published var challenge: ChallengeDetailResponse
    @Published var isJoinCompleted: Bool = false
    @Published var errorMessage: String? = nil

    init(mockData: ChallengeDetailResponse) {
        self.challenge = mockData
    }

    // 가입 가능한 상태인지 판단
    var isJoinable: Bool {
        !challenge.isParticipated && !challenge.isStarted && challenge.currentMembers < challenge.maxMember
    }

    // 가입 신청 처리
    func applyToChallenge() {
        guard isJoinable else {
            errorMessage = "신청할 수 없는 상태입니다."
            return
        }

        // 이 부분은 추후 네트워크 API 연동 시 실제 호출 로직으로 교체
        print("✅ 챌린지 가입 신청 실행됨!")
        isJoinCompleted = true
    }
}

