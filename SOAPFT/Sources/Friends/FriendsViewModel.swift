//
//  FriendsViewModel.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/12/25.
//

import Foundation
import Combine

final class FriendsViewModel: ObservableObject {
    // UI 바인딩
    @Published var friends: [Friend] = []
    @Published var filteredFriends: [SearchedFriend] = []
    @Published var searchText: String = ""
    @Published var receivedRequests: [ReceivedFriendRequest] = []

    // 내 UUID (친구요청 상세 이동 등에 사용)
    @Published var userUuid: String?

    // 서비스
    private let friendService = FriendService()
    private let userService = UserService()

    private var cancellables = Set<AnyCancellable>()

    init() {
        // 검색어 변경 → 300ms 디바운스 → 중복 제거 → 검색 수행
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newText in
                self?.performSearch(for: newText)
            }
            .store(in: &cancellables)

        // 진입 시 내 UUID 확보 후 필요한 리스트 로드
        fetchUserUuidAndThenFriends()
    }

    // MARK: - 내 UUID 가져온 뒤 필요한 목록 호출
    func fetchUserUuidAndThenFriends() {
        guard let token = KeyChainManager.shared.read(forKey: KeyChainKey.accessToken) else {
            print("❌ accessToken 없음")
            return
        }

        userService.getUserInfo(accessToken: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ 내 UUID: \(response.userUuid)")
                    self?.userUuid = response.userUuid
                    // 내 UUID 확보 후 원하는 로직 실행
                    self?.fetchFriends()
                    self?.fetchRequestFriends()
                case .failure(let error):
                    print("❌ 유저 정보 불러오기 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - 친구 목록
    func fetchFriends() {
        friendService.fetchFriendList { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let friends):
                    self?.friends = friends
                    // 화면에서 바로 표시 가능한 형태로 변환 (이미 친구인 목록)
                    self?.filteredFriends = friends.map {
                        SearchedFriend(
                            userUuid: $0.friendUuid,
                            nickname: $0.nickname?.isEmpty == false ? $0.nickname! : "알 수 없음",
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

    // MARK: - 받은 친구 요청 목록
    func fetchRequestFriends() {
        guard KeyChainManager.shared.read(forKey: KeyChainKey.accessToken) != nil else {
            print("❌ accessToken 없음")
            return
        }

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

    // MARK: - 검색
    private func performSearch(for keyword: String) {
        if keyword.isEmpty {
            filteredFriends = []
            return
        }

        friendService.searchFriends(keyword: keyword) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let searched):
                    // 이미 친구인 사람 제외
                    let existingUUIDs = Set(self?.friends.map { $0.friendUuid } ?? [])
                    self?.filteredFriends = searched.filter { !existingUUIDs.contains($0.userUuid) }
                    print("🔍 검색 결과(친구 제외) \(self?.filteredFriends.count ?? 0)명")
                case .failure(let error):
                    print("❌ 검색 실패: \(error.localizedDescription)")
                    self?.filteredFriends = []
                }
            }
        }
    }
}
