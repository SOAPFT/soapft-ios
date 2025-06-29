//
//  ChatRoomViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI

final class ChatRoomViewModel: ObservableObject {
    @Published var messages: [ChatMessageDTO]
    @Published var messageText: String = ""

    let currentUserUuid: String

    init(messages: [ChatMessageDTO], currentUserUuid: String) {
        self.messages = messages
        self.currentUserUuid = currentUserUuid
    }

    func sendMessage() {
        let newMessage = ChatMessageDTO(
            id: messages.count + 1,
            content: messageText,
            type: "TEXT",
            imageUrl: nil,
            sender: SenderDTO(userUuid: currentUserUuid, nickname: "운동러버", profileImage: "https://example.com/profile.jpg"),
            replyTo: nil,
            readByUuids: [currentUserUuid],
            isEdited: false,
            isDeleted: false,
            sentAt: Date(),
            editedAt: nil
        )

        messages.append(newMessage)
        messageText = ""
    }
}


