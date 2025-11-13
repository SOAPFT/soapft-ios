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
    
    // 디바이스별 버튼 최대 너비 계산
        private var buttonMaxWidth: CGFloat {
            let screenWidth = UIScreen.main.bounds.width
            
            // iPad 감지
            if UIDevice.current.userInterfaceIdiom == .pad {
                // iPad의 경우 최대 400pt로 제한
                return min(400, screenWidth * 0.6)
            } else {
                // iPhone의 경우 기존 로직 유지
                return screenWidth * 0.9
            }
        }

    private func handleLogin(oauthToken: OAuthToken?, error: Error?) {
        if let error = error {
            print("[KakoSignButton] 카카오 로그인 실패: \(error.localizedDescription)")
            return
        }
        
        guard let token = oauthToken?.accessToken else {
            print("[KakoSignButton] 토큰 없음")
            return
        }
        
        print("[KakoSignButton] 카카오 로그인 성공: \(token)")
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let deviceType = "iOS"
        let pushToken = UserDefaults.standard.string(forKey: "device_token") ?? "dummy_push_token"
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
                print("[KakoSignButton] 서버 로그인 성공: \(response)")
                
                // Keychain에 토큰 저장
                KeyChainManager.shared.save(response.accessToken, forKey: KeyChainKey.accessToken)
                KeyChainManager.shared.save(response.refreshToken, forKey: KeyChainKey.refreshToken)
                
                // 로그인 완료 후 동작
                if let accessToken = KeyChainManager.shared.readAccessToken() {
                    print("[KakoSignButton] 저장된 AccessToken: \(accessToken)")
                    // → 자동 로그인 시도 또는 API 호출
                    container.router.reset()
                    if response.isNewUser {
                        print("[KakoSignButton] isNewUser: ture")
                        container.router.push(.loginInfo)
                    } else {
                        print("[KakoSignButton] isNewUser: false")
                        container.router.push(.mainTabbar)
                    }
                } else {
                    print("[KakoSignButton] 토큰 없음 → 로그인 화면으로 이동")
                }

            case .failure(let error):
                print("[KakoSignButton] 서버 로그인 실패: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    KakoSignButton()
}
