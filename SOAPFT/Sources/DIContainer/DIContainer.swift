//
//  DIContainer.swift
//  SOAPFT
//
//  Created by 바견규 on 7/5/25.
//

import SwiftUI
import Combine

final class DIContainer: ObservableObject {
    // 뷰 이동 중앙 집중 관리
    let router: AppRouter
    
    
    // 뷰 수정, 생성, 삭제 시 호출할 데이터
    let challengeRefreshSubject = PassthroughSubject<Void, Never>()
    let chatRefreshSubject = PassthroughSubject<Void, Never>()
    let postRefreshSubject = PassthroughSubject<Void, Never>()
    
    // 모든 서비스 선언
    let authService: AuthService
    let userService: UserService
    let postService: PostService
    let likeService: LikeService
    let notificationsService: NotificationService
    let challengeService: ChallengeService
    let chatService: ChatService
    let friendService: FriendService
    let commentService: CommentService
    let evenetService: EventService
    let paymentService: PaymentService


    @Published var selectedTab: String = "Main"
    
    init(router: AppRouter) {
        self.router = router

        // 각 서비스 초기화
        self.authService = AuthService()
        self.userService = UserService()
        self.postService = PostService()
        self.likeService = LikeService()
        self.notificationsService = NotificationService()
        self.challengeService = ChallengeService()
        self.chatService = ChatService()
        self.friendService = FriendService()
        self.commentService = CommentService()
        self.evenetService = EventService()
        self.paymentService = PaymentService()
    }
}

private struct DIContainerKey: EnvironmentKey {
    static var defaultValue: DIContainer = DIContainer(router: AppRouter())
}

extension EnvironmentValues {
    var diContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
