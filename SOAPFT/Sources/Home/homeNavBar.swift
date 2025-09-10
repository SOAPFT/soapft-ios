//
//  ChatRoomNavBar.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI

struct homeNavBar: View {
    //DIContainer
    @Environment(\.diContainer) private var container
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image("logoSmall")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 32)
                    .padding(.leading, 8)
                
                Spacer()
                
                Button(action: { /* 메뉴 열기 */ }) {
                    Image(systemName: "bell")
                        .foregroundStyle(.black)
                        .font(.system(size: 18))
                }
                
                Button(action: {container.router.push(.ChallengeSearchWrapper)}) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.black)
                        .font(.system(size: 18))
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 16)
            
            Divider()
        }
    }
}

#Preview {
    homeNavBar()
}
