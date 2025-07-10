import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct SOAPFTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var router = AppRouter()
    // DIContainer 인스턴스 생성
    private var container: DIContainer
    
    init() {
        // kakao sdk 초기화
        let kakaoNativeAppKey = (Bundle.main.object(forInfoDictionaryKey: "Kakao_AppKey") as? String) ?? ""
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
        
        // DIContainer 생성
        let router = AppRouter()
        self._router = StateObject(wrappedValue: router)
        self.container = DIContainer(router: router)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                LoginView()
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .MainTabbar:
                            MainTabbarView()
                                .environment(\.diContainer, container)
                        }
                    }
                    .onOpenURL { url in
                        if (AuthApi.isKakaoTalkLoginUrl(url)) {
                            _ = AuthController.handleOpenUrl(url: url)
                        }
                    }
            }
            .environment(\.diContainer, container)
        }
    }
}
