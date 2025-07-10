//
//  CalendarViewModel.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/10/25.
//

import Foundation
import Combine

final class CalendarViewModel: ObservableObject {
    var container: DIContainer!
    
    @Published var calendarData: [MyCalendarResponseDTO.DatePosts] = []
    @Published var isLoading: Bool = false
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func fetchCalendar(year: Int, month: Int) {
        guard !isLoading else { return }
        isLoading = true
        
        container.postService.getCalendar(year: year, month: month) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    let newDates = response.data.filter { newDatePost in
                        !self.calendarData.contains(where: { $0.date == newDatePost.date})
                    }
                    self.calendarData.append(contentsOf: newDates)
                    print("✅ 캘린더 데이터: \(response.data.count)일")
                case .failure(let error):
                    print("❌ 캘린더 실패: \(error.localizedDescription)")
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
        return firstPost.imageUrl.first
    }
}
