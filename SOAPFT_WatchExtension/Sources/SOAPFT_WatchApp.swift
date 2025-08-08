
import SwiftUI

@main
struct SOAPFT_WatchApp: App {
    @StateObject private var sessionManager = WatchSessionManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager) // 환경 객체로 뷰에 주입
        }
    }
}
