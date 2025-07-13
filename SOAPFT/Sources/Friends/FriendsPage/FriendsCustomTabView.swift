//
//  FriendsCustomTabView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/13/25.
//

import SwiftUI

struct FriendsCustomTabView: View {
    let userUUID: String
    
    @State var selectedFilter: Int = 0
    let filters: [String] = ["square.grid.3x3.fill", "calendar"]

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                let tabSize = geometry.size.width / CGFloat(filters.count)
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(filters.indices, id: \.self) { index in
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    selectedFilter = index
                                }
                            }) {
                                VStack {
                                    Image(systemName: filters[index])
                                        .font(.system(size: 20, weight: selectedFilter == index ? .bold : .regular ))
                                        .foregroundStyle(selectedFilter == index ? Color.black : Color.gray)
                                }
                                .frame(width: tabSize, height: 50)
                            }
                        }
                    }
                    
                    //밑줄
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: tabSize / 2, height: 2)
                            .offset(x: CGFloat(selectedFilter) * tabSize + (tabSize / 4), y: -1)
                            .animation(.easeInOut(duration: 0.25), value: selectedFilter)
                    }
                }
            }
            .frame(height: 55)
            
            
            if selectedFilter == 0 {
                FriendsPostsView(userUUID: userUUID)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                FriendsCalendarView(userUUID: userUUID)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

        }
    }
}


//#Preview {
//    FriendsCustomTabView()
//}
