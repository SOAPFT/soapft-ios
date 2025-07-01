//
//  ChatRoomListView.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI

struct ChatListView: View {
    let rooms: [ChatRoomDTO]

    var body: some View {
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

struct ChatRoomCell: View {
    let room: ChatRoomDTO

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: room.participants.first?.profileImage ?? "")) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(Image(systemName: "person.fill").foregroundStyle(.gray))
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(room.name)
                    .font(.system(size: 16, weight: .semibold))

                if let challenge = room.challenge {
                    Text(challenge.title)
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}


#Preview {
    ChatListNavBar()
    ChatListView(rooms: mockChatRooms)
}
