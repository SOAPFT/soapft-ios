//
//  LoginView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/2/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.diContainer) var container
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                // 로고
                Text("한땀한땀")
                    .font(Font.Pretend.pretendardBold(size: 24))
                
                VStack(spacing: 20) {
                    Spacer()
                    // 카카오 로그인
                    KakoSignButton()
                    
                    // 네이버 로그인
                    NaverSignButton()
                    
                    // Apple 로그인
                    
                    // 테스트
    //                Button(action: {
    //                    // 로그인 성공 후 홈으로 이동
    //                    container.router.push(.mainTabbar)
    //                }) {
    //                    Text("테스트")
    //                }
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    LoginView()
}

//#Preview {
//    struct PreviewWrapper: View {
//        @StateObject var router = AppRouter()
//        
//        var body: some View {
//            let container = DIContainer(router: router)
//            
//            NavigationStack(path: $router.path) {
//                LoginView()
//                    .environment(\.diContainer, container)
//                    .navigationDestination(for: Route.self) { route in
//                        switch route {
//                        case .login:
//                            LoginView()
//                                .environment(\.diContainer, container)
//                        case .loginInfo:
//                            LoginInfoView()
//                                .environment(\.diContainer, container)
//                        case .mainTabbar:
//                            MainTabbarView()
//                                .environment(\.diContainer, container)
//                        case .groupEdit:
//                            GroupEditView()
//                                .environment(\.diContainer, container)
//                        case .home:
//                            GroupMainView()
//                                .environment(\.diContainer, container)
//                        case .groupCreate:
//                            GroupCreateView()
//                                .environment(\.diContainer, container)
//                        case .groupCreateNext:
//                            GroupCreateNextView()
//                        case .mypage:
//                            MyPageView()
//                                .environment(\.diContainer, container)
//                        case .mypageEdit:
//                            MyPageEditView()
//                                .environment(\.diContainer, container)
//                        case .mypageEditInfo:
//                            MyInfoEditView()
//                                .environment(\.diContainer, container)
//                        }
//                    }
//            }
//        }
//    }
//    
//    return PreviewWrapper()
//}
