//
//  ChatListViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI

class ChatListViewModel: ObservableObject {
    @Published var chatRooms: [ChatRoomDTO] = []

    init() {
        loadMockData()
    }

    func loadMockData() {
        chatRooms = mockChatRooms
    }
}

