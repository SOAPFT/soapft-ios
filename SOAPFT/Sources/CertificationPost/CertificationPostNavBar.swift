//
//  CertificationPost.swift
//  SOAPFT
//
//  Created by 바견규 on 7/2/25.
//

import SwiftUI

struct CertificationPostNavBar: View {
    var notificationCount: Int = 3
    
    var body: some View {
            // 좌우 버튼 정렬
            HStack {

                Spacer()

                // Notification with badge
                ZStack(alignment: .topTrailing) {
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .foregroundStyle(.black)
                    }

                    if notificationCount > 0 {
                        Text("\(notificationCount)")
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 8, y: -8)
                    }
                }


                // More icon
                Button(action: { /* 메뉴 열기 */ }) {
                    Image(systemName: "magnifyingglass")
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.black)
                        .frame(width: 18, height: 24)
                        .contentShape(Rectangle())
                }
                .padding(.horizontal, 10)
                
            }
            .padding(.top, 10)
    }
}



#Preview {
    CertificationPostNavBar()
}
