//
//  ChallengeSearchNavBar.swift
//  SOAPFT
//
//  Created by 바견규 on 7/3/25.
//

import SwiftUI

struct ChallengeSearchNavBar: View {
    var body: some View {
        ZStack {
            HStack {
                Button(action: { }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
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
    ChallengeSearchNavBar()
}
