//
//  ChallengeDetailInfoView.swift
//  SOAPFT
//
//  Created by 바견규 on 8/6/25.
//

import SwiftUI

// MARK: - Challenge Detail Info View (Collapsible)
struct ChallengeDetailInfoView: View {
    @ObservedObject var viewModel: ChallengeRankingViewModel
    @State private var isExpanded = false  // 접힌 상태로 시작
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with expand/collapse button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text("챌린지 상세정보")
                        .font(Font.Pretend.pretendardBold(size: 16))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Collapsible content
            if isExpanded {
                VStack(spacing: 12) {
                    ChallengeInfoRow(
                        icon: "calendar",
                        iconColor: .blue,
                        text: viewModel.period
                    )
                    
                    ChallengeInfoRow(
                        icon: "gift.fill",
                        iconColor: .orange,
                        text: "보상: \(viewModel.reward) 코인 (10위 이내 지급)"
                    )
                    
                    ChallengeInfoRow(
                        icon: "figure.walk",
                        iconColor: .pink,
                        text: "타입: \(viewModel.missionType.displayName)"
                    )
                    
                    ChallengeInfoRow(
                        icon: "timer",
                        iconColor: .red,
                        text: "진행 시간: \(formattedDuration(seconds: viewModel.durationSeconds))"
                    )
                }
                .padding()
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity).combined(with: .offset(y: -10)),
                    removal: .scale(scale: 0.95).combined(with: .opacity).combined(with: .offset(y: -10))
                ))
            }
            ChallengeInfoRow(
                icon: viewModel.isLongTerm ? "clock.arrow.circlepath" : "applewatch.watchface",
                iconColor: viewModel.isLongTerm ? .purple : .green,
                text: viewModel.isLongTerm
                ? "장기 미션: 완료 후 자동으로 워치 데이터가 연동되어 인증됩니다."
                : "단기 미션: 실시간으로 Apple Watch 앱을 통해 인증해야 합니다."
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
    }
    
    private func formattedDuration(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        } else {
            return "\(minutes)분"
        }
    }
}

// MARK: - Challenge Info Row Component
struct ChallengeInfoRow: View {
    let icon: String
    let iconColor: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(iconColor)
                .clipShape(Circle())
            
            Text(text)
                .font(Font.Pretend.pretendardSemiBold(size: 14))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}
