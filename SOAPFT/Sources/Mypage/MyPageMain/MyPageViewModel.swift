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
        guard let accessToken = KeyChainManager.shared.read(forKey: "accessToken") else {
            print("[MyPageViewModel] accessToken 없음")
            return
        }
        print("[MyPageViewModel] accessToken 있음: \(accessToken)")
    
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
                    print("[MyPageViewModel] 프로필 성공: \(profile)")
                case .failure(let error):
                    print("[MyPageViewModel] 프로필 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchNotificationCount() {
        guard let accessToken = KeyChainManager.shared.readAccessToken() else {
            print("[MyPageViewModel] accessToken 없음")
            return
        }
        
        container.notificationsService.fetchUnreadCount(accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let noti):
                    self?.notificationCount = noti.unreadCount
                    print("[MyPageViewModel] 알림 개수 fetch 성공: \(noti)")
                case .failure(let error):
                    print("[MyPageViewModel] 알림 개수 fetch 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateProfile(comperion: (() -> Void)? = nil) {
        guard let accessToken = KeyChainManager.shared.readAccessToken() else {
            print("[MyPageViewModel] accessToken 없음")
            return
        }
        
        let nickname = userName
        let introduction = userIntroduction ?? ""
        let profileImg = userImage ?? ""
        
        container.userService.updateProfile(newNickname: nickname, newIntroduction: introduction, newProfileImg: profileImg, accessToken: accessToken) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("[MyPageViewModel] 프로필 수정 성공: \(response.message)")
                case .failure(let error):
                    print("[MyPageViewModel] 프로필 수정 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteProfile(completion: @escaping (Bool, String?) -> Void) {
        guard let accessToken = KeyChainManager.shared.readAccessToken() else {
            print("[MyPageViewModel] accessToken 없음")
            return
        }
        
        container.userService.deleteProfile(accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    print("[MyPageViewModel] 계정 삭제 성공: \(res.message)")
                    // 토큰·세션 정리 (프로젝트에서 실사용하는 키 전부 제거)
                    KeyChainManager.shared.delete(forKey: "jwtToken")
                    KeyChainManager.shared.delete(forKey: "refreshToken")
                    KeyChainManager.shared.delete(forKey: "accessToken")
                    
                    // 필요하면 ViewModel 상태 초기화
                    self?.userName = ""
                    self?.userImage = nil
                    self?.userIntroduction = nil
                    self?.userUuid = ""
                    self?.coins = 0
                    self?.postCount = 0
                    self?.friendCount = 0
                    self?.notificationCount = 0

                    completion(true, res.message)

                case .failure(let error):
                    print("[MyPageViewModel] 계정 삭제 실패: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
}
