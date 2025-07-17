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
    @Published var challenge: ChallengeDetailResponse = .errorMock
    @Published var isJoinCompleted: Bool = false
    @Published var errorMessage: String? = nil
    @Published var creator: Participant?
    
    // 챌린지 API 서비스
    private let challengeService: ChallengeService
    // 챌린지 ID
    @Published var id: String

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
                        case .failure(let error):
                            print("챌린지 불러오기 실패: \(error)")
                        }
                    }
                }
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


