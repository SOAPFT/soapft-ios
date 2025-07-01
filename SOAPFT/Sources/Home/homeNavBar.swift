//
//  ChatRoomNavBar.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI

struct homeNavBar: View {
    
    var body: some View {
        
        HStack {
            
            Spacer()
            
            Button(action: { /* 메뉴 열기 */ }) {
                Image(systemName: "bell")
                    .foregroundStyle(.black)
            }
            
            Button(action: { /* 메뉴 열기 */ }) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.black)
            }
        }.padding()

    }
}

#Preview {
    homeNavBar()
}
