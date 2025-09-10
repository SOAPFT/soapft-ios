//
//  MainTabbarView.swift
//  SOAPFT
//
//  Created by 홍지우 on 6/25/25.
//

import SwiftUI

struct MainTabbarView: View {
    @EnvironmentObject var container: DIContainer

    var body: some View{
        VStack(spacing: 0) {
            TabView (selection: $container.selectedTab){
                HomeWrapper()
                    .tag("홈")
//                FriendsView()
//                    .tag("Friends")
                GroupMainView()
                    .tag("챌린지")
                ChatListWrapper()
                    .tag("채팅")
                MyPageView()
                    .tag("마이")
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack {
                tabButton(title: "홈", selectedImage: "house.fill")
//                tabButton(title: "Friends", selectedImage: "person.2.fill")
                tabButton(title: "챌린지", selectedImage: "flame.fill")
                tabButton(title: "채팅", selectedImage: "ellipsis.message.fill")
                tabButton(title: "마이", selectedImage: "person.crop.circle.fill")
            }
            .padding()
            .background(Color.white)
        }
    }
    
    @ViewBuilder
    private func tabButton(title: String, selectedImage: String) -> some View {
        Button {
            container.selectedTab = title
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedImage)
                    .foregroundStyle(container.selectedTab == title ? Color.orange01 : .gray)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(container.selectedTab == title ? Color.orange01 : .gray)
                    .frame(maxWidth: .infinity)
            }
            
        }
    }
}

//#Preview {
//    MainTabbarView()
//}
