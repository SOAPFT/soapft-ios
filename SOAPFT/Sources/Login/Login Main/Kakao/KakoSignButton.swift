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
//import Moya

struct KakoSignButton: View {
    @Environment(\.diContainer) private var container
//    let provider = MoyaProvider<KakaoAuthAPI>()
    
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
                .scaledToFit()
                .frame(height: 56)
                .cornerRadius(12)
                .padding(.horizontal, 16)
        }
    }

    private func handleLogin(oauthToken: OAuthToken?, error: Error?) {
        if let error = error {
            print("❌ 카카오 로그인 실패: \(error.localizedDescription)")
            return
        }
        
        guard let token = oauthToken?.accessToken else {
            print("❌ 토큰 없음")
            return
        }
        
        print("✅ 카카오 로그인 성공: \(token)")
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let deviceType = "iOS"
        let pushToken = "dummy_push_token"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        
        // AuthService
        AuthService.shared.kakaoLogin(
            accessToken: token,
            deviceId: deviceId,
            deviceType: deviceType,
            pushToken: pushToken,
            appVersion: appVersion
        ) { result in
            switch result {
            case .success(let response):
                print("✅ 서버 로그인 성공: \(response)")
                
                // Keychain에 토큰 저장
                KeyChainManager.shared.save(response.accessToken, forKey: KeyChainKey.accessToken)
                KeyChainManager.shared.save(response.refreshToken, forKey: KeyChainKey.refreshToken)
                
                // 로그인 완료 후 동작
                if let accessToken = KeyChainManager.shared.readAccessToken() {
                    print("🔐 저장된 AccessToken: \(accessToken)")
                    // → 자동 로그인 시도 또는 API 호출
                    container.router.reset()
                    if response.isNewUser {
                        print("🔥 isNewUser: ture")
                        container.router.push(.loginInfo)
                    } else {
                        print("🔥 isNewUser: false")
                        container.router.push(.mainTabbar)
                    }
                } else {
                    print("🔓 토큰 없음 → 로그인 화면으로 이동")
                }

            case .failure(let error):
                print("❌ 서버 로그인 실패: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    KakoSignButton()
}
