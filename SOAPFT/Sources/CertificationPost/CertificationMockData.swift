//
//  CertificationMockData.swift
//  SOAPFT
//
//  Created by 바견규 on 7/2/25.
//

let CertificationMockData = ChallengePostData(
    posts: [
        ChallengePost(
            postUuid: "01HXX1X1X1X1X1X1X1X1X1X1X1",
            content: "푸시업 완료! \n푸시업바 뒤에 보이시죠?",
            imageUrl: ["https://velog.velcdn.com/images/mazorika/post/bb01b28d-8759-4846-8550-a7cbccc1a600/image.jpeg","https://velog.velcdn.com/images/mazorika/post/1b6e082b-35b5-45c5-ab0b-125b62bf84ec/image.jpeg","https://velog.velcdn.com/images/mazorika/post/028ca7aa-20e7-434b-8b9c-857a0d35c3d9/image.jpeg"],
            likeCount: 24,
            commentCount: 5,
            createdAt: "2025-06-22T12:00:00.000Z",
            author: PostAuthor(
                userUuid: "01HXX3X3X3X3X3X3X3X3X3X3X3",
                nickname: "박하루씨",
                profileImage: "https://velog.velcdn.com/images/mazorika/profile/06dd6bd0-eff5-43ba-a86d-9757085c49a1/social_profile.jpeg"
            )
        ),
        ChallengePost(
            postUuid: "01HYY2Y2Y2Y2Y2Y2Y2Y2Y2Y2Y2",
            content: "아침에 러닝 완료!",
            imageUrl: ["https://i.pravatar.cc/300?img=20"],
            likeCount: 12,
            commentCount: 3,
            createdAt: "2025-06-22T08:00:00.000Z",
            author: PostAuthor(
                userUuid: "01HYY4Y4Y4Y4Y4Y4Y4Y4Y4Y4Y4",
                nickname: "닉네임2",
                profileImage: "https://i.pravatar.cc/100?img=2"
            )
        ),
        ChallengePost(
            postUuid: "01HZZ3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3",
            content: "스트레칭 완료~",
            imageUrl: [],
            likeCount: 7,
            commentCount: 0,
            createdAt: "2025-06-21T20:30:00.000Z",
            author: PostAuthor(
                userUuid: "01HZZ5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5",
                nickname: "닉네임3",
                profileImage: "https://i.pravatar.cc/100?img=3"
            )
        )
    ],
    pagination: Pagination(
        currentPage: 1,
        totalPages: 5,
        totalItems: 50,
        itemsPerPage: 10
    )
)


let PostCardMockData = ChallengePost(
    postUuid: "01HZZ3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3",
    content: "푸시업 완료! \n푸시업바 뒤에 보이시죠?",
    imageUrl: ["https://velog.velcdn.com/images/mazorika/post/bb01b28d-8759-4846-8550-a7cbccc1a600/image.jpeg","https://velog.velcdn.com/images/mazorika/post/1b6e082b-35b5-45c5-ab0b-125b62bf84ec/image.jpeg","https://velog.velcdn.com/images/mazorika/post/028ca7aa-20e7-434b-8b9c-857a0d35c3d9/image.jpeg"],
    likeCount: 7,
    commentCount: 0,
    createdAt: "2025-06-21T20:30:00.000Z",
    author: PostAuthor(
        userUuid: "01HZZ5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5",
        nickname: "박하루씨",
        profileImage: "https://velog.velcdn.com/images/mazorika/profile/06dd6bd0-eff5-43ba-a86d-9757085c49a1/social_profile.jpeg"
    )
)
