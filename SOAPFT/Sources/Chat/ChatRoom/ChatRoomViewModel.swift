//
//  ChatRoomViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//


import SwiftUI

final class ChatRoomViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var messageText: String = ""

    private let chatService: ChatService
    private var currentPage: Int = 1
    private var hasMore: Bool = true
    private var isLoading: Bool = false

    let currentUserUuid: String
    private let roomId: String
    
    //스크롤바 이동
    @Published var lastMessageIdToScroll: Int? = nil

    /// 가장 오래된 메시지의 ID (이전 메시지 불러올 때 사용)
    private var lastMessageId: Int? = nil

    init(
        roomId: String,
        currentUserUuid: String,
        chatService: ChatService
    ) {
        self.roomId = roomId
        self.currentUserUuid = currentUserUuid
        self.chatService = chatService
        fetchInitialMessages(limit: 15)
    }
    
    func fetchInitialMessages(limit: Int = 15) {
        guard !isLoading else { return }
        isLoading = true
        chatService.getMessages(
            roomId: roomId,
            page: 1,
            limit: limit,
            lastMessageId: nil,
            beforeMessageId: nil
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let response):
                    self.messages = response.messages

                    if let firstId = response.messages.first?.id {
                        self.lastMessageId = firstId
                    }

                    self.hasMore = response.pagination.hasNext ?? false
                    self.currentPage = 2

                case .failure(let error):
                    print("❌ 초기 메시지 불러오기 실패: \(error)")
                }
            }
        }
    }

    
    //MARK: - 위로 스크롤하여 이전 메시지 로딩
    func fetchMorePreviousMessages(limit: Int = 15) {
        guard !isLoading, hasMore else { return }
        guard let lastId = lastMessageId else { return }

        isLoading = true

        chatService.getMessages(
            roomId: roomId,
            page: currentPage,
            limit: limit,
            lastMessageId: lastId,
            beforeMessageId: nil
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let response):
                    let newMessages = response.messages
                    self.messages.insert(contentsOf: newMessages, at: 0)

                    // 다음 페이지를 위해 가장 오래된 메시지 ID 저장
                    if let newLast = newMessages.first?.id {
                        self.lastMessageId = newLast
                    }

                    // 더 이상 불러올 메시지가 없으면 hasMore = false
                    if newMessages.isEmpty || response.pagination.hasNext == false {
                        self.hasMore = false
                    } else {
                        self.currentPage += 1
                    }

                case .failure(let error):
                    print("❌ 이전 메시지 불러오기 실패: \(error)")
                }
            }
        }
    }
    
    //MARK: - 메시지 전송
    func postMessage(type: String) {
        guard !isLoading, !messageText.isEmpty else { return }
        
        isLoading = true
        
        chatService.sendMessage(roomId: roomId, content: messageText, type: type) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let response):
                    print("✅ 전송 성공")
                    
                    // 1. 메시지 리스트에 추가
                    self.messages.append(response)

                    // 3. 스크롤 아래로 이동 등 UI 갱신 필요 시 처리
                    self.lastMessageIdToScroll = response.id
                    
                case .failure(let error):
                    print("❌ 메시지 전송 실패: \(error)")
                }
            }
        }
    }


}


