//
//  AppDelegate.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/6/25.
//

import UIKit
import UserNotifications
import NidThirdPartyLogin
import WatchConnectivity

/// 푸시 알림 및 네이버 로그인 처리를 담당하는 AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, WCSessionDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 네이버 로그인 초기화
        NidOAuth.shared.initialize()
        NidOAuth.shared.setLoginBehavior(.appPreferredWithInAppBrowserFallback)
        
        // 알림 권한 요청
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("알림 권한 거부됨")
            }
        }
        
        // 워치 연결 세션 초기화
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        return true
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("📲 iPhone WCSession 활성화 완료. 상태: \(activationState)")
    }
    
    // 📥 워치에서 메시지 수신
    // AppDelegate.swift에 추가 (없다면)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("📦 UserInfo 수신: \(userInfo)")
        
        if let action = userInfo["action"] as? String, action == "endChallenge",
           let eventId = userInfo["eventId"] as? Int,
           let result = userInfo["resultData"] as? Int {
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .watchChallengeCompleted,
                    object: nil,
                    userInfo: [
                        "eventId": eventId,
                        "resultData": result
                    ]
                )
            }
            print("✅ NotificationCenter로 전송 완료")
        }
    }
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}

    
    // MARK: - 네이버 로그인 처리
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return NidOAuth.shared.handleURL(url)
    }

    // MARK: - 푸시 토큰 처리

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("Device Token: \(token)")
        UserDefaults.standard.set(token, forKey: "device_token")
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("푸시 등록 실패: \(error.localizedDescription)")
    }

    // MARK: - 푸시 알림 처리

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}


// MARK: - 알림 센터 (앱 내부에 알림)
extension Notification.Name {
    static let watchChallengeCompleted = Notification.Name("watchChallengeCompleted")
}
