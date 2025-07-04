//
//  MainChatListNavBar.swift
//  SOAPFT
//
//  Created by 바견규 on 7/5/25.
//

import SwiftUI

struct MainChatListNavBar: View {
    var body: some View {
        
        ZStack {
            
            
            HStack {
                
                Spacer()
                
                Button(action: { /* 메뉴 열기 */ }) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.black)
                        .contentShape(Rectangle())    // 터치 영역 확장
                }
            }
        }.padding()

    }
}


#Preview {
    MainChatListNavBar()
}
