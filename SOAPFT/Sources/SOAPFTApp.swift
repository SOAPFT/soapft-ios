import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct SOAPFTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var router = AppRouter()
    // DIContainer 인스턴스 생성
    
    
    init() {
        // kakao sdk 초기화
        let kakaoNativeAppKey = (Bundle.main.object(forInfoDictionaryKey: "Kakao_AppKey") as? String) ?? ""
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                let container = DIContainer(router: router)
                LoginView()
                    .environment(\.diContainer, container) // 💡 DIContainer 환경 주입
                    .navigationDestination(for: Route.self) { route in
                        switch route {

                        case .login:
                            LoginView()
                                .environment(\.diContainer, container)
                        case .loginInfo:
                            LoginInfoView()
                                .environment(\.diContainer, container)
                        case .mainTabbar:
                            MainTabbarView()
                                .environment(\.diContainer, container)
                        case .home:
                            GroupMainView()
                                .environment(\.diContainer, container)
                        case .mypage:
                            MyPageView()
                                .environment(\.diContainer, container)
                        case .mypageEdit:
                            MyPageEditView()
                                .environment(\.diContainer, container)
                        case .mypageEditInfo:
                            MyInfoEditView()
                                .environment(\.diContainer, container)

                        }
                    }
                    .onOpenURL { url in
                        if (AuthApi.isKakaoTalkLoginUrl(url)) {
                            _ = AuthController.handleOpenUrl(url: url)
                        }
                    }
            }
        }
    }
}
