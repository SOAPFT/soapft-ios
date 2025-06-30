//
//  CertificationNavView.swift
//  SOAPFT
//
//  Created by 바견규 on 6/30/25.
//

import SwiftUI

struct CertificationNavBar: View {
    var body: some View {
        ZStack {
            HStack {
                Button(action: { }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 18))
                }
                Spacer()
            }

            Text("인증하기")
                .font(Font.Pretend.pretendardBold(size: 16))
        }
        .padding()
    }
}

#Preview {
    CertificationNavBar()
}

