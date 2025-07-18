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
        switch challenge.type {
        case "EVENT": return "전체"
        case "NORMAL": return "일반"
        default: return "알 수 없음"
        }
    }

    var badgeColor: Color {
        switch challenge.type {
        case "EVENT": return Color.red
        case "NORMAL": return Color.yellow
        default: return Color.gray
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
                    .foregroundStyle(Color.black)
                    .lineLimit(1)

                HStack {
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text("\(challenge.currentMembers ?? 0 )/\(challenge.maxMember)")
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

}
