//
//  HealthKitManager.swift
//  SOAPFT
//
//  Created by 바견규 on 8/7/25.
//

import Foundation
import HealthKit

final class HealthManager: NSObject, ObservableObject, HKLiveWorkoutBuilderDelegate {
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    private let logger = DebugLogger.shared

    @Published var stepCount: Double = 0       // 걸음 수
    @Published var distance: Double = 0        // m
    @Published var calories: Double = 0        // kcal

    // MARK: - 권한 요청

    
    func requestAuthorization() {
        let readTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        let writeTypes: Set = [
            HKObjectType.workoutType()
        ]
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            self.logger.log("✅ 권한 요청: \(success), 오류: \(error?.localizedDescription ?? "없음")")
        }
    }


    // MARK: - 워크아웃 시작
    func startWorkout() {
        logger.log("🏃‍♂️ 워크아웃 시작 시도")
        
        let config = HKWorkoutConfiguration()
        config.activityType = .walking       // 걷기로 설정
        config.locationType = .indoor        // 실내로 설정 (GPS 불필요)
        
        logger.log("📋 워크아웃 설정: 걷기, 실내")

        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            workoutSession?.delegate = self
            logger.log("✅ 워크아웃 세션 생성 성공")
            
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
            workoutBuilder?.delegate = self
            logger.log("✅ 워크아웃 빌더 생성 성공")

            // 데이터 소스 설정
            let dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)
            
            // 수집할 데이터 타입 명시적으로 활성화
            let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
            let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
            
            let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: .strictStartDate)
            
            dataSource.enableCollection(for: stepType, predicate: predicate)
            dataSource.enableCollection(for: distanceType, predicate: predicate)
            dataSource.enableCollection(for: energyType, predicate: predicate)
            
            workoutBuilder?.dataSource = dataSource
            logger.log("✅ 데이터 소스 설정 완료")

            let startDate = Date()
            workoutSession?.startActivity(with: startDate)
            logger.log("🚀 워크아웃 활동 시작")
            
            workoutBuilder?.beginCollection(withStart: startDate) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.logger.log("✅ 데이터 수집 시작 성공")
                    } else {
                        self.logger.log("❌ 데이터 수집 시작 실패: \(error?.localizedDescription ?? "unknown")")
                    }
                }
            }
        } catch {
            logger.log("❌ 워크아웃 시작 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - 워크아웃 종료
    func stopWorkout() {
        logger.log("🛑 워크아웃 종료 시작")
        
        workoutSession?.end()
        workoutBuilder?.endCollection(withEnd: Date()) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.logger.log("✅ 데이터 수집 종료 성공")
                } else {
                    self.logger.log("❌ 데이터 수집 종료 실패: \(error?.localizedDescription ?? "unknown")")
                }
            }
        }
        workoutBuilder?.finishWorkout { workout, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.logger.log("❌ 워크아웃 종료 실패: \(error.localizedDescription)")
                } else {
                    self.logger.log("✅ 워크아웃 종료 완료")
                }
            }
        }
    }

    // MARK: - 실시간 데이터 수집 콜백
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        logger.log("📊 데이터 수집됨: \(collectedTypes.count)개 타입")
        
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            let stats = workoutBuilder.statistics(for: quantityType)

            DispatchQueue.main.async {
                switch quantityType.identifier {
                case HKQuantityTypeIdentifier.stepCount.rawValue:
                    let newSteps = stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    if newSteps != self.stepCount {
                        self.stepCount = newSteps
                        self.logger.log("👟 걸음 수 업데이트: \(Int(newSteps))")
                    }

                case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue:
                    let newDistance = stats?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
                    if newDistance != self.distance {
                        self.distance = newDistance
                        self.logger.log("📏 거리 업데이트: \(Int(newDistance))m")
                    }

                case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
                    let newCalories = stats?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                    if newCalories != self.calories {
                        self.calories = newCalories
                        self.logger.log("🔥 칼로리 업데이트: \(Int(newCalories))kcal")
                    }

                default:
                    break
                }
            }
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        logger.log("📝 워크아웃 이벤트 수집됨")
    }
}

// MARK: - HKWorkoutSessionDelegate
extension HealthManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            let fromStateName = self.stateToString(fromState)
            let toStateName = self.stateToString(toState)
            self.logger.log("🔄 워크아웃 상태 변경: \(fromStateName) → \(toStateName)")
            
            if toState == .running {
                self.logger.log("🏃‍♂️ 워크아웃 실행 중 - 데이터 수집 시작")
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.logger.log("💥 워크아웃 세션 실패: \(error.localizedDescription)")
        }
    }
    
    private func stateToString(_ state: HKWorkoutSessionState) -> String {
        switch state {
        case .notStarted: return "시작 안됨"
        case .running: return "실행 중"
        case .ended: return "종료됨"
        case .paused: return "일시정지"
        case .prepared: return "준비됨"
        @unknown default: return "알 수 없음"
        }
    }
}

extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}
