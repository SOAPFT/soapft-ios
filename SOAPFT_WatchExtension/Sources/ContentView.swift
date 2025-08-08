//  ContentView.swift
//  SOAPFT Watch

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @StateObject private var challengeManager = WatchChallengeStateManager()
    @ObservedObject private var sessionManager = WatchSessionManager.shared
    @StateObject private var healthManager = HealthManager()
    @StateObject private var logger = DebugLogger.shared

    @State private var isRunning = false
    @State private var showStopAlert = false
    @State private var timer: Timer?
    @State private var elapsedSeconds: Int = 0
    @State private var currentTab = 0
    @State private var crownValue: Double = 0.0

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea(.all)

            VStack(spacing: 0) {
                pageIndicator
                    .padding(.top, 2)

                Group {
                    switch currentTab {
                    case 0: missionInfoPage
                    case 1: scorePage
                    case 2: rankComparePage
                    case 3: debugLogPage
                    default: missionInfoPage
                    }
                }
                .frame(maxWidth: .infinity)
                .animation(.easeInOut(duration: 0.3), value: currentTab)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            if value.translation.width > threshold && currentTab > 0 {
                                currentTab -= 1
                            } else if value.translation.width < -threshold && currentTab < 3 {
                                currentTab += 1
                            }
                        }
                )

                Spacer(minLength: 4)

                actionButton
                    .padding(.vertical)
            }

            if challengeManager.rankEffectTriggered {
                rankEffectOverlay
            }
        }
        .onAppear {
            logger.log("⌚️ ContentView onAppear")
            healthManager.requestAuthorization()

            logger.log("⌚️ WatchSessionManager 상태:")
            logger.log("- isSupported: \(WCSession.isSupported())")
            logger.log("- isReachable: \(WCSession.default.isReachable)")
            logger.log("- activationState: \(WCSession.default.activationState.rawValue)")

            WatchSessionManager.shared.activateSession()

            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                if isRunning {
                    logger.log("📊 HealthKit 데이터 상태:")
                    logger.log("- 걸음 수: \(healthManager.stepCount)")
                    logger.log("- 거리: \(healthManager.distance)m")
                    logger.log("- 칼로리: \(healthManager.calories)kcal")
                }
            }
        }
        .onChange(of: sessionManager.currentChallenge) { _, newSession in
            logger.log("⌚️ currentChallenge 변경됨")
            logger.log("새 세션: \(newSession != nil ? "있음" : "없음")")

            if let newSession {
                logger.log("⌚️ 세션 설정: duration=\(newSession.duration), type=\(newSession.missionType)")
                challengeManager.setSession(newSession)
                elapsedSeconds = 0
                logger.log("✅ challengeManager 세션 설정 완료")
            } else {
                logger.log("❌ 새 세션이 nil입니다")
            }
        }
        .alert("미션을 종료하시겠습니까?", isPresented: $showStopAlert) {
            Button("취소", role: .cancel) {}
            Button("종료", role: .destructive) {
                stopMeasurement()
            }
        } message: {
            Text("측정이 완료되며 결과가 iPhone으로 전송됩니다.")
        }
        .focusable()
        .digitalCrownRotation($crownValue, from: 0.0, through: 3.0, by: 1.0, sensitivity: .medium, isContinuous: false)
        .onChange(of: crownValue) { _, newValue in
            let newTab = Int(newValue.rounded())
            if newTab != currentTab && newTab >= 0 && newTab <= 3 {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentTab = newTab
                }
            }
        }
    }

    // MARK: - 측정 로직

    private func toggleMeasurement() {
        logger.log("⌚️ 측정 버튼 클릭 - 현재 상태: \(isRunning ? "실행중" : "정지중")")

        guard challengeManager.session != nil else {
            logger.log("❗️세션 없음. 측정 시작 불가")
            if let challenge = sessionManager.currentChallenge {
                logger.log("🔧 수동으로 세션 설정 시도...")
                challengeManager.setSession(challenge)
            }
            return
        }

        if isRunning {
            logger.log("⌚️ 측정 중지 알림 표시")
            showStopAlert = true
        } else {
            logger.log("⌚️ 측정 시작!")
            isRunning = true
            startMeasurement()
        }
    }

    private func startMeasurement() {
        logger.log("⌚️ startMeasurement 호출됨")
        healthManager.startWorkout()
        logger.log("⌚️ HealthKit 워크아웃 시작 요청 완료")

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedSeconds += 1
            if elapsedSeconds % 10 == 0 {
                logger.log("⌚️ 경과 시간: \(elapsedSeconds)초")
            }
            updateScoreFromSensors()
        }
        logger.log("✅ 타이머 시작됨")
    }

    private func stopMeasurement() {
        logger.log("⌚️ stopMeasurement 호출됨")
        healthManager.stopWorkout()
        timer?.invalidate()
        timer = nil
        isRunning = false
        logger.log("✅ 측정 중지 완료")
        sendResultToiPhone()
    }

    private func sendResultToiPhone() {
        logger.log("📱 iPhone으로 결과 전송 시도")
        
        guard let session = challengeManager.session else {
            logger.log("❌ session 없음")
            return
        }

        let resultData: Int
        switch session.missionType {
        case "steps":
            resultData = Int(healthManager.stepCount)
        case "distance":
            resultData = Int(healthManager.distance)
        case "calories":
            resultData = Int(healthManager.calories)
        default:
            logger.log("❌ 알 수 없는 missionType: \(session.missionType)")
            return
        }

        let payload: [String: Any] = [
            "action": "endChallenge",
            "eventId": session.eventId,
            "resultData": resultData
        ]

        logger.log("📦 UserInfo로 전송: \(payload)")
        
        // 인증 완료 상태로 먼저 변경
        challengeManager.markAsCompleted()
        
        // UserInfo 전송 (항상 성공)
        WCSession.default.transferUserInfo(payload)
        logger.log("✅ UserInfo 전송 완료")
        
        // UserInfo는 항상 성공하므로 3초 후 자동 리셋
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.logger.log("🔄 전송 성공 - 미션 대기 상태로 복귀")
            self.challengeManager.resetToInitialState()
        }
        
        // 대안: sendMessage도 시도해서 즉시 전송 성공하면 더 빠른 리셋
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(payload, replyHandler: { reply in
                self.logger.log("✅ 즉시 전송도 성공: \(reply)")
                // 즉시 전송 성공 시 더 빠른 리셋 (1초 후)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.logger.log("🚀 즉시 전송 성공 - 빠른 리셋")
                    self.challengeManager.resetToInitialState()
                }
            }) { error in
                self.logger.log("⚠️ 즉시 전송 실패, UserInfo로 전송됨: \(error.localizedDescription)")
            }
        }
    }

    private func updateScoreFromSensors() {
        guard let missionType = challengeManager.session?.missionType else {
            if elapsedSeconds % 30 == 0 {
                logger.log("❌ missionType이 없음")
            }
            return
        }

        let oldScore = challengeManager.currentScore

        switch missionType {
        case "steps":
            challengeManager.updateScore(to: Int(healthManager.stepCount))
            if oldScore != challengeManager.currentScore {
                logger.log("👟 걸음 수 업데이트: \(healthManager.stepCount) → 점수: \(challengeManager.currentScore)")
            }
        case "distance":
            challengeManager.updateScore(to: Int(healthManager.distance))
            if oldScore != challengeManager.currentScore {
                logger.log("📏 거리 업데이트: \(healthManager.distance)m → 점수: \(challengeManager.currentScore)")
            }
        case "calories":
            challengeManager.updateScore(to: Int(healthManager.calories))
            if oldScore != challengeManager.currentScore {
                logger.log("🔥 칼로리 업데이트: \(healthManager.calories)kcal → 점수: \(challengeManager.currentScore)")
            }
        default:
            logger.log("❌ 알 수 없는 미션 타입: \(missionType)")
        }
    }

    // MARK: - 디버그 로그 페이지

    private var debugLogPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(logger.logs.reversed(), id: \.self) { line in
                    Text(line)
                        .font(.caption2.monospaced())
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .background(Color.black.opacity(0.9))
    }

    // MARK: - Custom Button Style

    struct ScaleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        Group {
            switch currentTab {
            case 0:
                LinearGradient(colors: [.blue.opacity(0.8), .indigo.opacity(0.9), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
            case 1:
                LinearGradient(colors: [.orange.opacity(0.7), .red.opacity(0.8), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
            default:
                LinearGradient(colors: [.purple.opacity(0.7), .pink.opacity(0.6), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(currentTab == index ? Color.white : Color.white.opacity(0.3))
                    .frame(width: currentTab == index ? 6 : 4, height: currentTab == index ? 6 : 4)
                    .animation(.spring(response: 0.3), value: currentTab)
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Mission Info Page

    private var missionInfoPage: some View {
        VStack(spacing: 8) {
            headerLabel(icon: "target", label: "MISSION")

            if challengeManager.isCompleted {
                // 인증 완료 상태 UI
                VStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    
                    Text("인증 완료!")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                    
                    Text("결과 전송 중...")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    // 로딩 인디케이터
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                        .padding(.top, 4)
                }
            } else if let session = challengeManager.session {
                // 기존 미션 진행 UI
                VStack(spacing: 6) {
                    Text(session.missionType.uppercased())
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)

                    ZStack {
                        Circle().stroke(.white.opacity(0.2), lineWidth: 6).frame(width: 80, height: 80)
                        Circle()
                            .trim(from: 0, to: progressValue)
                            .stroke(.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1), value: progressValue)

                        VStack(spacing: 1) {
                            Text(formattedRemainingTime)
                                .font(.callout.monospacedDigit().weight(.bold))
                                .foregroundColor(.white)
                            Text("남은시간")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
            } else {
                // 미션 대기 상태 UI
                VStack(spacing: 6) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.6))
                    Text("미션 대기 중")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Score Page

    private var scorePage: some View {
        VStack(spacing: 10) {
            headerLabel(icon: "bolt.fill", label: "SCORE")

            VStack(spacing: 2) {
                Text("\(challengeManager.currentScore)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.yellow)
                    .contentTransition(.numericText())
                    .animation(.bouncy(duration: 0.5), value: challengeManager.currentScore)

                Text("현재 점수")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }

            HStack {
                Image(systemName: rankIcon).font(.callout).foregroundColor(rankColor)

                VStack(alignment: .leading, spacing: 1) {
                    Text("현재 순위").font(.caption2).foregroundColor(.white.opacity(0.7))
                    Text("\(challengeManager.currentRank)위").font(.callout.weight(.bold)).foregroundColor(.white)
                }

                Spacer()
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(rankColor.opacity(0.5), lineWidth: 0.5))
            )
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Rank Compare Page

    private var rankComparePage: some View {
        VStack(spacing: 8) {
            headerLabel(icon: "person.2.fill", label: "RANKING")

            VStack(spacing: 6) {
                if let upperUser = getNextHigherRankUser() {
                    rankCard(title: "다음 순위", name: upperUser.name, score: String(upperUser.score), rank: upperUser.rank, isMe: false)
                } else {
                    rankCard(title: "1위입니다!", name: "축하합니다", score: "최고점", rank: 1, isMe: false)
                }

                rankCard(title: "내 순위", name: "나", score: "\(challengeManager.currentScore)", rank: challengeManager.currentRank, isMe: true)
            }
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Components

    private func headerLabel(icon: String, label: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.caption)
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(.ultraThinMaterial))
    }

    private func rankCard(title: String, name: String, score: String, rank: Int?, isMe: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Image(systemName: isMe ? "person.fill" : "arrow.up")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                    Text(title)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                HStack(spacing: 4) {
                    Text(name)
                        .font(.caption.weight(.medium))
                        .foregroundColor(isMe ? .yellow : .white)
                    if let rank = rank {
                        Text("#\(rank)").font(.caption2).foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            Spacer()
            Text(score)
                .font(.caption.weight(.bold))
                .foregroundColor(isMe ? .yellow : .white.opacity(0.9))
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isMe ? .yellow.opacity(0.1) : .white.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(isMe ? .yellow.opacity(0.3) : .white.opacity(0.2), lineWidth: 0.5))
        )
    }

    private var actionButton: some View {
        Button(action: toggleMeasurement) {
            HStack(spacing: 6) {
                Image(systemName: isRunning ? "pause.fill" : "play.fill").font(.caption.weight(.bold))
                Text(isRunning ? "측정 중지" : "측정 시작").font(.caption.weight(.semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(LinearGradient(
                        colors: isRunning ? [.red.opacity(0.8), .red] : [.green.opacity(0.8), .green],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(challengeManager.isCompleted) // 완료 상태일 때 버튼 비활성화
        .opacity(challengeManager.isCompleted ? 0.5 : 1.0) // 비활성화 시 투명도 조절
    }

    private var rankEffectOverlay: some View {
        RankEffectView(newRank: challengeManager.currentRank)
            .transition(.scale.combined(with: .opacity))
            .zIndex(100)
    }

    // MARK: - Computed Properties

    private var progressValue: Double {
        guard let session = challengeManager.session else { return 0 }
        let remaining = max(session.duration - elapsedSeconds, 0)
        return Double(remaining) / Double(session.duration)
    }

    private var formattedRemainingTime: String {
        guard let session = challengeManager.session else { return "--:--" }
        let remaining = max(session.duration - elapsedSeconds, 0)
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var rankIcon: String {
        switch challengeManager.currentRank {
        case 1: return "crown.fill"
        case 2, 3: return "medal.fill"
        default: return "trophy.fill"
        }
    }

    private var rankColor: Color {
        switch challengeManager.currentRank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }

    private func getNextHigherRankUser() -> RankUserDTO? {
        guard let session = challengeManager.session else { return nil }
        let allUsers = (session.top3 + session.others)
            .map { RankUserDTO(name: $0.name, rank: $0.rank, score: $0.score) }

        let currentScore = challengeManager.currentScore

        let myUser = RankUserDTO(name: "나", rank: -1, score: currentScore)

        let allIncludingMe = (allUsers + [myUser])
            .sorted { $0.score > $1.score }

        guard let myIndex = allIncludingMe.firstIndex(where: { $0.name == "나" }) else { return nil }

        return myIndex > 0 ? allIncludingMe[myIndex - 1] : nil
    }
}

// MARK: - Custom Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
