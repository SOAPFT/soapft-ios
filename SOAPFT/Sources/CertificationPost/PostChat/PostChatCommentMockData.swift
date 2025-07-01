//
//  PostChatCommentMockData.swift
//  SOAPFT
//
//  Created by 바견규 on 7/2/25.
//

import Foundation

struct PostChatCommentMockData {
    static let sample: CommentResponse = CommentResponse(
        comments: [
            Comment(
                id: 1001,
                content: "정말 멋져요! 자극받고 갑니다 😍",
                author: Author(
                    userUuid: "U001",
                    nickname: "피트니스초보",
                    profileImage: "https://randomuser.me/api/portraits/women/1.jpg"
                ),
                parentCommentId: nil,
                mentionedUsers: [],
                replies: [
                    Reply(
                        id: 2001,
                        content: "같이 열심히 해봐요! 화이팅 🔥",
                        author: Author(
                            userUuid: "U002",
                            nickname: "근육질청년",
                            profileImage: "https://randomuser.me/api/portraits/men/2.jpg"
                        ),
                        parentCommentId: 1001,
                        createdAt: "2025-06-22T12:45:00.000Z"
                    )
                ],
                replyCount: 1,
                createdAt: "2025-06-22T12:00:00.000Z",
                updatedAt: "2025-06-22T12:00:00.000Z"
            ),
            Comment(
                id: 1002,
                content: "식단도 공유해주시면 좋겠어요 🥗",
                author: Author(
                    userUuid: "U003",
                    nickname: "다이어터",
                    profileImage: "https://randomuser.me/api/portraits/women/3.jpg"
                ),
                parentCommentId: nil,
                mentionedUsers: [],
                replies: [],
                replyCount: 0,
                createdAt: "2025-06-22T13:10:00.000Z",
                updatedAt: "2025-06-23T13:10:00.000Z"
            ),
            Comment(
                id: 1003,
                content: "운동 루틴 참고해도 될까요? 💪",
                author: Author(
                    userUuid: "U004",
                    nickname: "바벨러",
                    profileImage: "https://randomuser.me/api/portraits/men/4.jpg"
                ),
                parentCommentId: nil,
                mentionedUsers: [],
                replies: [
                    Reply(
                        id: 2002,
                        content: "물론이죠! DM 주세요 😄",
                        author: Author(
                            userUuid: "U005",
                            nickname: "헬스왕",
                            profileImage: "https://randomuser.me/api/portraits/men/5.jpg"
                        ),
                        parentCommentId: 1003,
                        createdAt: "2025-06-22T13:30:00.000Z"
                    )
                ],
                replyCount: 1,
                createdAt: "2025-06-22T13:00:00.000Z",
                updatedAt: "2025-06-22T13:00:00.000Z"
            )
        ],
        pagination: Pagination(
            currentPage: 1,
            totalPages: 2,
            totalItems: 25,
            itemsPerPage: 10
        )
    )
}
