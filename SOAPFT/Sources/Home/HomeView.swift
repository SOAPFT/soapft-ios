//
//  Home.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI
import Lottie

struct Home: View {
    @StateObject private var viewModel: HomeViewModel
    @Environment(\.diContainer) private var container
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            homeNavBar()
            
//            Divider()
            
            ScrollView {
                LazyVStack {
                    LottieView(filename: "Fire")
                        .frame(width: 120, height: 90)
                        .padding(.top, 33)
                    
                    Text("\(viewModel.completedChallengeCount)")
                        .font(Font.Pretend.pretendardBold(size: 60))
                    Text("Challenges You've Completed")
                        .font(Font.Pretend.pretendardSemiBold(size: 15))
                        .padding(.bottom, 33)
                    
                    AdBannerView()
                        .padding(.vertical)
                    
                    HomeChallengeToggleView(selectedTab: $viewModel.selectedTab)
                        .padding()
                    
                    if viewModel.filteredChallenges.isEmpty {
                        Image("NoneParticipateChallenge")
                            .padding()
                        Text("참여하는 챌린지가 없어요")
                            .font(Font.Pretend.pretendardSemiBold(size: 18))
                            .foregroundStyle(.gray)
                        Text("챌린지에 참여해보세요!")
                            .font(Font.Pretend.pretendardLight(size: 15))
                            .foregroundStyle(.gray)
                            .padding(1)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.filteredChallenges, id: \.id) { challenge in
                                Button(action: { handleChallengeTap(challenge) }) {
                                    ChallengeItemView(challenge: challenge)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    // MARK: - 챌린지 목록 탭 시
    private func handleChallengeTap(_ challenge: Challenge) {
        switch challenge.challengeType {
        case "EVENT":
            // 이벤트 → missionId 사용
            container.router.push(.challengeRankingWrapper(missionId: challenge.id))
            
        case "GROUP":
            // 일반 챌린지 → challengeUuid 사용
            if let uuid = challenge.challengeUuid {
                container.router.push(.GroupTabbar(ChallengeID: uuid))
            } else {
                print("❌ challengeUuid가 없음")
            }
            
        default:
            print("❌ 지원하지 않는 챌린지 타입: \(challenge.challengeType ?? "")")
        }
    }

}

struct HomeWrapper: View {
    @Environment(\.diContainer) private var container
    
    var body: some View {
        let viewModel = HomeViewModel(challengeService: container.challengeService)
        Home(viewModel: viewModel)
            .navigationBarBackButtonHidden(true)
            .onReceive(container.challengeRefreshSubject) { _ in
                print("📨 chatRefreshSubject 수신됨")
                viewModel.fetchChallenges()
            }
    }
   
}

#Preview {
}

