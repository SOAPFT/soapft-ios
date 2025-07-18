//
//  AppDelegate.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/6/25.
//

import UIKit
import UserNotifications
import NidThirdPartyLogin

/// 푸시 알림 및 네이버 로그인 처리를 담당하는 AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
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
        
        return true
    }

    /// 네이버 로그인 URL 처리
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return NidOAuth.shared.handleURL(url)
    }

    /// 디바이스 토큰 등록 성공
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("Device Token: \(token)")

        // UserDefaults에 저장 (전송은 따로)
        UserDefaults.standard.set(token, forKey: "device_token")
    }

    /// 디바이스 토큰 등록 실패
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("푸시 등록 실패: \(error.localizedDescription)")
    }

    /// 앱이 포그라운드 상태일 때 알림 수신 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
