//
//  ChallengeStatisticsCalendar.swift
//  SOAPFT
//
//  Created by 바견규 on 7/3/25.
//

import SwiftUI

// PreferenceKey로 셀 위치 추적
struct CellPositionPreferenceKey: PreferenceKey {
    static var defaultValue: [Date: Anchor<CGPoint>] = [:]
    static func reduce(value: inout [Date: Anchor<CGPoint>], nextValue: () -> [Date: Anchor<CGPoint>]) {
        value.merge(nextValue()) { $1 }
    }
}

struct CalenderView: View {
    @State var currentMonth: Date
    @State var startMonth: Date
    @State var endMonth: Date
    @State private var selectedDate: Date? = nil

    let certifiedCount: [Date: Int]
    let certifiedMembers: [Date: [Member]]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("멤버의 ") + Text("인증 현황").bold() + Text("을\n확인해 보세요!")
            headerView
            ZStack {
                calendarGridView
                    .overlayPreferenceValue(CellPositionPreferenceKey.self) { preferences in
                        GeometryReader { geo in
                            if let date = selectedDate,
                               let anchorEntry = preferences.first(where: { Calendar.current.isDate($0.key, equalTo: date, toGranularity: .day) }),
                               let membersEntry = certifiedMembers.first(where: { Calendar.current.isDate($0.key, equalTo: date, toGranularity: .day) }) {

                                let anchor = anchorEntry.value
                                let members = membersEntry.value
                                let center = geo[anchor]
                                let popupWidth: CGFloat = 220
                                let popupHeight: CGFloat = CGFloat(50 + members.count * 40)

                                let safeX = min(max(center.x, popupWidth / 2 + 8), geo.size.width - popupWidth / 2 - 8)
                                let safeY = min(max(center.y - 60, popupHeight / 2 + 8), geo.size.height - popupHeight / 2 - 8)

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("선택된 날짜: \(date.formatted(date: .numeric, time: .omitted))")
                                            .font(.caption)
                                        Spacer()
                                        Button(action: {
                                            selectedDate = nil
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.gray)
                                        }
                                    }

                                    ForEach(members) { member in
                                        HStack(spacing: 8) {
                                            AsyncImage(url: URL(string: member.profileImage)) { image in
                                                image.resizable()
                                            } placeholder: {
                                                Color.gray
                                            }
                                            .frame(width: 30, height: 30)
                                            .clipShape(Circle())

                                            Text(member.name)
                                                .font(.caption)
                                        }
                                    }
                                }
                                .frame(width: popupWidth)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.2), radius: 4)
                                )
                                .position(x: safeX, y: safeY)
                            }
                        }
                    }
            }

            legendView
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3))
        )
        .padding()
    }

    private var headerView: some View {
        VStack(spacing: 4) {
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(currentMonth == startMonth ? Color.gray : Color.orange)
                }.disabled(currentMonth <= startMonth)

                Spacer()

                Text(currentMonth, formatter: Self.dateFormatter)
                    .font(.title3)
                    .bold()

                Spacer()

                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(currentMonth == endMonth ? Color.gray : Color.orange)
                }.disabled(currentMonth >= endMonth)
            }

            HStack {
                ForEach(Self.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var calendarGridView: some View {
        let daysInMonth = numberOfDays(in: currentMonth)
        let firstWeekday = firstWeekdayOfMonth(in: currentMonth) - 1

        return LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
            ForEach(0..<daysInMonth + firstWeekday, id: \.self) { index in
                Group {
                    if index < firstWeekday {
                        Color.clear.frame(height: 40)
                    } else {
                        let rawDate = getDate(for: index - firstWeekday)
                        let count = certifiedCount.first(where: { Calendar.current.isDate($0.key, equalTo: rawDate, toGranularity: .day) })?.value ?? 0

                        CellView(day: index - firstWeekday + 1, certified: count)
                            .anchorPreference(key: CellPositionPreferenceKey.self, value: .center) {
                                [rawDate: $0]
                            }
                            .onTapGesture {
                                if count > 0 {
                                    selectedDate = rawDate
                                } else {
                                    selectedDate = nil
                                }
                            }
                    }
                }
            }
        }
    }

    private var legendView: some View {
        HStack(spacing: 4) {
            Circle().fill(Color.orange01).frame(width: 6, height: 6)
            Text("인증 완료").font(.caption2).foregroundStyle(.gray)
        }.padding(.top, 8)
    }

    func getDate(for day: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: day, to: startOfMonth())!
    }

    func startOfMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: currentMonth)
        return Calendar.current.date(from: components)!
    }

    func numberOfDays(in date: Date) -> Int {
        Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 0
    }

    func firstWeekdayOfMonth(in date: Date) -> Int {
        let firstDay = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date))!
        return Calendar.current.component(.weekday, from: firstDay)
    }

    func changeMonth(by value: Int) {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) else { return }
        if newMonth < startMonth || newMonth > endMonth { return }
        withAnimation { self.currentMonth = newMonth }
    }

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter
    }()

    static let weekdaySymbols = Calendar.current.shortStandaloneWeekdaySymbols
}


private struct CellView: View {
    let day: Int
    let certified: Int

    var body: some View {
        ZStack {
            if certified > 0 {
                Circle()
                    .fill(Color.orange01.opacity(0.1))
                    .frame(width: 30, height: 30)
            }

            Text("\(day)")
                .font(.caption)
                .foregroundStyle(.black)

            if certified > 0 {
                Text("\(certified)명")
                    .font(.caption2)
                    .foregroundStyle(Color.orange01)
                    .offset(y: 23)
            }
        }
        .frame(height: 40)
    }
}


#Preview {
    let sampleMembers: [Date: [Member]] = [
        Calendar.current.date(byAdding: .day, value: -1, to: Date())!: [
            Member(id: "1", name: "윤재명", profileImage: "https://via.placeholder.com/30"),
            Member(id: "2", name: "한나", profileImage: "https://via.placeholder.com/30")
        ],
        Calendar.current.date(byAdding: .day, value: -2, to: Date())!: [
            Member(id: "3", name: "태현", profileImage: "https://via.placeholder.com/30")
        ]
    ]

    let sampleCounts: [Date: Int] = sampleMembers.mapValues { $0.count }

    return CalenderView(
        currentMonth: Date(),
        startMonth: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
        endMonth: Calendar.current.date(byAdding: .month, value: 3, to: Date())!,
        certifiedCount: sampleCounts,
        certifiedMembers: sampleMembers
    )
}

