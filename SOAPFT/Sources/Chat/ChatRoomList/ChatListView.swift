//
//  ChatRoomListView.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI

struct ChatListWrapper: View {
    @Environment(\.diContainer) private var container
    
    var body: some View {
        let viewModel = ChatListViewModel(chatService: container.chatService, userService: container.userService)
        ChatListView(viewModel: viewModel)
            .navigationBarBackButtonHidden(true)
            .onReceive(container.challengeRefreshSubject) { _ in
                print("📨 chatRefreshSubject 수신됨")
                viewModel.refreshChatRooms()
            }
    }
}


struct ChatListView: View {
    @StateObject private var viewModel: ChatListViewModel
    @Environment(\.diContainer) private var container

    init(viewModel: ChatListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    
    var body: some View {
        VStack {
            ChatListNavBar()
            Group {
                if let currentUserUuid = viewModel.userUuid {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.chatRooms, id: \.roomUuid) { room in
                                ChatRoomCell(room: room, currentUserUuid: currentUserUuid)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                } else {
                    ProgressView("사용자 정보 로딩 중...")
                }
            }
        }
    }
}

struct ChatRoomCell: View {
    let room: ChatRoom
    @Environment(\.diContainer) private var container
    let currentUserUuid: String
    
    
    var body: some View {
        Button(action: {
            container.router.push(.ChatRoomWrapper(currentUserUuid: currentUserUuid, roomId: room.roomUuid, chatRoomName: room.name))
        }) {
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
                        .foregroundStyle(.black)
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
}


#Preview {
    
}
