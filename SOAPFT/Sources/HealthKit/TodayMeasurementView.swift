//
//  TodayMeasurementView.swift
//  SOAPFT
//
//  Created by 바견규 on 7/16/25.
//

import SwiftUI

struct TodayMeasurementView: View {
    @StateObject private var manager = HealthKitManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Text("📊 오늘의 측정")
                .font(.title2)
                .bold()

            HStack {
                Text("👣 걸음 수:")
                Spacer()
                Text("\(manager.todaySteps) 보")
            }

            HStack {
                Text("🏃 운동 거리:")
                Spacer()
                Text(String(format: "%.2f km", manager.todayDistance))
            }

            HStack {
                Text("🔥 칼로리:")
                Spacer()
                Text(String(format: "%.0f kcal", manager.todayCalories))
            }
        }
        .padding()
        .onAppear {
            manager.requestAuthorization { success in
                if success {
                    manager.fetchTodayHealthData()
                } else {
                    print("HealthKit 권한 거부됨")
                }
            }
        }
    }
}
