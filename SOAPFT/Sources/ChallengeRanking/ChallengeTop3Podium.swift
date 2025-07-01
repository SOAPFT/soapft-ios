//
//  SwiftUIView.swift
//  SOAPFT
//
//  Created by 바견규 on 7/1/25.
//

// ChallengeRankingView.swift
import SwiftUI

struct ChallengeTop3PodiumView: View {
    let top3: [RankUser] = [
        RankUser(rank: 2, name: "챌린저이름", image: "https://i.pravatar.cc/100?img=11", score: "30000"),
        RankUser(rank: 1, name: "챌린저이름", image: "https://i.pravatar.cc/100?img=13", score: "25000"),
        RankUser(rank: 3, name: "챌린저이름", image: "https://i.pravatar.cc/100?img=17", score: "20000")
    ]
    
    var body: some View {
        ZStack {
            // 상단 그라데이션 배경
            LinearGradient(
                gradient: Gradient(colors: [.orange.opacity(0.3), .white]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                // 타이틀 & 별 아이콘
                VStack(spacing: 4) {
                    Text("CHALLENGE")
                        .font(Font.Pretend.pretendardRegular(size: 20))
                        .foregroundStyle(Color.orange01)
                
                    Text("RANKING")
                        .font(Font.Pretend.pretendardMedium(size: 40))
                        .foregroundStyle(Color.orange01)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.orange01)
                        .padding(.top, 4)
                }
                .padding(.top, 32)
                .padding(.bottom, 60)

                // 시상대 podium
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(0..<3) { i in
                        let user = top3[i]
                        let isCenter = i == 1
                        let height: CGFloat = isCenter ? 250 : (i == 0 ? 175 : 125)
                        
                        VStack(spacing: 8) {
                            AsyncImage(url: URL(string: user.image)) { image in
                                image.resizable()
                            } placeholder: {
                                Circle().fill(Color.gray.opacity(0.2))
                            }
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                            Text(user.name)
                                .font(Font.Pretend.pretendardBold(size: 14))
                                .multilineTextAlignment(.center)
                            Text(user.score)
                                .font(Font.Pretend.pretendardBold(size: 14))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 16)
                        .frame(width: 100, height: height)
                        .offset(y: offsetY(for: i))
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(color(for:i))
                        )
                    }
                }
                Spacer()
            }
        }
    }
}

// 시상대 podium (높이 조정 offset)
func offsetY(for index: Int) -> CGFloat {
    switch index {
    case 0: return -30   // 2등 (왼쪽)
    case 1: return -70  // 1등 (가운데)
    case 2: return -10   // 3등 (오른쪽)
    default: return 0
    }
}
// 시상대 podium (색상 분기)
func color(for index: Int) -> Color {
    switch index {
    case 0: return Color.gray.opacity(0.2)   // 2등
    case 1: return Color.yellow.opacity(0.5) // 1등
    case 2: return Color.gray.opacity(0.2)  // 3등
    default: return Color.gray.opacity(1)
    }
}

// 모델
struct RankUser: Identifiable {
    let id = UUID()
    let rank: Int
    let name: String
    let image: String
    let score: String
}

#Preview {
    ChallengeTop3PodiumView()
}

