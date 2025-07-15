//
//  AppRouter.swift
//  SOAPFT
//
//  Created by 바견규 on 7/5/25.
//

import SwiftUI

enum Route: Hashable {
    case login
    case loginInfo
    case mainTabbar
    case groupEdit
    case home
    case friendPage(userUUID: String, accessToken: String)
    case friendsRequest
    case groupCreate
    case groupCreateNext
    case mypage
    case mypageEdit
    case mypageEditInfo
    case alert
    case GroupTabbar(ChallengeID: String)
    case ChallengeSearchWrapper
    case ChatRoomWrapper(currentUserUuid: String, roomId: String, chatRoomName: String)
    case ChatListWrapper
}

class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func push(_ route: Route) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func reset() {
        path = NavigationPath()
    }
}
