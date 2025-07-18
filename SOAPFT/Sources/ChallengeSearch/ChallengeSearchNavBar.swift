//
//  ChallengeSearchNavBar.swift
//  SOAPFT
//
//  Created by 바견규 on 7/3/25.
//

import SwiftUI

struct ChallengeSearchNavBar: View {
    @Environment(\.diContainer) private var container
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: { container.router.pop()  }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                        .font(.system(size: 18))
                }
                Spacer()
            }

            Text("챌린지 검색")
                .font(Font.Pretend.pretendardBold(size: 16))
        }
        .padding()
    }
}

#Preview {
    ChallengeSearchNavBar()
}
