//
//  FriendsCalendarViewModel.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/13/25.
//

import Foundation
import Combine

final class FriendsCalendarViewModel: ObservableObject {
    var container: DIContainer!
    private let userUUID: String

    @Published var calendarData: [OtherUserCalendarResponseDTO.DatePosts] = []
    @Published var isLoading: Bool = false

    init(container: DIContainer, userUUID: String) {
        self.container = container
        self.userUUID = userUUID
    }

    func fetchCalendar(userUuid: String, year: Int, month: Int) {
        guard let accessToken = KeyChainManager.shared.read(forKey: "accessToken") else {
            print("❌ accessToken 없음")
            return
        }
        
        guard !isLoading else {
            print("⚠️ [FriendsCalendarViewModel] 이미 로딩 중입니다. 중복 호출 방지됨.")
            return
        }
        
        isLoading = true
        print("📡 [FriendsCalendarViewModel] fetchCalendar called")
        print("🧾 userUUID: \(userUUID), year: \(year), month: \(month)")
        
        PostService.shared.getUserCalendar(userUuid: userUUID, year: year, month: month, accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    print("✅ [FriendsCalendarViewModel] Calendar fetch 성공")
                    print("📅 날짜 개수: \(response.data.count)")
                    self.calendarData.append(contentsOf: response.data)
                case .failure(let error):
                    print("❌ [FriendsCalendarViewModel] Calendar fetch 실패: \(error.localizedDescription)")
                }
            }
        }
    }


    func imageURL(for date: Date) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        guard let datePost = calendarData.first(where: { $0.date == dateString }),
              let firstPost = datePost.posts.first else {
            return nil
        }
        return firstPost.imageUrl[0]
    }
}
