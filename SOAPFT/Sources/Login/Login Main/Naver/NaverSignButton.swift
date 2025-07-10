//
//  NaverSignButton.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/6/25.
//

import SwiftUI
import NidThirdPartyLogin

struct NaverSignButton: View {
    @Environment(\.diContainer) private var container
    
    @State private var accessToken: String = ""
    @State private var loginError: String = ""
    @State private var userName: String = ""
    
    var body: some View {
        VStack {
            Button(action: {
                loginWithNaver()
            }) {
                Image("naverButton")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width * 0.9)
            }
        }
    }
    
    func loginWithNaver() {
        NidOAuth.shared.requestLogin { result in
            switch result {
            case .success(let loginResult):
                let naverAccessToken = loginResult.accessToken.tokenString
                print("✅ Naver 토큰: \(naverAccessToken)")
                callNaverLoginAPI(with: naverAccessToken)
            case .failure(let error):
                DispatchQueue.main.async {
                    loginError = error.localizedDescription
                }
                print("❌ 네이버 로그인 실패: ", error.localizedDescription)
            }
        }
    }
    
    private func callNaverLoginAPI(with token: String) {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let deviceType = "IOS"
        let pushToken = UserDefaults.standard.string(forKey: "pushToken") ?? "dummyPushToken"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        
        container.authService.naverLogin(accessToken: token, deviceId: deviceId, deviceType: deviceType, pushToken: pushToken, appVersion: appVersion) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ 네이버 로그인 성공: \(response.message)")
                    print("AccessToken: \(response.accessToken)")
                    print("RefreshToken: \(response.refreshToken)")
                    
                    // 토큰 저장
                    KeyChainManager.shared.save(response.accessToken, forKey: "jwtToken")
                    KeyChainManager.shared.save(response.refreshToken, forKey: "refreshToken")
                    
                    // 다음 화면 이동
                    container.router.reset()
                    if response.isNewUser {
                        container.router.push(.loginInfo)
                    } else {
                        container.router.push(.mainTabbar)
                    }
                    
                case .failure(let error):
                    print("❌ 서버 로그인 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetUserProfile(with token: String) {
        NidOAuth.shared.getUserProfile(accessToken: token) { result in
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    userName = profile["name"] ?? "이름 없음"
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    loginError = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    NaverSignButton()
}
