//
//  SwiftUIView.swift
//  SOAPFT
//
//  Created by 바견규 on 7/2/25.
//

import SwiftUI

extension RankUser {
    init(entry: RankingEntry) {
        self.init(
            rank: entry.displayRank,
            name: entry.name,
            image: entry.profileImage ?? "",
            score: entry.result
        )
    }
}

struct ChallengeRankingWrapper: View {
    @Environment(\.diContainer) private var container
    let missionId: Int

    var body: some View {
        ChallengeRankingView(
            viewModel: ChallengeRankingViewModel(
                eventService: container.evenetService,
                missionId: missionId
            )
        )
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Main View
struct ChallengeRankingView: View {
    @StateObject private var viewModel: ChallengeRankingViewModel
    
    init(viewModel: ChallengeRankingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ChallengeRankingNavBar(ChallengeName: "걷기 챌린지")
                
                if viewModel.isLoading {
                    LoadingView()
                } else {
                    MainContentView(viewModel: viewModel)
                }
            }
            
            // Bottom View
            VStack {
                Spacer()
                MyRankingBottomView(viewModel: viewModel)
            }
            
            // Toast Message
            if viewModel.showToast {
                ToastMessageView(
                    message: viewModel.toastMessage,
                    showToast: $viewModel.showToast
                )
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        Spacer()
        ProgressView("로딩 중...")
        Spacer()
    }
}

// MARK: - Main Content View
struct MainContentView: View {
    @ObservedObject var viewModel: ChallengeRankingViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ChallengeTop3PodiumView(top3: viewModel.top3)
                
                ChallengeDetailInfoView(viewModel: viewModel)
                
                ChallengeRankingListView(others: viewModel.others)
                    .padding(.bottom, 100)
            }
        }
    }
}


// MARK: - My Ranking Bottom View
struct MyRankingBottomView: View {
    @ObservedObject var viewModel: ChallengeRankingViewModel
    @State private var showCertifyAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("나의 기록")
                    .font(Font.Pretend.pretendardBold(size: 18))
                    .foregroundStyle(Color.orange01)
                Spacer()
                
                ActionButtonView(viewModel: viewModel, showCertifyAlert: $showCertifyAlert)
            }

            // 내 기록만 표시
            if let my = viewModel.myRank {
                MyRankInfoView(myRank: my, viewModel: viewModel)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.85))
                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: -2)
        )
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}

// MARK: - Action Button View
struct ActionButtonView: View {
    @ObservedObject var viewModel: ChallengeRankingViewModel
    @Binding var showCertifyAlert: Bool
    
    var body: some View {
        if !viewModel.isParticipating {
            Button("미션 참여하기") {
                viewModel.joinMission()
            }
            .buttonStyle(ActionButtonStyle())

        } else if viewModel.isParticipating && !viewModel.hasResult {
            Button("지금 인증하기") {
                showCertifyAlert = true
            }
            .buttonStyle(ActionButtonStyle())
            .alert("인증 안내", isPresented: $showCertifyAlert) {
                Button("취소", role: .cancel) {}
                Button("확인", role: .destructive) {
                    viewModel.handleCertifyAction()
                }
            } message: {
                Text("인증을 진행하면 다시 도전할 수 없습니다.\n지금 인증하시겠습니까?")
            }

        }
    }
}

// MARK: - My Rank Info View
struct MyRankInfoView: View {
    let myRank: RankUser
    @ObservedObject var viewModel: ChallengeRankingViewModel
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(myRank.rank)")
            Text(myRank.name)
            Spacer()
            
            if viewModel.missionType.rawValue == "steps" {
                Text("\(myRank.score) 걸음")
            } else if viewModel.missionType.rawValue == "calories" {
                Text("\(myRank.score) kcal")
            } else if viewModel.missionType.rawValue == "distance" {
                let distanceInMeters = Double(myRank.score)
                if distanceInMeters >= 1000 {
                    Text(String(format: "%.1f km", distanceInMeters / 1000.0))
                } else {
                    Text(String(format: "%.0f m", distanceInMeters))
                }
            } else {
                Text("\(myRank.score) 보")
            }
        }
        .font(Font.Pretend.pretendardSemiBold(size: 16))
    }
}

// MARK: - Toast Message View
struct ToastMessageView: View {
    let message: String
    @Binding var showToast: Bool
    
    var body: some View {
        VStack {
            Spacer()
            ToastView(message: message)
                .padding(.bottom, 40)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showToast = false
                        }
                    }
                }
        }
        .transition(.opacity)
        .animation(.easeInOut, value: showToast)
    }
}

// MARK: - Button Styles
struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.Pretend.pretendardSemiBold(size: 14))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Color.orange01)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// MARK: - Toast View
struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.8))
            .cornerRadius(10)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.3), value: message)
    }
}
