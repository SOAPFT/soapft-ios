//
//  MainTabbarView.swift
//  SOAPFT
//
//  Created by 홍지우 on 6/25/25.
//

import SwiftUI

struct MainTabbarView: View {
    @EnvironmentObject var container: DIContainer
    @State private var selectedTab: String = "Main"

    var body: some View{
        VStack(spacing: 0) {
            TabView (selection: $selectedTab){
                HomeWrapper()
                    .tag("Main")
                FriendsView()
                    .tag("Friends")
                GroupMainView()
                    .tag("More")
                ChatListWrapper()
                    .tag("Chat")
                MyPageView()
                    .tag("My")
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack {
                tabButton(title: "Main", selectedImage: "house.fill")
                tabButton(title: "Friends", selectedImage: "person.2.fill")
                tabButton(title: "More", selectedImage: "list.bullet")
                tabButton(title: "Chat", selectedImage: "ellipsis.message.fill")
                tabButton(title: "My", selectedImage: "person.crop.circle.fill")
            }
            .padding()
            .background(Color.white)
        }
    }
    
    @ViewBuilder
    private func tabButton(title: String, selectedImage: String) -> some View {
        Button {
            selectedTab = title
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedImage)
                    .foregroundStyle(selectedTab == title ? Color.orange01 : .gray)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(selectedTab == title ? Color.orange01 : .gray)
                    .frame(maxWidth: .infinity)
            }
            
        }
    }
}

#Preview {
    MainTabbarView()
}
