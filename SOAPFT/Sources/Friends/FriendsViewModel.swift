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
    @Published var filteredFriends: [Friend] = []
    @Published var searchText: String = ""
    
    private let friendService = FriendService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 검색어가 변경될 때마다 필터링 자동 반영
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterFriends()
            }
            .store(in: &cancellables)
    }
    
    // 친구 목록 조회 API 호출
    func fetchFriends() {
        let parameters: [String: Any] = [:]  // 필요한 파라미터 넣기 (ex. 페이징, 필터 등)
                
        friendService.fetchFriendList(parameters: parameters) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let friends):
                    print("✅ 친구 목록 조회 성공 - \(friends.count)명")
                    self?.friends = friends
                    self?.filteredFriends = friends
                case .failure(let error):
                    print("❌ 친구 목록 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 검색어에 맞게 친구 목록 필터링
    func filterFriends() {
        if searchText.isEmpty {
            filteredFriends = friends
        } else {
            filteredFriends = friends.filter {
                $0.nickname.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
