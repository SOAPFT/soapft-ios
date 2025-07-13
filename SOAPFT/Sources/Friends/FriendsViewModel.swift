//
//  FriendsViewModel.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/12/25.
//

import Foundation
import Combine

final class FriendsViewModel: ObservableObject {
    
    @Published var friends: [Friend] = []
    @Published var filteredFriends: [SearchedFriend] = []
    @Published var searchText: String = ""
    @Published var receivedRequests: [ReceivedFriendRequest] = []
    
    private let friendService = FriendService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 검색어가 변경될 때마다 필터링 자동 반영
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newText in
                self?.performSearch(for: newText)
            }
            .store(in: &cancellables)
    }
    
    // 친구 목록 조회 API 호출
    func fetchFriends() {
        friendService.fetchFriendList { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let friends):
                    self?.friends = friends
                    self?.filteredFriends = friends.map {
                        SearchedFriend(
                            userUuid: $0.friendUuid,
                            nickname: $0.nickname,
                            profileImage: $0.profileImage ?? "",
                            isFriend: true
                        )
                    }
                case .failure(let error):
                    print("❌ 친구 목록 조회 실패: \(error.localizedDescription)")
                }
            }
        }

    }
    
    // 받은 친구 요청 목록 조회
    func fetchRequestFriends() {
        guard let token = KeyChainManager.shared.read(forKey: "accessToken") else {
            print("❌ accessToken 없음")
            return
        }

        print("🔑 accessToken 확인: \(token)")

        friendService.fetchReceivedRequests { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let requests):
                    print("✅ 받은 친구 요청 목록 수신 성공")
                    self?.receivedRequests = requests
                case .failure(let error):
                    print("❌ 받은 친구 요청 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 검색어에 맞게 친구 목록 필터링
    private func performSearch(for keyword: String) {
        if keyword.isEmpty {
            filteredFriends = []
            return
        }

        friendService.searchFriends(keyword: keyword) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let searched):
                    // 이미 친구인 사람은 friends에 있기 때문에 제외
                    let existingUUIDs = Set(self?.friends.map { $0.friendUuid } ?? [])
                    self?.filteredFriends = searched.filter { !existingUUIDs.contains($0.userUuid) }
                    print("🔍 검색 결과 중 친구 아님: \((self?.filteredFriends.count) ?? 0)명")
                case .failure(let error):
                    print("❌ 검색 실패: \(error.localizedDescription)")
                    self?.filteredFriends = []
                }
            }
        }
    }
}
