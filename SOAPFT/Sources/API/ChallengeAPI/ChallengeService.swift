//
//  ChallengeService.swift
//  SOAPFT
//
//  Created by 바견규 on 7/8/25.
//

import Foundation
import Moya

final class ChallengeService {
    private let provider = MoyaProvider<ChallengeAPI>()

    // 사용자 참여 챌린지 목록
    func getParticipatedChallenges(status: String, completion: @escaping (Result<[ChallengeSummary], Error>) -> Void) {
        provider.request(.userChallenges(status: status)) { result in
            self.handleResponse(result, type: ParticipatedChallengesResponse.self) {
                completion($0.map { $0.data })
            }
        }
    }

    // 챌린지 생성
    func createChallenge(parameters: [String: Any], completion: @escaping (Result<ChallengeCreationResponse, Error>) -> Void) {
        provider.request(.createChallenge(parameters: parameters)) { result in
            self.handleResponse(result, type: ChallengeCreationResponse.self, completion: completion)
        }
    }

    // 챌린지 목록 조회
    func fetchChallenges(page: Int, limit: Int, type: String, gender: String, status: String, completion: @escaping (Result<[Challenge], Error>) -> Void) {
        provider.request(.fetchChallenges(page: page, limit: limit, type: type, gender: gender, status: status)) { result in
            self.handleResponse(result, type: ChallengeListWithMetaResponse.self) {
                completion($0.map { $0.data })
            }
        }
    }

    // 챌린지 상세
    func getChallengeDetail(id: String, completion: @escaping (Result<ChallengeDetailResponse2, Error>) -> Void) {
        provider.request(.challengeDetail(id: id)) { result in
            self.handleResponse(result, type: ChallengeDetailResponse2.self, completion: completion)
        }
    }

    // 챌린지 참여
    func joinChallenge(id: String, completion: @escaping (Result<ChallengeJoinResponse, Error>) -> Void) {
        provider.request(.joinChallenge(id: id)) { result in
            self.handleResponse(result, type: ChallengeJoinResponse.self, completion: completion)
        }
    }

    // 챌린지 탈퇴
    func leaveChallenge(id: String, completion: @escaping (Result<ChallengeLeaveResponse, Error>) -> Void) {
        provider.request(.leaveChallenge(id: id)) { result in
            self.handleResponse(result, type: ChallengeLeaveResponse.self, completion: completion)
        }
    }

    // 인증 진행률
    func getProgress(id: String, completion: @escaping (Result<ChallengeProgressResponse, Error>) -> Void) {
        provider.request(.progress(id: id)) { result in
            self.handleResponse(result, type: ChallengeProgressResponse.self, completion: completion)
        }
    }

    // 월별 인증 현황
    func getMonthlyVerifications(id: String, year: Int, month: Int, completion: @escaping (Result<MonthlyVerificationResponse, Error>) -> Void) {
        provider.request(.monthlyStats(id: id, year: year, month: month)) { result in
            self.handleResponse(result, type: MonthlyVerificationResponse.self, completion: completion)
        }
    }

    // 완료된 챌린지 수
    func getCompletedChallengeCount(completion: @escaping (Result<CompletedChallengeCountResponse, Error>) -> Void) {
        provider.request(.successfulChallenges) { result in
            self.handleResponse(result, type: CompletedChallengeCountResponse.self, completion: completion)
        }
    }

    // 공통 응답 처리
    private func handleResponse<T: Decodable>(
        _ result: Result<Moya.Response, MoyaError>,
        type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        switch result {
        case .success(let response):
            do {
                let decoded = try JSONDecoder().decode(T.self, from: response.data)
                completion(.success(decoded))
            } catch {
                print("📦 Raw JSON Response:\n" + (String(data: response.data, encoding: .utf8) ?? "nil"))
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
