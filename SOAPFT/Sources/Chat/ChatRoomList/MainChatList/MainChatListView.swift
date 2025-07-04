//
//  MainChatListView.swift
//  SOAPFT
//
//  Created by 바견규 on 7/5/25.
//

import SwiftUI

struct MainChatListView: View {
    let rooms: [ChatRoomDTO]

    var body: some View {
        VStack{
            MainChatListNavBar()
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(rooms, id: \.roomUuid) { room in
                        ChatRoomCell(room: room)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
}


#Preview {
    MainChatListView(rooms: mockChatRooms)
}
