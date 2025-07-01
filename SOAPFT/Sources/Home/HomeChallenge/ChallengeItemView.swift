//
//  ChallengeView.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI


struct ChallengeItemView: View {
    let challenge: Challenge

    // 상태에 따른 뱃지 색상과 텍스트
    var badgeText: String {
        switch challenge.status {
        case .inProgress: return "진행 중"
        case .upcoming: return "진행 예정"
        case .completed: return "완료"
        }
    }

    var badgeColor: Color {
        switch challenge.status {
        case .inProgress: return Color.red
        case .upcoming: return Color.yellow
        case .completed: return Color.green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .cornerRadius(12)
                    
                    Text(badgeText)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(badgeColor)
                        .cornerRadius(8)
                        .padding(8)
                }
                .aspectRatio(1, contentMode: .fit)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.title)
                    .font(.headline)
                    .lineLimit(1)

                Text("그룹 소개글")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .lineLimit(1)

                HStack {
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text("\(challenge.currentMembers)/\(challenge.maxMembers)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            .padding([.horizontal, .bottom], 8)
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}



#Preview {
    ChallengeItemView(challenge: ChallengesMockdata[0])
}
