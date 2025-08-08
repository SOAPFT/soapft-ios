//
//  appleWatchData.swift
//  SOAPFT
//
//  Created by 바견규 on 8/7/25.
//

import SwiftUI
import WatchConnectivity

extension ChallengeRankingViewModel {
    func rankUserToDict(_ user: RankUser) -> [String: Any] {
        return [
            "name": user.name,
            "rank": user.rank,
            "score": user.score  // score 추가!
        ]
    }

    func sendMissionToWatch() {
        guard WCSession.default.isReachable else {
            print("⌚️ 워치 연결 안 됨")
            return
        }

        let payload: [String: Any] = [
            "action": "startChallenge",
            "durationSeconds": durationSeconds,
            "missionType": missionType.rawValue,
            "top3": top3.map { rankUserToDict($0) },
            "others": others.map { rankUserToDict($0) },
            "eventId" : missionId
        ]

        print("📱 → ⌚️ 전송 데이터: \(payload)")

        WCSession.default.sendMessage(payload, replyHandler: nil) { error in
            print("❌ 워치 전송 실패: \(error.localizedDescription)")
        }
    }
}
