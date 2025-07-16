//
//  HealthKitManager.swift
//  SOAPFT
//
//  Created by 바견규 on 7/16/25.
//

import Foundation
import HealthKit

final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    @Published var todaySteps: Int = 0
    @Published var todayDistance: Double = 0.0 // km
    @Published var todayCalories: Double = 0.0 // kcal

    private init() {}

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        let readTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }

    func fetchTodayHealthData() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        fetchQuantity(.stepCount, unit: .count(), predicate: predicate) { value in
            DispatchQueue.main.async {
                self.todaySteps = Int(value)
            }
        }

        fetchQuantity(.distanceWalkingRunning, unit: .meter(), predicate: predicate) { value in
            DispatchQueue.main.async {
                self.todayDistance = value / 1000.0 // m → km
            }
        }

        fetchQuantity(.activeEnergyBurned, unit: .kilocalorie(), predicate: predicate) { value in
            DispatchQueue.main.async {
                self.todayCalories = value
            }
        }
    }

    private func fetchQuantity(_ id: HKQuantityTypeIdentifier, unit: HKUnit, predicate: NSPredicate, completion: @escaping (Double) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: id) else {
            completion(0)
            return
        }

        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let sum = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
            completion(sum)
        }

        healthStore.execute(query)
    }
}
