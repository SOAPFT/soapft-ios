//
//  LoginResponse.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/3/25.
//

import Foundation

struct KakaoLoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let isNewUser: Bool
    let message: String
}
