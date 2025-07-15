//
//  ChallengeStatisticsNavBar.swift
//  SOAPFT
//
//  Created by 바견규 on 7/15/25.
//

import SwiftUI

struct ChallengeStatisticsNavBar: View {
    @Environment(\.diContainer) private var container
    
    var body: some View {
        HStack {
            Button(action: { container.router.pop() }) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.black)
                    .font(.system(size: 18))
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ChallengeStatisticsNavBar()
}
