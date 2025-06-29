//
//  MockData.swift
//  SOAPFT
//
//  Created by 바견규 on 6/28/25.
//

import Foundation

let me = SenderDTO(
    userUuid: "01HZQK5J8X2M3N4P5Q6R7S8T9V",
    nickname: "운동러버",
    profileImage: "https://example.com/profile.jpg"
)

let other = SenderDTO(
    userUuid: "01HZQK5J8X2M3N4P5Q6R7S8T9W",
    nickname: "헬스마니아",
    profileImage: "https://example.com/other.jpg"
)

let mockMessages: [ChatMessageDTO] = [
    ChatMessageDTO(
        id: 1,
        content: "오늘은 운동 전에 워밍업을 좀 더 길게 해봤어요. 효과가 있는지 땀이 더 잘 나네요.",
        type: "TEXT",
        imageUrl: nil,
        sender: other,
        replyTo: nil,
        readByUuids: [me.userUuid, other.userUuid],
        isEdited: false,
        isDeleted: false,
        sentAt: ISO8601DateFormatter().date(from: "2025-06-22T09:00:00Z")!,
        editedAt: nil
    ),
    ChatMessageDTO(
        id: 2,
        content: "저도 어제 스트레칭을 10분 정도 했는데 확실히 몸이 더 가볍더라고요!",
        type: "TEXT",
        imageUrl: nil,
        sender: me,
        replyTo: ReplyToDTO(
            messageId: 1,
            content: "워밍업을 좀 더 길게 해봤어요",
            sender: ReplySenderDTO(userUuid: other.userUuid, nickname: other.nickname)
        ),
        readByUuids: [me.userUuid],
        isEdited: false,
        isDeleted: false,
        sentAt: ISO8601DateFormatter().date(from: "2025-06-22T09:05:00Z")!,
        editedAt: nil
    ),
    ChatMessageDTO(
        id: 3,
        content: "오늘은 헬스장 사람이 너무 많아서 기다리다가 시간 다 갔네요 ㅠㅠ",
        type: "TEXT",
        imageUrl: nil,
        sender: other,
        replyTo: nil,
        readByUuids: [me.userUuid, other.userUuid],
        isEdited: false,
        isDeleted: false,
        sentAt: ISO8601DateFormatter().date(from: "2025-06-22T09:10:00Z")!,
        editedAt: nil
    ),
    ChatMessageDTO(
        id: 4,
        content: "운동하고 난 뒤 셀카 🤳",
        type: "TEXT",
        imageUrl: "https://soapft-bucket.s3.amazonaws.com/images/sweat.jpg",
        sender: me,
        replyTo: nil,
        readByUuids: [me.userUuid],
        isEdited: false,
        isDeleted: false,
        sentAt: ISO8601DateFormatter().date(from: "2025-06-22T09:11:00Z")!,
        editedAt: nil
    ),
    ChatMessageDTO(
        id: 5,
        content: "사진 보니까 땀 정말 많이 흘리셨네요! 열심히 하셨다 💪",
        type: "TEXT",
        imageUrl: nil,
        sender: other,
        replyTo: ReplyToDTO(
            messageId: 4,
            content: "운동하고 난 뒤 셀카 🤳",
            sender: ReplySenderDTO(userUuid: me.userUuid, nickname: me.nickname)
        ),
        readByUuids: [me.userUuid, other.userUuid],
        isEdited: false,
        isDeleted: false,
        sentAt: ISO8601DateFormatter().date(from: "2025-06-22T09:13:00Z")!,
        editedAt: nil
    )
]
