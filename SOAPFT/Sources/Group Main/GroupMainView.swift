import SwiftUI
import Kingfisher

struct GroupMainView: View {
    @Environment(\.diContainer) private var container
    @StateObject private var viewModel = GroupMainViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) { // 상단 고정 부분
                Button(action: {
                    print("new challenge")
                    container.router.push(.groupCreate)
                }, label: {
                    HStack {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.black)
                            .font(.system(size: 18))
                    }
                })
                
                Spacer()
                
                Button(action: {
                    container.router.push(.alert)
                }, label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .foregroundStyle(Color.black)
                            .font(.system(size: 18))

                        if viewModel.notificationCount > 0 {
                            Text("\(viewModel.notificationCount)")
                                .font(.caption2)
                                .foregroundStyle(.white)
                                .padding(5)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 8, y: -8)
                        }
                    }
                })
                
                Button(action: {container.router.push(.ChallengeSearchWrapper)}) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.black)
                        .font(.system(size: 18))
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            
            Divider()
            
            ScrollView { // 스크롤뷰
                Spacer().frame(height: 20)
                
                // 광고 배너

                ChallengeBannerView
                
                Spacer().frame(height: 20)
                
                HotChallenge // 지금 인기 있는 챌린지
                
                Spacer().frame(height: 30)
                
                RecentChallenge // 최근 개설된 챌린지
            }
            .padding(.horizontal, 12)
        }
        .onAppear() {
            viewModel.fetchHotChallenges()
            viewModel.fetchRecentChallenges()
            viewModel.fetchEventChallenges()
            viewModel.fetchNotificationCount()
        }
        .navigationBarBackButtonHidden()
    }
    
    
    private var ChallengeBannerView: some View {
        VStack(spacing: 0) { // 기존 default spacing을 8로 설정
            HStack {
                Text("이벤트 챌린지")
                    .font(Font.Pretend.pretendardMedium(size: 16))
                Image(systemName: "party.popper")
                    .foregroundColor(.orange)
                    .font(.system(size: 16))
                Spacer()
            }
            
            if viewModel.event.isEmpty {
                Text("현재 참여 가능한 이벤트가 없습니다.")
                    .foregroundColor(.gray)
                    .frame(height: 260)
            } else {
                VStack(spacing: 0) {
                    TabView {
                        ForEach(viewModel.event.indices, id: \.self) { index in
                            BannerCard(index: index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 240)
                    .onAppear {
                        // transform 제거하여 크래시 방지
                        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.systemOrange
                        UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray5
                    }
                }
            }
        }
    }

    private func BannerCard(index: Int) -> some View {
        let mission = viewModel.event[index]
        
        return ZStack {
            // 배경 그라데이션
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.4, blue: 0.3),
                            Color(red: 0.85, green: 0.35, blue: 0.4),
                            Color(red: 0.75, green: 0.3, blue: 0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // 장식용 원들
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 100, height: 100)
                            .offset(x: 70, y: -50)
                        
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 60, height: 60)
                            .offset(x: -60, y: 40)
                        
                        Circle()
                            .fill(Color.yellow.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .offset(x: 50, y: 35)
                    }
                )
            
            VStack(spacing: 16) {
                // 상단 영역
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        // 타입 뱃지
                        HStack(spacing: 6) {
                            Image(systemName: missionTypeIcon(for: mission.type))
                                .foregroundColor(.white)
                                .font(.system(size: 11, weight: .semibold))
                            Text(mission.type.displayName)
                                .font(Font.Pretend.pretendardSemiBold(size: 11))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.25))
                        )
                        
                        // 메인 타이틀
                        Text(mission.title)
                            .font(Font.Pretend.pretendardBold(size: 18))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    // 보상 정보
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color.yellow.opacity(0.9))
                                .frame(width: 45, height: 45)
                            
                            VStack(spacing: 1) {
                                Image("coin")
                                    .resizable()
                                    .frame(width: 14, height: 14)
                                Text("\(mission.reward)")
                                    .font(Font.Pretend.pretendardBold(size: 9))
                                    .foregroundColor(.white)
                            }
                        }
                        .shadow(color: Color.yellow.opacity(0.4), radius: 6, x: 0, y: 3)
                        
                        Text("보상")
                            .font(Font.Pretend.pretendardMedium(size: 9))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // 설명
                Text(mission.description)
                    .font(Font.Pretend.pretendardRegular(size: 13))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 8)
                
                // 참여 버튼
                Button(action: {
                    print("이벤트 미션 참여하기 탭됨 - ID: \(mission.id), 제목: \(mission.title)")
                    container.router.push(.challengeRankingWrapper(missionId: mission.id))
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                        
                        Text("도전하기")
                            .font(Font.Pretend.pretendardSemiBold(size: 14))
                            .foregroundColor(.white)
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .contentShape(Rectangle())
            }
            .padding(18)
        }
        .frame(height: 200)
        .padding(.horizontal, 8)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    
    private var NewChallenge: some View {
        VStack {
            Button(action: {
                print("new challenge")
                container.router.push(.groupCreate)
            }, label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.black)
                        .frame(width: 43, height: 43)
                }
            })
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            Divider()
        }
    }

    private func missionTypeIcon(for type: MissionType) -> String {
        switch type {
        case .distance:
            return "figure.run"
        case .steps:
            return "figure.walk"
        case .calories:
            return "flame"
        }
    }


    // MARK: - 이벤트 아이콘 뷰
    private struct EventIconView: View {
        let challengeType: String?
        
        var body: some View {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange02.opacity(0.2), Color.orange02.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: iconName)
                    .font(.system(size: 32))
                    .foregroundColor(.orange02)
            }
            .frame(width: 100, height: 100)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.gray.opacity(0.5), lineWidth: 0.8)
            )
        }
        
        private var iconName: String {
            if challengeType == "EVENT" {
                return "party.popper"
            } else {
                return "star.circle"
            }
        }
    }
    
    private var HotChallenge: some View {
        VStack {
            HStack {
                Text("지금 인기 있는 챌린지")
                    .font(Font.Pretend.pretendardMedium(size: 16))
                Image(systemName: "flame")
                    .foregroundColor(.red)
                    .font(.system(size: 16))
                
                Spacer()
                
                Button(action: {
                    container.router.push(.moreHotGroup)
                }, label: {
                    HStack(spacing: 4) {
                        Text("더보기")
                            .font(Font.Pretend.pretendardLight(size: 11))
                            .foregroundStyle(Color.gray)
                        Image(systemName: "chevron.right")
                            .resizable()
                            .frame(width: 6, height: 6)
                            .foregroundStyle(Color.gray)
                    }
                })
            }
            
            ScrollView (.horizontal) {
                LazyHStack (spacing: 17) {
                    ForEach(viewModel.hot, id: \.self) { challenge in
                        Button(action: {
                            if challenge.isParticipated ?? false {
                                container.router.push(.GroupTabbar(ChallengeID: challenge.challengeUuid ?? ""))
                            } else {
                                container.router.push(.challengeSignUpWrapper(ChallengeID: challenge.challengeUuid ?? ""))
                            }
                        }) {
                            ChallengeCard(Name: challenge.banner ?? "", Title: challenge.title)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private func ChallengeCard(Name: String, Title: String) -> some View {
        VStack {
            // Kingfisher로 이미지 로드 (테두리 추가)
            KFImage(URL(string: Name))
                .placeholder {
                    // 플레이스홀더
                    Color.gray.opacity(0.3)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                        )
                }
                .onFailure { error in
                    print("챌린지 카드 이미지 로드 실패: \(error)")
                }
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.gray.opacity(0.5), lineWidth: 0.8)
                )

            HStack {
                Text(Title)
                    .font(Font.Pretend.pretendardLight(size: 12))
                    .foregroundStyle(Color.black)
                    .frame(width: 100, height: 30, alignment: .leading)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
        }
    }
    
    private var RecentChallenge: some View {
        VStack {
            HStack {
                Text("최근 개설된 챌린지")
                    .font(Font.Pretend.pretendardMedium(size: 16))
                Image(systemName: "leaf")
                    .foregroundColor(.green)
                    .font(.system(size: 16))
                
                Spacer()
                
                Button(action: {
                    container.router.push(.moreRecentGroup)
                }, label: {
                    HStack(spacing: 4) {
                        Text("더보기")
                            .font(Font.Pretend.pretendardLight(size: 11))
                            .foregroundStyle(Color.gray)
                        Image(systemName: "chevron.right")
                            .resizable()
                            .frame(width: 6, height: 6)
                            .foregroundStyle(Color.gray)
                    }
                })
            }
            
            ScrollView (.horizontal) {
                LazyHStack (spacing: 17) {
                    ForEach(viewModel.recent, id: \.self) { challenge in
                        Button(action: {
                            if challenge.isParticipated ?? false {
                                container.router.push(.GroupTabbar(ChallengeID: challenge.challengeUuid ?? ""))
                            } else {
                                container.router.push(.challengeSignUpWrapper(ChallengeID: challenge.challengeUuid ?? ""))
                            }
                        }) {
                            ChallengeCard(Name: challenge.banner ?? "", Title: challenge.title)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}


#Preview {
    GroupMainView()
}

// MARK: - Kingfisher 확장 옵션들

extension KFImage {
    /// 캐시와 애니메이션이 포함된 커스텀 설정
    func customImageSetup() -> some View {
        self
            .cacheMemoryOnly() // 메모리 캐시만 사용
            .fade(duration: 0.25) // 페이드 애니메이션
            .onProgress { receivedSize, totalSize in
                // 다운로드 진행상황 (필요시 사용)
                let progress = (Float(receivedSize) / Float(totalSize)) * 100
                print("다운로드 진행률: \(progress)%")
            }
            .onSuccess { result in
                print("이미지 로드 성공: \(result.source.url?.absoluteString ?? "")")
            }
    }
}
