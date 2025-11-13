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
    func getParticipatedChallenges(status: String, completion: @escaping (Result<[Challenge], Error>) -> Void) {
        provider.request(.userChallenges(status: status)) { result in
            self.handleResponse(result, type: [Challenge].self, completion: completion)
        }
    }

    // 챌린지 생성
    func createChallenge(parameters: [String: Any], completion: @escaping (Result<ChallengeCreationResponse, Error>) -> Void) {
        provider.request(.createChallenge(parameters: parameters)) { result in
            self.handleResponse(result, type: ChallengeCreationResponse.self, completion: completion)
        }
    }
    func createChallengeMultipart(parameters: [String: Any], profileImage: Data, bannerImage: Data, completion: @escaping (Result<ChallengeCreationResponse, Error>) -> Void) {
        provider.request(.createChallengeMultipart(parameters: parameters, profileImage: profileImage, bannerImage: bannerImage)) { result in
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
    func getChallengeDetail(id: String, completion: @escaping (Result<ChallengeDetailResponse, Error>) -> Void) {
        provider.request(.challengeDetail(id: id)) { result in
            self.handleResponse(result, type: ChallengeDetailResponse.self, completion: completion)
        }
    }

    // 챌린지 참여
    func joinChallenge(id: String, completion: @escaping (Result<ChallengeJoinResponse, Error>) -> Void) {
        provider.request(.joinChallenge(id: id)) { result in
            switch result {
            case .success(let response):
                if (200..<300).contains(response.statusCode) {
                    do {
                        let decoded = try JSONDecoder().decode(ChallengeJoinResponse.self, from: response.data)
                        completion(.success(decoded))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    let apiError = NSError(
                        domain: "JoinChallengeAPI",
                        code: response.statusCode,
                        userInfo: ["data": response.data]
                    )
                    completion(.failure(apiError))
                }

            case .failure(let error):
                completion(.failure(error))
            }
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
    
    // 챌린지 수정
        func updateChallenge(id: String, parameters: [String: Any], completion: @escaping (Result<ChallengeUpdateResponse, Error>) -> Void) {
            provider.request(.updateChallenge(id: id, parameters: parameters)) { result in
                self.handleResponse(result, type: ChallengeUpdateResponse.self, completion: completion)
            }
        }
        
        // 최근 챌린지 목록
        func getRecentChallenges(completion: @escaping (Result<[Challenge], Error>) -> Void) {
            provider.request(.recentChallenges) { result in
                self.handleResponse(result, type: [Challenge].self, completion: completion)
            }
        }
        
        // 인기 챌린지 목록
        func getPopularChallenges(completion: @escaping (Result<[Challenge], Error>) -> Void) {
            provider.request(.popularChallenges) { result in
                self.handleResponse(result, type: [Challenge].self, completion: completion)
            }
        }
        
        // 챌린지 검색
        func searchChallenges(keyword: String, page: Int, limit: Int, completion: @escaping (Result<[Challenge], Error>) -> Void) {
            provider.request(.searchChallenges(keyword: keyword, page: page, limit: limit)) { result in
                self.handleResponse(result, type: ChallengeListWithMetaResponse.self) {
                    completion($0.map { $0.data })
                }
            }
        }
    
    // 게시글 신고
    func reportPost(postUuid: String, completion: @escaping (Result<String, Error>) -> Void) {
        provider.request(.reportPost(postUuid: postUuid)) { result in
            self.handleResponse(result, type: ReportResponse.self) {
                completion($0.map { $0.message })
            }
        }
    }

    // 이미지 사전 AI 검증
        func precheckImages(challengeUuid: String, images: [Data], completion: @escaping (Result<VerificationStatusResponse, Error>) -> Void) {
            provider.request(.precheckImages(challengeUuid: challengeUuid, images: images)) { result in
                self.handleResponse(result, type: VerificationStatusResponse.self, completion: completion)
            }
        }
        
        // 검증 상태 조회 (콜백)
        func getVerificationStatus(
            postUuid: String,
            completion: @escaping (Result<VerificationStatusResponse, Error>) -> Void
        ) {
            provider.request(.verificationStatus(PostUuid: postUuid)) { result in
                self.handleResponse(result, type: VerificationStatusResponse.self, completion: completion)
            }
        }

        // AI 검증된 이미지로 게시글 생성
        func createVerifiedPost(parameters: [String: Any], completion: @escaping (Result<CreatePostResponse, Error>) -> Void) {
            provider.request(.createVerifiedPost(parameters: parameters)) { result in
                self.handleResponse(result, type: CreatePostResponse.self, completion: completion)
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
                // 디코딩 시도 전에 JSON Raw 출력
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("Raw JSON Response:\n\(jsonString)")
                } else {
                    print("Raw JSON: 인코딩 실패")
                }
                
                let decoded = try JSONDecoder().decode(T.self, from: response.data)
                
                // ChallengeLeaveResponse의 경우 success 필드 확인
                if let leaveResponse = decoded as? ChallengeLeaveResponse {
                    if leaveResponse.success {
                        completion(.success(decoded))
                    } else {
                        // success: false인 경우 APIError로 변환
                        let apiError = APIError(
                            message: leaveResponse.message,
                            code: leaveResponse.errorCode,
                            details: nil
                        )
                        completion(.failure(apiError))
                    }
                } else {
                    // 다른 응답들은 기존대로 처리
                    completion(.success(decoded))
                }
            } catch {
                // 디코딩 실패 상세 에러 출력
                print("JSON Decoding 실패 - 타입: \(T.self)")
                print("상태 코드: \(response.statusCode)")
                if let json = try? JSONSerialization.jsonObject(with: response.data, options: []),
                   let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                   let jsonStr = String(data: pretty, encoding: .utf8) {
                    print("응답 JSON (Pretty):\n\(jsonStr)")
                }
                print("에러 디버그: \(error.localizedDescription)")
                completion(.failure(error))
            }

        case .failure(let error):
            print("네트워크 또는 서버 에러: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
}
