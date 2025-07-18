//
//  ChatListViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI

class ChatListViewModel: ObservableObject {
    @Published var chatRooms: [ChatRoom] = []
    @Published var isLoading = false
    @Published var hasMore = true

    private let chatService: ChatService
    private let userService: UserService
    private var currentPage = 1
    private let limit = 15
    var userUuid: String?

    init(chatService: ChatService, userService: UserService) {
        self.chatService = chatService
        self.userService = userService
        fetchUserUuidAndThenChatRooms()
    }

    private func fetchUserUuidAndThenChatRooms() {
        guard let token = KeyChainManager.shared.read(forKey: KeyChainKey.accessToken) else {
            print("❌ 토큰을 읽을 수 없습니다.")
            return
        }

        print("✅ 저장 후 읽은 토큰: \(token)")
        userService.getUserInfo(accessToken: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.userUuid = response.userUuid
                    self?.fetchChatRooms() // ✅ 순서 보장
                case .failure(let error):
                    print("❌ 유저 정보 불러오기 실패: \(error)")
                }
            }
        }
    }

    func fetchChatRooms() {
        guard !isLoading && hasMore else { return }
        isLoading = true

        chatService.getRooms(type: nil, page: currentPage, limit: limit) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    self.chatRooms.append(contentsOf: response.chatRooms)
                    self.hasMore = response.chatRooms.count == self.limit
                    self.currentPage += 1
                case .failure(let error):
                    print("❌ 채팅방 불러오기 실패: \(error)")
                    self.hasMore = false
                }
            }
        }
    }
}

