//
//  EventService.swift
//  SOAPFT
//
//  Created by 바견규 on 8/4/25.
//

import Foundation
import Moya

final class EventService {
    private let provider = MoyaProvider<EventAPI>()
    
    // MARK: - 1. 전체 이벤트 목록 조회
    func getEventList(completion: @escaping (Result<[Mission], Error>) -> Void) {
        provider.request(.getEventList) { result in
            self.handleResponse(result, type: [Mission].self, completion: completion)
        }
    }
    
    // MARK: - 2. 이벤트 상세 조회
    func getEventDetail(id: Int, completion: @escaping (Result<MissionDetailResponse, Error>) -> Void) {
        provider.request(.getEventDetail(id: id)) { result in
            self.handleResponse(result, type: MissionDetailResponse.self, completion: completion)
        }
    }
    
    // MARK: - 3. 이벤트 참여
    func participateEvent(id: Int, completion: @escaping (Result<MissionParticipationResponse, Error>) -> Void) {
        provider.request(.participateEvent(id: id)) { result in
            switch result {
            case .success(let response):
                if (200..<300).contains(response.statusCode) {
                    do {
                        let decoded = try JSONDecoder().decode(MissionParticipationResponse.self, from: response.data)
                        completion(.success(decoded))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    let apiError = NSError(
                        domain: "ParticipateEventAPI",
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
    
    // MARK: - 4. 내 참여 미션 목록 조회
    func getParticipatedMyEventList(completion: @escaping (Result<[MyMission], Error>) -> Void) {
        provider.request(.getParticipatedMyEventList) { result in
            self.handleResponse(result, type: [MyMission].self, completion: completion)
        }
    }
    
    // MARK: - 5. 미션 결과 제출 (인증)
    func certificateEvent(id: String, parameters: [String: Any], completion: @escaping (Result<MissionSubmissionResponse, Error>) -> Void) {
        provider.request(.certificateEvent(id: id, parameters: parameters)) { result in
            self.handleResponse(result, type: MissionSubmissionResponse.self, completion: completion)
        }
    }

    // MARK: - 5-1. 미션 결과 제출 (편의 메서드)
    func submitMissionResult(
        id: String,
        resultData: Int,
        completion: @escaping (Result<MissionSubmissionResponse, Error>) -> Void
    ) {
        let parameters: [String: Any] = ["resultData": resultData]
        certificateEvent(id: id, parameters: parameters, completion: completion)
    }
    
    // MARK: - 6. 미션 참여 취소
    func cancelParticipateEvent(id: Int, completion: @escaping (Result<MissionCancellationResponse, Error>) -> Void) {
        provider.request(.cancleParticipateEvent(id: id)) { result in
            self.handleResponse(result, type: MissionCancellationResponse.self, completion: completion)
        }
    }
    
    // MARK: - 공통 응답 처리
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
                    print("📦 Raw JSON Response (\(T.self)):\n\(jsonString)")
                } else {
                    print("📦 Raw JSON: 인코딩 실패")
                }
                
                // JSONDecoder 설정
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let decoded = try decoder.decode(T.self, from: response.data)
                completion(.success(decoded))
            } catch {
                // 🧨 디코딩 실패 상세 에러 출력
                print("❌ JSON Decoding 실패 - 타입: \(T.self)")
                print("📦 상태 코드: \(response.statusCode)")
                if let json = try? JSONSerialization.jsonObject(with: response.data, options: []),
                   let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                   let jsonStr = String(data: pretty, encoding: .utf8) {
                    print("📜 응답 JSON (Pretty):\n\(jsonStr)")
                }
                print("🧩 에러 디버그: \(error.localizedDescription)")
                completion(.failure(error))
            }
            
        case .failure(let error):
            print("❌ 네트워크 또는 서버 에러: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
}

