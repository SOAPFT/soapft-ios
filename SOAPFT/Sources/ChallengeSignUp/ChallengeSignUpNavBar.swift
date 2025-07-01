//
//  ChallengeSignUpNavBar.swift
//  SOAPFT
//
//  Created by 바견규 on 7/1/25.
//


import SwiftUI

struct ChallengeSignUpNavBar: View {
    let challengeName: String
    
    var body: some View {
        ZStack{
            Text(challengeName)
                .font(Font.Pretend.pretendardBold(size: 16))
            HStack {
                Button(action: { }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                        .font(Font.system(size: 18))
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.black)
                }
                
                Button(action: { /* 메뉴 열기 */ }) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.black)
                        .frame(width: 18, height: 24) // 아이콘 크기 조정
                        .contentShape(Rectangle())    // 터치 영역 확장
                }
            }.padding()
            
        }
    }
}

#Preview {
    ChallengeSignUpNavBar(challengeName: "채팅방 이름")
}
