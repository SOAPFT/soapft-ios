//
//  GroupTabbarView.swift
//  SOAPFT
//
//  Created by 홍지우 on 6/25/25.
//

import SwiftUI

struct GroupTabbarView: View {
    @State private var selectedTab: String = "Info"
    
    var body: some View{
        VStack(spacing: 0) {
            TabView (selection: $selectedTab){
                Text("그룹 정보")
                    .tag("Info")
                Text("인증 현황")
                    .tag("Status")
                Text("인증")
                    .tag("Check")
                Text("인증글 보기")
                    .tag("List")
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack {
                tabButton(title: "Info", selectedImage: "info.circle")
                tabButton(title: "Stauts", selectedImage: "checkmark.seal")
                tabButton(title: "Check", selectedImage: "camera")
                tabButton(title: "List", selectedImage: "newspaper")
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
    GroupTabbarView()
}
