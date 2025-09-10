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
    @Published var userImage: String = ""
    @Published var userIntroduction: String = ""
    @Published var postCount: Int = 0
    @Published var friendCount: Int = 0
    @Published var friendStatus: String = ""
    @Published var friendId: Int = 0
    
    @Published var isFriend: Bool = false
    @Published var isSentFriendRequest: Bool = false
    @Published var isRecievedFriendRequest: Bool = false
    @Published var isBlocked: Bool = false
    
    // API 호출 상태 관리용
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var createdRoom: ChatRoomCreationResponse?
    
    var userUUID: String
    private var accessToken: String
    private var receivedRequestId: String? = nil
    
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
                    self?.nickname = userInfo.userName ?? ""
                    self?.userImage = userInfo.userImage ?? ""
                    self?.userIntroduction = userInfo.userIntroduction ?? ""
                    self?.userUUID = userInfo.userUuid
                    self?.postCount = userInfo.postCount
                    self?.friendCount = userInfo.friendCount
                    self?.friendStatus = userInfo.friendStatus
                    self?.friendId = userInfo.friendId ?? 0
                    
                    self?.updateFriendStatus(from: userInfo.friendStatus)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func updateFriendStatus(from status: String?) {
        isFriend = false
        isSentFriendRequest = false
        isRecievedFriendRequest = false
        isBlocked =  false
        
        switch status {
        case "friends":
            isFriend = true
        case "request_sent":
            isSentFriendRequest = true
        case "request_received":
            isRecievedFriendRequest = true
            fetchReceivedFriendRequestId()
        case "blocked":
            isBlocked = true
        default:
            break
        }
    }
    
    private func fetchReceivedFriendRequestId() {
        friendService.fetchReceivedRequests { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let requests):
                    if let matchedRequest = requests.first(where: { $0.requesterUuid == self?.userUUID }) {
                        self?.receivedRequestId = String(matchedRequest.requestId)
                    }
                case .failure(let error):
                    print("❌ 받은 친구 요청 조회 실패: \(error.localizedDescription)")
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
        friendService.acceptFriendRequest(friendId: String(friendId)) { [weak self] result in
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
        friendService.deleteFriend(friendId: String(friendId)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // 거절 후 처리 예: 상태 업데이트
                    self?.isSentFriendRequest = false
                    self?.isRecievedFriendRequest = false
                    print("✅ 친구 요청 거절 성공")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ 친구 요청 거절 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 채팅방 생성
    // 채팅방 생성
    func createChatRoom() {
        let chatService = ChatService()
        let type = "DIRECT"
        let participants = [userUUID]
        let name = "\(nickname)님과의 대화"
        let challengeUuid = ""

        chatService.createRoom(
            type: type,
            participantUuids: participants,
            name: name,
            challengeUuid: challengeUuid
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let room):
                    self?.createdRoom = room   // ✅ View로 전달
                    print("✅ 채팅방 생성 성공: \(room.roomUuid)")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ 채팅방 생성 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}
