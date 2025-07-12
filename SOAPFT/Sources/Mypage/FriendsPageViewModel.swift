//
//  FriendsPageViewModel.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/12/25.
//

import Foundation
import Combine

final class FriendsPageViewModel: ObservableObject {
    private let friendService = FriendService()
    
    @Published var nickname: String = ""
    @Published var postCount: Int = 0
    @Published var friendCount: Int = 0
    @Published var coinCount: Int = 0
    
    @Published var isFriend: Bool = false
    @Published var isSentFriendRequest: Bool = false
    @Published var isRecievedFriendRequest: Bool = false
    
    // API 호출 상태 관리용
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var userUUID: String
    private var accessToken: String
    
    private var cancellables = Set<AnyCancellable>()
    
    init(userUUID: String, accessToken: String) {
        self.userUUID = userUUID
        self.accessToken = accessToken
    }
    
    func fetchOtherUserInfo() {
        isLoading = true
        errorMessage = nil
        
        UserService.shared.getOtherUserInfo(userUUID: userUUID, accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let userInfo):
                    self?.nickname = userInfo.userName
                    self?.postCount = userInfo.postCount
                    self?.friendCount = userInfo.friendCount
                    self?.coinCount = 0 // 응답에 없으면 기본값
                    
                    // friendStatus 값에 따라 상태 세팅
                    switch userInfo.friendStatus {
                    case .friends:
                        self?.isFriend = true
                        self?.isSentFriendRequest = false
                        self?.isRecievedFriendRequest = false
                    case .requestSent:
                        self?.isFriend = false
                        self?.isSentFriendRequest = true
                        self?.isRecievedFriendRequest = false
                    case .requestReceived:
                        self?.isFriend = false
                        self?.isSentFriendRequest = false
                        self?.isRecievedFriendRequest = true
                    default:
                        self?.isFriend = false
                        self?.isSentFriendRequest = false
                        self?.isRecievedFriendRequest = false
                    }
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // 친구 요청 보내기
    func sendFriendRequest() {
        friendService.sendFriendRequest(to: userUUID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isSentFriendRequest = true
                    self?.isFriend = false
                    self?.isRecievedFriendRequest = false
                    print("✅ 친구 요청 성공")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ 친구 요청 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 친구 요청 수락
    func acceptFriendRequest() {
        // 요청 ID가 필요할 경우 로직 추가해야 함
        let dummyRequestId = "request-id-placeholder"  // ✅ 실제 요청 ID로 교체
        friendService.acceptFriendRequest(requestId: dummyRequestId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isFriend = true
                    self?.isSentFriendRequest = false
                    self?.isRecievedFriendRequest = false
                    print("✅ 친구 수락 성공")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ 친구 수락 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 친구 삭제
    func deleteFriend() {
        friendService.deleteFriend(friendId: userUUID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isFriend = false
                    self?.isSentFriendRequest = false
                    self?.isRecievedFriendRequest = false
                    print("✅ 친구 삭제 성공")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ 친구 삭제 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}
