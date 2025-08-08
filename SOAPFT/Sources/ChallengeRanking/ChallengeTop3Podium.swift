//
//  SwiftUIView.swift
//  SOAPFT
//
//  Created by 바견규 on 7/1/25.
//

// ChallengeRankingView.swift

import SwiftUI
import Kingfisher

struct ChallengeTop3PodiumView: View {
    let top3: [RankUser]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.orange.opacity(0.3), .white]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
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

                if top3.isEmpty {
                    emptyStateView
                } else {
                    podiumView
                }

                Spacer()
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))

            Text("아직 참여자가 없습니다")
                .font(Font.Pretend.pretendardMedium(size: 16))
                .foregroundColor(.gray)

            Text("첫 번째 참여자가 되어보세요!")
                .font(Font.Pretend.pretendardRegular(size: 14))
                .foregroundColor(.gray.opacity(0.7))
        }
        .padding(.vertical, 50)
    }

    // MARK: - Podium View
    private var podiumView: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if top3.count > 1 {
                podiumUserView(user: top3[1], height: 175, offset: -30, color: .gray.opacity(0.2)) // 2등
            } else {
                placeholderView(height: 175, offset: -30)
            }

            podiumUserView(user: top3[0], height: 250, offset: -70, color: .yellow.opacity(0.5)) // 1등

            if top3.count > 2 {
                podiumUserView(user: top3[2], height: 125, offset: -10, color: .gray.opacity(0.2)) // 3등
            } else {
                placeholderView(height: 125, offset: -10)
            }
        }
    }

    private func podiumUserView(user: RankUser, height: CGFloat, offset: CGFloat, color: Color) -> some View {
        VStack(spacing: 8) {
            KFImage(URL(string: user.image))
                .placeholder {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                        )
                }
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(Circle())

            Text(user.name)
                .font(Font.Pretend.pretendardBold(size: 14))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text("\(user.score)")
                .font(Font.Pretend.pretendardBold(size: 14))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 16)
        .frame(width: 100, height: height)
        .offset(y: offset)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
        )
    }

    private func placeholderView(height: CGFloat, offset: CGFloat) -> some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.clear)
                .frame(width: 64, height: 64)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .overlay(
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(.gray.opacity(0.5))
                                .font(.system(size: 25))
                        )
                )

            Text("대기 중")
                .font(Font.Pretend.pretendardMedium(size: 12))
                .foregroundColor(.gray.opacity(0.7))

            Text("0점")
                .font(Font.Pretend.pretendardMedium(size: 12))
                .foregroundColor(.gray.opacity(0.7))
        }
        .padding(.top, 16)
        .frame(width: 100, height: height)
        .offset(y: offset)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
                )
        )
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


