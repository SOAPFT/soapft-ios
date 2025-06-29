//
//  ChatListNavBar.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI

struct ChatListNavBar: View {
    var body: some View {
        
        HStack {
            Button(action: { }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                    .font(Font.system(size: 18))
            }
            
            Spacer()
            
            Text("채팅")
                .font(Font.Pretend.pretendardBold(size: 16))
            
            Spacer()
            
            Button(action: { /* 메뉴 열기 */ }) {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundColor(.black)
                    .frame(width: 18, height: 24) // 아이콘 크기 조정
                    .contentShape(Rectangle())    // 터치 영역 확장
            }
        }.padding()

    }
}


#Preview {
    ChatListNavBar()
}
