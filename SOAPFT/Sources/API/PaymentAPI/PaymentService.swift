//
//  PaymentService.swift
//  SOAPFT
//
//  Created by 바견규 on 8/10/25.
//

import Foundation
import Moya

//결제 로직이 있는 것이 아닌 기프티콘용 서비스
final class PaymentService {
    private let provider = MoyaProvider<PaymentAPI>()
    
    // 기프티콘 변환
    func withdrawGifticon(amount: Int, completion: @escaping (Result<WithdrawResponse, Error>) -> Void) {
        provider.request(.withdraw(amount: amount)) { result in
            self.handleResponse(result, type: WithdrawResponse.self, completion: completion)
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
                completion(.success(decoded))
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
