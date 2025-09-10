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
        ZStack {
            Color.orange02
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                ZStack {
                    // 로고
                    VStack(spacing: 16) {
                        Image("logo")
                            .resizable()
                            .frame(width: 84, height: 75)
                            .foregroundStyle(Color.white)
                        Text("좋은 습관을 위한 한걸음, 한땀한땀")
                            .font(Font.Pretend.pretendardSemiBold(size: 18))
                            .foregroundStyle(Color.white)
                    }
                            
                    VStack(spacing: 20) {
                        Spacer()
                        // 카카오 로그인
                        KakoSignButton()
                        
                        // 네이버 로그인
                        NaverSignButton()
                        
                        // Apple 로그인
                        
                        
                        // 테스트
                        Button(action: {
                            container.router.push(.mainTabbar)
                        }) {
                            Text("테스트")
                        }
                        
                        Text("")
                    }
                }
            }
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    LoginView()
}

