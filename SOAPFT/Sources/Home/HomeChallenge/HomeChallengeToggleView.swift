//
//  HomeChallengeToggleView.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI

struct HomeChallengeToggleView: View {
    @Binding var selectedTab: ChallengeTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ChallengeTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(selectedTab == tab ? .black : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedTab == tab ? Color.white : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(4)
        .background(Color.gray.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}



#Preview {
    struct PreviewContainer: View {
        @State private var selectedTab: ChallengeTab = .inProgress
        
        var body: some View {
            HomeChallengeToggleView(selectedTab: $selectedTab)
                .padding()
        }
    }
    
    return PreviewContainer()
}
