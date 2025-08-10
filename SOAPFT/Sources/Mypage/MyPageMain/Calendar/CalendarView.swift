//
//  CalendarView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/4/25.
//

import SwiftUI
import SwiftData
import Kingfisher

struct CalendarView: View {
    @Environment(\.diContainer) private var container
    
    @StateObject private var viewModel: CalendarViewModel
    @State private var clickedDates: Set<Date> = []
    @State private var monthsToShow: [Date] = []
    @State private var loadedMonths: Set<Date> = []
    
    init() {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(container: DIContainer(router: AppRouter())))
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
                        viewModel.fetchCalendar(year: year(from: monthDate), month: month(from: monthDate))
                        
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
            /// CalendarModel에 데이터가 있을 경우 표시될 뷰 - Kingfisher 적용
            if let imageUrlString = myModel, let imageUrl = URL(string: imageUrlString) {
                KFImage(imageUrl)
                    .placeholder {
                        // 로딩 중 플레이스홀더
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 40, height: 50)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                    .scaleEffect(0.6)
                            )
                    }
                    .onFailure { error in
                        print("캘린더 이미지 로드 실패: \(error)")
                    }
                    .fade(duration: 0.2)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 50)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 0.5)
                    )
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
                .overlay(
                    Text(String(day))
                        .font(Font.Pretend.pretendardMedium(size: 16))
                )
                .foregroundStyle(
                    cellDate.isSameDate(date: Date()) ? Color.white :
                            cellDate.isAfterToday(date: Date()) ? Color.gray :
                            Color.black
                )
        }
        .scaledToFit()
    }
}

// MARK: - 내부 메서드
private extension CalendarView {
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
    
    /// Date 를 해당 날짜의 자정으로 바꿔줌 (시 분 초기화)
    func startOfDay(date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
}

// MARK: - Static 프로퍼티
extension CalendarView {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    static let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols
}

// MARK: - 날짜 비교를 위한 함수 추가
extension Date {
    private func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func isSameDate(date: Date) -> Bool {
        self.startOfDay() == date.startOfDay()
    }
    
    func isAfterToday(date: Date) -> Bool {
        self.startOfDay() > date.startOfDay()
    }
}

#Preview {
    CalendarView()
}
