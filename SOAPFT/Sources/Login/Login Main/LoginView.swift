//
//  LoginView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/2/25.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack(alignment: .leading) {
            // 로고
            Text("한땀한땀")
                .font(Font.Pretend.pretendardBold(size: 24))
            
            // 카카오 로그인
            KakoSignButton()
            
            // 네이버 로그인
            
            // Apple 로그인
        }
    }
}

#Preview {
    LoginView()
}
