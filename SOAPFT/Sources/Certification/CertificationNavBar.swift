//
//  CertificationNavView.swift
//  SOAPFT
//
//  Created by 바견규 on 6/30/25.
//

import SwiftUI

struct CertificationNavBar: View {
    @Environment(\.diContainer) private var container
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: { container.router.pop() }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                        .font(.system(size: 18))
                }
                Spacer()
            }

            Text("인증하기")
                .font(Font.Pretend.pretendardBold(size: 16))
        }
        .padding(.horizontal)
    }
}

#Preview {
    CertificationNavBar()
}

