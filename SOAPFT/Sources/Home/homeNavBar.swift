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
        
        HStack {
            
            Spacer()
            
            Button(action: { container.router.push(.alert ) }) {
                Image(systemName: "bell")
                    .foregroundStyle(.black)
            }
            
            Button(action: {container.router.push(.ChallengeSearchWrapper)}) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.black)
            }
        }.padding()

    }
}

#Preview {
    homeNavBar()
}
