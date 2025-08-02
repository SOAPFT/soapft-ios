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
        // 테스트 계정용
        KeyChainManager.shared.save("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyVXVpZCI6IjAxSllLVk4xOE1DVzVCOUZaMVBQN1QxNFhTIiwiaWF0IjoxNzUyNDMyOTY4LCJleHAiOjE3NTUwMjQ5Njh9.hQIIndKOAYVbvTzMqJ0fxLiaYj71-eUIsO-xkydAo2I", forKey: KeyChainKey.accessToken)
        
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

                        case .login:
                            LoginView()
                                .environment(\.diContainer, container)
                        case .loginInfo:
                            LoginInfoView()
                                .environment(\.diContainer, container)
                        case .mainTabbar:
                            MainTabbarView()
                                .environment(\.diContainer, container)
                                .environmentObject(container)
                        case .groupEdit:
                            GroupEditView()
                                .environment(\.diContainer, container)
                        case .home:
                            GroupMainView()
                                .environment(\.diContainer, container)
                        case .friendPage(let userUUID, let accessToken):
                            FriendsPageView(userUUID: userUUID, accessToken: accessToken)
                                .environment(\.diContainer, container)
                        case .friendsRequest:
                            FriendsRequestView()
                                .environment(\.diContainer, container)
                        case .groupCreate:
                            GroupCreateView()
                                .environment(\.diContainer, container)
//                        case .groupCreateNext:
//                            GroupCreateNextView()
//                                .environment(\.diContainer, container)
                        case .moreRecentGroup:
                            MoreGroupView(viewType: .recent)
                                .environment(\.diContainer, container)
                        case .moreHotGroup:
                            MoreGroupView(viewType: .hot)
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
                        case .alert:
                            AlertView()
                                .environment(\.diContainer, container)
                        case .GroupTabbar(let ChallengeID):
                            GroupTabbarWrapper(challengeID: ChallengeID)
                        case .ChallengeSearchWrapper:
                            ChallengeSearchWrapper()
                        case .ChatRoomWrapper(let currentUserUuid,let roomId,let chatRoomName):
                            ChatRoomWrapper(currentUserUuid: currentUserUuid, roomId: roomId, chatRoomName: chatRoomName)
                        case .ChatListWrapper:
                            ChatListWrapper()
                        case .challengeSignUpWrapper(let challengeId):
                            ChallengeSignUpWrapper(challengeUuid: challengeId, container: container)
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
