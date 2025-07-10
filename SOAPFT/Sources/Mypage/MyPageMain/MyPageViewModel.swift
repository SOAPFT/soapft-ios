//
//  MyPageViewModel.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/10/25.
//

import Foundation

final class MyPageViewModel: ObservableObject {
    var container: DIContainer!
    
    @Published var userName: String = ""
    @Published var userImage: String? = nil
    @Published var userIntroduction: String? = nil
    @Published var userUuid: String = ""
    @Published var coins: Int = 0
    @Published var postCount: Int = 0
    @Published var friendCount: Int = 0
    
    @Published var notificationCount: Int = 0 // 필요시 사용
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func fetchUserProfile() {
        guard let accessToken = KeyChainManager.shared.readAccessToken() else {
            print("❌ accessToken 없음")
            return
        }
//        let accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyVXVpZCI6IjAxSllLVk4xOE1DVzVCOUZaMVBQN1QxNFhTIiwiaWF0IjoxNzUxOTAzNDA0LCJleHAiOjE3NTQ0OTU0MDR9.eeETUYLQy_W14flyNrvkSkJQm4CfqfsbrtfN7dOssl8"
        
        container.userService.getUserInfo(accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.userName = profile.userName ?? ""
                    self?.userImage = profile.userImage
                    self?.userIntroduction = profile.userIntroduction
                    self?.userUuid = profile.userUuid
                    self?.coins = profile.coins
                    self?.postCount = profile.postCount
                    self?.friendCount = profile.friendCount
                    print("✅ 프로필 성공: \(profile)")
                case .failure(let error):
                    print("❌ 프로필 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchNotificationCount() {
        guard let accessToken = KeyChainManager.shared.readAccessToken() else {
            print("❌ accessToken 없음")
            return
        }
        
        container.notificationsService.fetchUnreadCount(accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let noti):
                    self?.notificationCount = noti.unreadCount
                    print("✅ 알림 개수 fetch 성공: \(noti)")
                case .failure(let error):
                    print("❌ 알림 개수 fetch 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateProfile(comperion: (() -> Void)? = nil) {
        guard let accessToken = KeyChainManager.shared.readAccessToken() else {
            print("❌ accessToken 없음")
            return
        }
        
        let nickname = userName
        let introduction = userIntroduction ?? ""
        let profileImg = userImage ?? ""
        
        container.userService.updateProfile(newNickname: nickname, newIntroduction: introduction, newProfileImg: profileImg, accessToken: accessToken) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ 프로필 수정 성공: \(response.message)")
                case .failure(let error):
                    print("❌ 프로필 수정 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}
