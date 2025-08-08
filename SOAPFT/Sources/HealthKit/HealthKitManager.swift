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
    
    // 기간별 데이터를 위한 새로운 프로퍼티들
    @Published var periodSteps: Int = 0
    @Published var periodDistance: Double = 0.0 // km
    @Published var periodCalories: Double = 0.0 // kcal

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

    // 오늘 데이터 fetch 함수
    func fetchTodayHealthData() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        fetchQuantityFromAppleWatch(.stepCount, unit: .count(), predicate: predicate) { value in
            DispatchQueue.main.async {
                self.todaySteps = Int(value)
            }
        }

        fetchQuantityFromAppleWatch(.distanceWalkingRunning, unit: .meter(), predicate: predicate) { value in
            DispatchQueue.main.async {
                self.todayDistance = value / 1000.0 // m → km
            }
        }

        fetchQuantityFromAppleWatch(.activeEnergyBurned, unit: .kilocalorie(), predicate: predicate) { value in
            DispatchQueue.main.async {
                self.todayCalories = value
            }
        }
    }
    
    // 기간별 데이터 fetch 함수 (초 단위)
    func fetchHealthData(forLastSeconds seconds: TimeInterval) {
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-seconds)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        fetchQuantityFromAppleWatch(.stepCount, unit: .count(), predicate: predicate) { value in
            DispatchQueue.main.async {
                self.periodSteps = Int(value)
            }
        }

        fetchQuantityFromAppleWatch(.distanceWalkingRunning, unit: .meter(), predicate: predicate) { value in
            DispatchQueue.main.async {
                self.periodDistance = value / 1000.0 // m → km
            }
        }

        fetchQuantityFromAppleWatch(.activeEnergyBurned, unit: .kilocalorie(), predicate: predicate) { value in
            DispatchQueue.main.async {
                self.periodCalories = value
            }
        }
    }
    
    // MARK: - 실제 인증용
    func fetchHealthData(
            missionType: MissionType,
            durationSeconds: Int,
            completion: @escaping (Int) -> Void
        ) {
            let endDate = Date()
            let startDate = endDate.addingTimeInterval(-TimeInterval(durationSeconds))
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

            let (identifier, unit): (HKQuantityTypeIdentifier, HKUnit) = {
                switch missionType {
                case .steps: return (.stepCount, .count())
                case .distance: return (.distanceWalkingRunning, .meter())
                case .calories: return (.activeEnergyBurned, .kilocalorie())
                }
            }()

            fetchQuantityFromAppleWatch(identifier, unit: unit, predicate: predicate) { value in
                let resultValue: Int
                switch missionType {
                case .steps:
                    resultValue = Int(value)
                case .distance:
                    resultValue = Int(value) // 단위: m
                case .calories:
                    resultValue = Int(value) // 단위: kcal
                }

                DispatchQueue.main.async {
                    completion(resultValue)
                }
            }
        }
    
    // 더 유연한 기간별 데이터 fetch 함수 (시작일과 종료일 직접 지정)
    func fetchHealthData(from startDate: Date, to endDate: Date) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        fetchQuantityFromAppleWatch(.stepCount, unit: .count(), predicate: predicate) { value in
            DispatchQueue.main.async {
                self.periodSteps = Int(value)
            }
        }

        fetchQuantityFromAppleWatch(.distanceWalkingRunning, unit: .meter(), predicate: predicate) { value in
            DispatchQueue.main.async {
                self.periodDistance = value / 1000.0 // m → km
            }
        }

        fetchQuantityFromAppleWatch(.activeEnergyBurned, unit: .kilocalorie(), predicate: predicate) { value in
            DispatchQueue.main.async {
                self.periodCalories = value
            }
        }
    }
    
    // 편의 함수들
    func fetchHealthDataForLastMinutes(_ minutes: Int) {
        fetchHealthData(forLastSeconds: TimeInterval(minutes * 60))
    }
    
    func fetchHealthDataForLastHours(_ hours: Int) {
        fetchHealthData(forLastSeconds: TimeInterval(hours * 3600))
    }
    
    func fetchHealthDataForLastDays(_ days: Int) {
        fetchHealthData(forLastSeconds: TimeInterval(days * 24 * 3600))
    }

    /// 애플워치 데이터만 필터링하여 합산
    private func fetchQuantityFromAppleWatch(
        _ id: HKQuantityTypeIdentifier,
        unit: HKUnit,
        predicate: NSPredicate,
        completion: @escaping (Double) -> Void
    ) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: id) else {
            completion(0)
            return
        }

        let query = HKSampleQuery(
            sampleType: quantityType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, _ in
            guard let quantitySamples = samples as? [HKQuantitySample] else {
                completion(0)
                return
            }

            // 소스 이름이 "watch"를 포함하는 경우만 합산
            let watchSamples = quantitySamples.filter { sample in
                let sourceName = sample.sourceRevision.source.name.lowercased()
                return sourceName.contains("watch")
            }

            let total = watchSamples.reduce(0.0) { sum, sample in
                sum + sample.quantity.doubleValue(for: unit)
            }

            completion(total)
        }

        healthStore.execute(query)
    }
}
