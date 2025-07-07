import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct SOAPFTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let service: ChallengeService
    
    let parameters: [String: Any] = [
          "title": "6월 새벽 기상 챌린지",
          "type": "NORMAL",
          "introduce": "하루를 일찍 시작하고 싶은 사람들을 위한 챌린지입니다.",
          "verificationGuide": "6시 전에 일어나서 인증샷!!",
          "start_date": "2025-07-12T00:00:00.000Z",
          "end_date": "2025-07-31T23:59:59.000Z",
          "goal": 5,
          "start_age": 18,
          "end_age": 40,
          "gender": "NONE",
          "max_member": 30,
          "coin_amount": 0,
          "profile": "https://cdn.example.com/images/challenge-profile.png",
          "banner": "https://cdn.example.com/images/challenge-banner.png"
    ]
    
    init() {
        // kakao sdk 초기화
        let kakaoNativeAppKey = (Bundle.main.object(forInfoDictionaryKey: "Kakao_AppKey") as? String) ?? ""
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
        service = ChallengeService()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .onOpenURL { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
            
            Button(action:{
                service.createChallenge(parameters: parameters) { result in
                    switch result {
                    case .success(let response):
                        print("✅ 생성 완료:")
                        dump(response) // 전체 구조체 내용을 계층적으로 출력

                    case .failure(let error):
                        print("❌ 실패:", error.localizedDescription)
                    }
                }


            }){
                Text("챌린지 테스트")
            }
        }
    }
}
