//
//  GroupInfoNavBar.swift
//  SOAPFT
//
//  Created by 바견규 on 6/30/25.
//

import SwiftUI

struct GroupInfoNavBar: View {
    var notificationCount: Int = 3
    @Environment(\.diContainer) private var container
    
    var body: some View {
        ZStack {
            // 정중앙 타이틀
            Text("그룹 정보")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)

            // 좌우 버튼 정렬
            HStack {
                // Back button
                Button(action: {
                    container.router.pop()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.black)
                }

                Spacer()

                // Group Members Icon
                Button(action: {}) {
                    Image(systemName: "message")
                        .foregroundStyle(.black)
                }

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
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.black)
                        .frame(width: 18, height: 24)
                        .contentShape(Rectangle())
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 44)
        .background(Color.white)
    }
}



#Preview {
    GroupInfoNavBar()
}
