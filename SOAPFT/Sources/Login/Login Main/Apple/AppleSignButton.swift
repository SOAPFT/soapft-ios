import SwiftUI
import AuthenticationServices

struct AppleSignButton: View {
    @Environment(\.diContainer) private var container
    @State private var coordinator: AppleSignInCoordinator?
    @State private var authController: ASAuthorizationController?
    
    var body: some View {
        Button(action: {
            startSignInWithAppleFlow()
        }) {
            Image("appleButton")
                .resizable()
                .scaledToFit()
                .frame(height: 56)
                .cornerRadius(12)
                .padding(.horizontal, 16)
        }
    }
    
    private func startSignInWithAppleFlow() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        // 1) 코디네이터 한 번만 만들고 보관
        let coord = AppleSignInCoordinator(container: container)
        self.coordinator = coord
        
        // 2) 동일 인스턴스를 delegate / presentationContextProvider 둘 다에 설정
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = coord
        controller.presentationContextProvider = coord
        
        // (선택) 컨트롤러도 보관
        self.authController = controller
        
        controller.performRequests()
    }
}

final class AppleSignInCoordinator: NSObject,
                                    ASAuthorizationControllerDelegate,
                                    ASAuthorizationControllerPresentationContextProviding {
    private let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("❌ credential 변환 실패")
            return
        }
        
        guard let tokenData = credential.identityToken,
              let tokenString = String(data: tokenData, encoding: .utf8) else {
            print("❌ identityToken 없음")
            return
        }
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let deviceType = "iOS"
        let pushToken = UserDefaults.standard.string(forKey: "device_token") ?? "dummy_push_token"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        
        AuthService.shared.appleLogin(
            accessToken: tokenString,
            deviceId: deviceId,
            deviceType: deviceType,
            pushToken: pushToken,
            appVersion: appVersion
        ) { result in
            switch result {
            case .success(let response):
                print("✅ 서버 로그인 성공: \(response)")
                KeyChainManager.shared.save(response.accessToken, forKey: KeyChainKey.accessToken)
                KeyChainManager.shared.save(response.refreshToken, forKey: KeyChainKey.refreshToken)
                
                DispatchQueue.main.async {
                    self.container.router.reset()
                    if response.isNewUser {
                        print("🔥 isNewUser: true")
                        self.container.router.push(.loginInfo)
                    } else {
                        print("🔥 isNewUser: false")
                        self.container.router.push(.mainTabbar)
                    }
                }
            case .failure(let error):
                print("❌ 서버 로그인 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        print("❌ Apple 로그인 에러: \(error.localizedDescription)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // keyWindow가 nil이면 임시로 새 anchor 반환
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? ASPresentationAnchor()
    }
}
