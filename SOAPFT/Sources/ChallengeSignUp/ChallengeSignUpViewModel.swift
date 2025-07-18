//
//  C.swift
//  SOAPFT
//
//  Created by 바견규 on 7/1/25.
//

// ChallengeDetailViewModel.swift
import Foundation
import Combine
import Alamofire


final class ChallengeSignUpViewModel: ObservableObject {
    @Published var challenge: ChallengeDetailResponse = .errorMock
    @Published var isJoinCompleted: Bool = false
    @Published var errorMessage: String? = nil
    @Published var toastMessage: String? = nil
    @Published var creator: Participant?

    private let navigationRouter: AppRouter
    private let challengeService: ChallengeService
    @Published var id: String

    init(challengeService: ChallengeService, navigationRouter: AppRouter, id: String) {
        self.challengeService = challengeService
        self.navigationRouter = navigationRouter
        self.id = id
        
        self.challengeService.getChallengeDetail(id: id) { [weak self] (result: Result<ChallengeDetailResponse, Error>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(var challenge):
                    if let index = challenge.participants.firstIndex(where: { $0.userUuid == challenge.creatorUuid }) {
                        self.creator = challenge.participants.remove(at: index)
                    }
                    self.challenge = challenge
                case .failure(let error):
                    print("챌린지 불러오기 실패: \(error)")
                    self.toastMessage = "챌린지를 불러오지 못했습니다."
                }
            }
        }
    }

    var isJoinable: Bool {
        !challenge.isParticipated && !challenge.isStarted && challenge.currentMembers < challenge.maxMember
    }

    func applyToChallenge() {
        guard isJoinable else {
            toastMessage = "참가할 수 없는 상태입니다."
            return
        }

        challengeService.joinChallenge(id: challenge.challengeUuid) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.isJoinCompleted = true
                    self.toastMessage = response.message

                case .failure(let error):
                    print("챌린지 참가 실패: \(error)")

                    let nsError = error as NSError
                    if let data = nsError.userInfo["data"] as? Data,
                       let serverError = try? JSONDecoder().decode(ChallengeJoinErrorResponse.self, from: data) {
                        self.toastMessage = serverError.message
                        self.errorMessage = serverError.message
                    } else {
                        self.toastMessage = "참가 신청에 실패했습니다. 다시 시도해주세요."
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }



}
