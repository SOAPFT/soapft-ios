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
            // 로고
            Text("한땀한땀")
                .font(Font.Pretend.pretendardBold(size: 24))
            
            VStack(spacing: 20) {
                // 카카오 로그인
                KakoSignButton()
                
                // 네이버 로그인
                NaverSignButton()
                
                // Apple 로그인
                Button(action: {
                    // 로그인 성공 후 홈으로 이동
                    container.router.push(.mainTabbar)
                }) {
                    Text("테스트")
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {

}
