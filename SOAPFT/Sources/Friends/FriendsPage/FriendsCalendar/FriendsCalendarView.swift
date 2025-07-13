//
//  FriendsCalendarView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/13/25.
//

import SwiftUI
import SwiftData

struct FriendsCalendarView: View {
    @Environment(\.diContainer) private var container
    
    @StateObject private var viewModel: FriendsCalendarViewModel
    @State private var clickedDates: Set<Date> = []
    @State private var monthsToShow: [Date] = []
    @State private var loadedMonths: Set<Date> = []
    
    let userUUID: String
    
    init(userUUID: String) {
        self.userUUID = userUUID
        _viewModel = StateObject(wrappedValue: FriendsCalendarViewModel(container: DIContainer(router: AppRouter()), userUUID: userUUID))
    }
    
    var body: some View {
        LazyVStack(spacing: 30) {
            ForEach(monthsToShow, id: \.self) { monthDate in
                VStack {
                    headerView(for: monthDate)
                    calendarGridView(for: monthDate)
                }
                .onAppear {
                    //스크롤이 마지막에 도달하면 새로운 달 추가
                    if !loadedMonths.contains(monthDate) {
                        loadedMonths.insert(monthDate)
                        viewModel.fetchCalendar(userUuid: userUUID, year: year(from: monthDate), month: month(from: monthDate))
                        
                        if monthDate == monthsToShow.last {
                            addPreviousMonth()
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            setupInitialMonths()
        }
    }
    
    // MARK: - 초기 세팅
    private func setupInitialMonths() {
        let currentMonth = startOfMonth(for: Date())
        monthsToShow = [currentMonth]
    }
    
    private func addPreviousMonth() {
        guard let lastMonth = monthsToShow.last else { return }
        if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: lastMonth) {
            monthsToShow.append(newMonth)
        }
    }
    
    // MARK: - 헤더 뷰
    private func headerView(for month: Date) -> some View {
        VStack(spacing: 4) {
            Text(month, formatter: Self.dateFormatter)
                .font(Font.Pretend.pretendardMedium(size: 20))
                .padding(.bottom)
            
            HStack {
                ForEach(Array(Self.weekdaySymbols.enumerated()), id: \.offset) { index, symbol in
                    Text(symbol)
                        .frame(maxWidth: .infinity)
                        .font(Font.Pretend.pretendardMedium(size: 18))
                }
            }
            .padding(.bottom, 5)
        }
    }
    
    // MARK: - 날짜 그리드 뷰
    private func calendarGridView(for month: Date) -> some View {
        let daysInMonth: Int = numberOfDays(in: month)
        let firstWeekday: Int = firstWeekdayOfMonth(in: month) - 1
        
        return VStack {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                ForEach(0 ..< daysInMonth + firstWeekday, id: \.self) { index in
                    if index < firstWeekday {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(Color.clear)
                    } else {
                        let date = getDate(for: index - firstWeekday, in: month)
                        let day = index - firstWeekday + 1
                        let clicked = clickedDates.contains(date)
                        let myModel = viewModel.imageURL(for: date)
                        
                        CellView(day: day, clicked: clicked, cellDate: date, myModel: myModel)
                            .id(date)
                            .onTapGesture {
                                if clicked {
                                    clickedDates.remove(date)
                                } else {
                                    clickedDates.insert(date)
                                }
                            }
                    }
                }
            }
        }
    }
    
    private func year(from date: Date) -> Int {
        Calendar.current.component(.year, from: date)
    }
    
    private func month(from date: Date) -> Int {
        Calendar.current.component(.month, from: date)
    }
}

// MARK: - 날짜 한 칸의 셀 뷰
private struct CellView: View {
    var day: Int
    var clicked: Bool = false
    var cellDate: Date
    var myModel: String?
    
    var body: some View {
        ZStack {
            /// CalendarModel에 데이터가 있을 경우 표시될 뷰
            if let imageUrlString = myModel, let imageUrl = URL(string: imageUrlString) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40,height: 50)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure:
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 40,height: 50)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            /// Date( )는 현재 시간의 Date를 반환함.
            /// cellDate 와 Date( ) 이 같은 날이면 Circle 표시
            if cellDate.isSameDate(date: Date()) {
                Circle()
                    .frame(width: 32)
                    .foregroundStyle(Color.orange01.opacity(0.8))
            }
            
            RoundedRectangle(cornerRadius: 5)
                .opacity(0)
                .overlay(Text(String(day)))
                .foregroundStyle(
                    cellDate.isSameDate(date: Date()) ? Color.white :
                            cellDate.isAfterToday(date: Date()) ? Color.gray :
                            Color.black
                )
            
//            if clicked {
//                Text("Click")
//            }
        }
        .scaledToFit()
    }
}

// MARK: - 내부 메서드
private extension FriendsCalendarView {
    /// 특정 해당 날짜
    private func getDate(for day: Int, in month: Date) -> Date {
        return Calendar.current.date(byAdding: .day, value: day, to: startOfMonth(for: month))!
    }
    
    /// 해당 월의 시작 날짜
    func startOfMonth(for date: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        return Calendar.current.date(from: components)!
    }
    
    /// 해당 월에 존재하는 일자 수
    func numberOfDays(in date: Date) -> Int {
        return Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 0
    }
    
    /// 해당 월의 첫 날짜가 갖는 해당 주의 몇번째 요일
    func firstWeekdayOfMonth(in date: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = Calendar.current.date(from: components)!

        return Calendar.current.component(.weekday, from: firstDayOfMonth)
    }
    
    /// myModels 에서 otherDate 와 동일한 날인 데이터 하나 찾아서 반환. 없으면 nil 반환
//    func myModelByDate(otherDate: Date) -> String? {
////        return myModels.first { myModel in
////            startOfDay(date: myModel.date) == startOfDay(date: otherDate)
////        }
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let dateString = formatter.string(from: otherDate)
//
//        guard let datePost = viewModel.calendarData.first(where: { $0.date == dateString}),
//              let imageUrl = datePost.posts.first?.imageUrl.first else {
//            return nil
//        }
//        return imageUrl
//    }

    /// Date 를 해당 날짜의 자정으로 바꿔줌 (시 분 초기화)
    func startOfDay(date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

}

// MARK: - Static 프로퍼티
extension FriendsCalendarView {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    static let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols
}

//
//#Preview {
//    FriendsCalendarView()
//}
