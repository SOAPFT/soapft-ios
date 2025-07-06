//
//  AppDelegate.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/6/25.
//

import SwiftUI
import UIKit
import NidThirdPartyLogin

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NidOAuth.shared.initialize()
        NidOAuth.shared.setLoginBehavior(.appPreferredWithInAppBrowserFallback) // 네이버 앱이 설치된 경우 네이버 앱으로 인증, 네이버 앱이 설치되어있지 않은 경우 SafariViewController를 실행해 인증하는 방식
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if NidOAuth.shared.handleURL(url) {
            return true
        }
        return false
    }
}
