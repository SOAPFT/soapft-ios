//
//  WatchSessionManager.swift
//  SOAPFT
//
//  Created by 바견규 on 8/7/25.
//

import Foundation
import WatchConnectivity

final class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()

    // 워치에서 사용하는 현재 챌린지 데이터 (DTO)
    @Published var currentChallenge: ChallengeSession?

    private override init() {
        super.init()
        activateSession()
    }

    func activateSession() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    // MARK: - 필수 Delegate 구현

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("⌚️ Watch session activated: \(activationState.rawValue)")
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        print("⌚️ Session reachability changed: \(session.isReachable)")
    }

    // MARK: - 메시지 수신 처리

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("⌚️ 메시지 수신: \(message)")
        
        guard message["action"] as? String == "startChallenge" else {
            print("❌ action이 startChallenge가 아님")
            return
        }
        
        // 개별 필드 추출
        guard let eventId = message["eventId"] as? Int,
              let durationSeconds = message["durationSeconds"] as? Int,
              let missionTypeRaw = message["missionType"] as? String,
              let top3Data = message["top3"] as? [[String: Any]],
              let othersData = message["others"] as? [[String: Any]] else {
            print("❌ 필수 필드 누락: \(message)")
            return
        }
        
        // RankUserDTO 변환 (score 포함)
        let top3Users = top3Data.compactMap { dict -> RankUserDTO? in
            guard let name = dict["name"] as? String,
                  let rank = dict["rank"] as? Int,
                  let score = dict["score"] as? Int else {
                print("❌ top3 데이터 변환 실패: \(dict)")
                return nil
            }
            return RankUserDTO(name: name, rank: rank, score: score)
        }
        
        let othersUsers = othersData.compactMap { dict -> RankUserDTO? in
            guard let name = dict["name"] as? String,
                  let rank = dict["rank"] as? Int,
                  let score = dict["score"] as? Int else {
                print("❌ others 데이터 변환 실패: \(dict)")
                return nil
            }
            return RankUserDTO(name: name, rank: rank, score: score)
        }
        
        // ChallengeSession 생성
        let challenge = ChallengeSession(
            eventId: eventId,
            duration: durationSeconds,
            missionType: missionTypeRaw,
            top3: top3Users,
            others: othersUsers
        )
        
        DispatchQueue.main.async {
            self.currentChallenge = challenge
            print("✅ 챌린지 세션 생성 완료: duration=\(challenge.duration), type=\(challenge.missionType)")
            print("✅ Top3: \(challenge.top3)")
        }
    }
}
