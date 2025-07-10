//
//  ChallengeSignUpMockData.swift
//  SOAPFT
//
//  Created by 바견규 on 7/1/25.
//

// 이 모델의 정의부는 Group Info Folder
let ChallengeSignUpMockData = ChallengeDetail(
    challengeUuid: "01HZQK5J8X2M3N4P5Q6R7S8T9V",
    title: "30일 헬스 챌린지",
    type: "NORMAL",
    profile: "https://img.freepik.com/free-photo/young-fitness-man-studio_7502-5008.jpg?semt=ais_hybrid&w=740",
    banner: "https://kr.imboldn.com/wp-content/uploads/2022/07/newbie_guide_fitness_pt1_main.jpg",
    introduce: "매일 헬스장에서 운동하고 인증하는 챌린지입니다!\n저희 열심히 해봐요!",
    startDate: "2025-07-01",
    endDate: "2025-07-31",
    goal: 5,
    startAge: 18,
    endAge: 65,
    gender: "ALL",
    maxMember: 50,
    currentMember: 25,
    coinAmount: 1000,
    isStarted: false,
    isFinished: false,
    creator: Creator(
        userUuid: "01HZQK5J8X2M3N4P5Q6R7S8T9V",
        nickname: "챌린지마스터",
        profileImage: "https://www.handmk.com/news/photo/202306/16714_40371_5250.jpg"
    ),
    participants: [
        Participant(
            userUuid: "01HZQK5J8X2M3N4P5Q6R7S8T9V",nickname: "챌린지마스터",profileImage: "https://www.handmk.com/news/photo/202306/16714_40371_5250.jpg", joinedAt: "2025-06-22T12:00:00Z"
        ),
        Participant(userUuid: "f3a55b15-c2bf-43ca-ab1e-dc7dbdea21eb", nickname: "헬스초보", profileImage: "https://i.pravatar.cc/150?img=1", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "0630aca2-98b2-4d67-aa42-b9015e073037", nickname: "근육돼지", profileImage: "https://i.pravatar.cc/150?img=2", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "170c7924-0798-47f7-91f8-125dfe8593f8", nickname: "헬창왕자", profileImage: "https://i.pravatar.cc/150?img=3", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "24a85dcb-9f5d-4290-9eaf-8912099e1b30", nickname: "요가요정", profileImage: "https://i.pravatar.cc/150?img=4", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "063414ec-e893-4cf1-af72-2471c71e6dc3", nickname: "스쿼트달인", profileImage: "https://i.pravatar.cc/150?img=5", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "ac6f18ab-15f8-493d-a545-89afaa04f270", nickname: "런닝맨", profileImage: "https://i.pravatar.cc/150?img=6", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "3085f74a-b703-45e1-a10e-1e2411097d8c", nickname: "홈트마스터", profileImage: "https://i.pravatar.cc/150?img=7", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "269e7cb5-6f5b-47f0-8574-46460b33808e", nickname: "단백질중독", profileImage: "https://i.pravatar.cc/150?img=8", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "2c15e816-348b-4b93-8508-580e39a0c6b6", nickname: "복근조각가", profileImage: "https://i.pravatar.cc/150?img=9", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "39d3b012-9301-45d2-87ff-5cb3e20f89cb", nickname: "팔씨름왕", profileImage: "https://i.pravatar.cc/150?img=10", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "6b5e4f65-233f-4057-9216-b95aa49d889e", nickname: "스핀사이클러", profileImage: "https://i.pravatar.cc/150?img=11", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "ff0201d3-3b5b-4624-b154-66a0c3ffad45", nickname: "헬스요정", profileImage: "https://i.pravatar.cc/150?img=12", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "ba8e6502-1070-4e0f-99dc-ea0b3a404bb3", nickname: "웨이트좀친", profileImage: "https://i.pravatar.cc/150?img=13", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "faed6fc3-fbb5-4e1d-82d0-00147bc202dd", nickname: "지구력갑", profileImage: "https://i.pravatar.cc/150?img=14", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "99d96cd2-93e3-4a98-b2d1-3be7a9dbdb20", nickname: "스트레칭장인", profileImage: "https://i.pravatar.cc/150?img=15", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "ecb7256d-2b36-444e-b571-5ccdd4875aa9", nickname: "케틀벨러", profileImage: "https://i.pravatar.cc/150?img=16", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "04f05765-9d86-4e3e-9e70-dce80895fd40", nickname: "PT고수", profileImage: "https://i.pravatar.cc/150?img=17", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "6b143f9c-cfc4-4dc2-9b3d-050a3b32002f", nickname: "운동중독자", profileImage: "https://i.pravatar.cc/150?img=18", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "e570b8df-438e-423b-bf27-92b8e469efad", nickname: "헬스천재", profileImage: "https://i.pravatar.cc/150?img=19", joinedAt: "2025-06-22T12:00:00Z"),
        Participant(userUuid: "8c06a0c0-95e7-4e0d-9769-964f7a0f1ee3", nickname: "식단지옥인간", profileImage: "https://i.pravatar.cc/150?img=20", joinedAt: "2025-06-22T12:00:00Z")
    ]
,
    isParticipating: false,
    createdAt: "2025-06-22T12:00:00Z",
    updatedAt: "2025-06-22T12:00:00Z"
)

