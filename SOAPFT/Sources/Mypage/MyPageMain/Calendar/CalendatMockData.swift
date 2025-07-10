//
//  CalendatMockData.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/4/25.
//

import SwiftUI
import SwiftData

@MainActor
let sampleDate: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: CalendarModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = container.mainContext
        if try modelContext.fetch(FetchDescriptor<CalendarModel>()).isEmpty {
            mockData.forEach { container.mainContext.insert($0) }
        }
        return container
    } catch {
        fatalError("컨테이너 생성 실패")
    }
}()

let mockData = [
    CalendarModel(date: Date().addingTimeInterval(-01233), imageURL: "https://velog.velcdn.com/images/mazorika/post/bb01b28d-8759-4846-8550-a7cbccc1a600/image.jpeg"),
    CalendarModel(date: Date().addingTimeInterval(-252200), imageURL: "https://velog.velcdn.com/images/mazorika/post/1b6e082b-35b5-45c5-ab0b-125b62bf84ec/image.jpeg"),
    CalendarModel(date: Date().addingTimeInterval(-482000), imageURL: "https://velog.velcdn.com/images/mazorika/post/bb01b28d-8759-4846-8550-a7cbccc1a600/image.jpeg"),
    CalendarModel(date: Date().addingTimeInterval(-615800), imageURL: "https://velog.velcdn.com/images/mazorika/post/bb01b28d-8759-4846-8550-a7cbccc1a600/image.jpeg"),
    CalendarModel(date: Date().addingTimeInterval(-834000), imageURL: "https://velog.velcdn.com/images/mazorika/post/1b6e082b-35b5-45c5-ab0b-125b62bf84ec/image.jpeg"),
    CalendarModel(date: Date().addingTimeInterval(-1396000), imageURL: "https://velog.velcdn.com/images/mazorika/post/028ca7aa-20e7-434b-8b9c-857a0d35c3d9/image.jpeg"),
    CalendarModel(date: Date().addingTimeInterval(-1792730), imageURL: "https://velog.velcdn.com/images/mazorika/post/bb01b28d-8759-4846-8550-a7cbccc1a600/image.jpeg")
]
