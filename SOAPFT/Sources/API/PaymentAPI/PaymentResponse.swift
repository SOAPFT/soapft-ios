//
//  PaymentResponse.swift
//  SOAPFT
//
//  Created by 바견규 on 8/10/25.
//

import Foundation

// MARK: - 기프티콘 변환 응답
struct WithdrawResponse: Decodable {
    let message: String
}

// MARK: - 에러 응답
struct PaymentErrorResponse: Decodable {
    let error: String
    let code: Int?
    let message: String?
}
