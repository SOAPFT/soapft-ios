//
//  KakoSignButton.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/3/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import Moya

struct KakoSignButton: View {
    let provider = MoyaProvider<KakaoAuthAPI>()
    
    var body: some View {
        Button {
            if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                    handleLogin(oauthToken: oauthToken, error: error)
                }
            } else {
                UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                    handleLogin(oauthToken: oauthToken, error: error)
                }
            }
        } label: {
            Image("kakaoButton")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width * 0.9)
        }
    }

    private func handleLogin(oauthToken: OAuthToken?, error: Error?) {
        if let error = error {
            print("카카오 로그인 실패: \(error.localizedDescription)")
            return
        }
        
        guard let token = oauthToken?.accessToken else {
            print("토큰 없음")
            return
        }
        
        print("카카오 로그인 성공: \(token)")
        
        let accessToken = token
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let deviceType = "iOS"
        let pushToken = "dummy_push_token"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        
        provider.request(.sendToken(accessToken: accessToken, deviceId: deviceId, deviceType: deviceType, pushToken: pushToken, appVersion: appVersion)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(KakaoLoginResponse.self, from: response.data)
                    print("서버 로그인 성공: \(decoded)")
                } catch {
                    print("응답 디코딩 실패: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("서버 요청 실패: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    KakoSignButton()
}
