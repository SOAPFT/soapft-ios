import SwiftUI
import Kingfisher

struct GroupMainView: View {
    @Environment(\.diContainer) private var container
    @StateObject private var viewModel = GroupMainViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) { // 상단 고정 부분
                // 로고
                
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
            .padding()
            
            Divider()
            
            ScrollView { // 스크롤뷰
                Spacer()
                
                // 광고 배너
                
                NewChallenge // 새로운 챌린지 만들기 버튼
                
                Spacer().frame(height: 30)
                
                ChallengeBannerView
                
                Spacer().frame(height: 30)
                
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
    
    private var NewChallenge: some View {
        VStack {
            Button(action: {
                print("new challenge")
                container.router.push(.groupCreate)
            }, label: {
                HStack {
                    Text("새로운 챌린지 만들기")
                        .font(Font.Pretend.pretendardMedium(size: 16))
                        .foregroundStyle(Color.black)
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.black)
                }
            })
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            Divider()
        }
    }
    
    private var ChallengeBannerView: some View {
        Group {
            HStack {
                Text("이벤트 챌린지 🎉")
                    .font(Font.Pretend.pretendardRegular(size: 16))
                Spacer()
            }
            if viewModel.event.isEmpty {
                Text("현재 참여 가능한 이벤트가 없습니다.")
                    .foregroundColor(.gray)
                    .frame(height: 260)
            } else {
                TabView {
                    ForEach(viewModel.event.indices, id: \.self) { index in
                        BannerCard(index: index)
                            .padding(.horizontal, 8)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(height: 260)
                .onAppear {
                    UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.systemGray
                    UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray6
                }
            }
        }
    }

    private func BannerCard(index: Int) -> some View {
        let challenge = viewModel.event[index]
        
        return VStack(spacing: 16) {
            Spacer()
             
            Text(challenge.title)
            
            // Kingfisher로 이미지 로드
            KFImage(URL(string: challenge.banner ?? ""))
                .placeholder {
                    // 플레이스홀더
                    Color.gray.opacity(0.3)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                        )
                }
                .onFailure { error in
                    print("이미지 로드 실패: \(error)")
                }
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(8)
            
            Button(action: {
                print("지금 참여하기 \(index)")
            }, label: {
                Text("지금 참여하기")
                    .font(Font.Pretend.pretendardSemiBold(size: 12))
                    .foregroundStyle(Color.white)
                    .frame(width: 100, height: 25)
                    .background(Color.orange01)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            })
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .aspectRatio(4/3, contentMode: .fit)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.black, lineWidth: 0.8)
                .background(Color.clear)
        )
    }
    
    private var HotChallenge: some View {
        VStack {
            HStack {
                Text("지금 인기 있는 챌린지 🔥")
                    .font(Font.Pretend.pretendardMedium(size: 16))
                
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
            // Kingfisher로 이미지 로드
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
                Text("최근 개설된 챌린지 🌱")
                    .font(Font.Pretend.pretendardMedium(size: 16))
                
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

// MARK: - 사용 예시 (더 고급 옵션들)

/*
// 더 많은 Kingfisher 옵션들:

KFImage(URL(string: imageURL))
    .placeholder {
        ProgressView()
            .frame(width: 100, height: 100)
    }
    .retry(maxCount: 3, interval: .seconds(0.5)) // 재시도
    .cacheOriginalImage() // 원본 이미지 캐시
    .fade(duration: 0.25) // 페이드 애니메이션
    .roundCorner(radius: 8) // 둥근 모서리
    .resizable()
    .scaledToFill()
    .frame(width: 100, height: 100)
    .clipped()
*/
