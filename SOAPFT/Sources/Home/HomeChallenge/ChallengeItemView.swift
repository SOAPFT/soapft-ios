//
//  ChallengeView.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI
import Kingfisher

struct ChallengeItemView: View {
    let challenge: Challenge

    // 상태에 따른 뱃지 색상과 텍스트
    var badgeText: String {
        switch challenge.challengeType {
        case "EVENT": return "전체"
        case "GROUP": return "일반"
        default: return "알 수 없음"
        }
    }

    var badgeColor: Color {
        switch challenge.challengeType {
        case "EVENT": return Color.red
        case "GROUP": return Color.yellow
        default: return Color.gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                GeometryReader { geometry in
                    KFImage(URL(string: challenge.banner ?? ""))
                        .placeholder {
                            // 로딩 중 표시
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    ProgressView()
                                        .scaleEffect(0.8)
                                )
                        }
                        .retry(maxCount: 3)
                        .onSuccess { result in
                            print("✅ 이미지 로드 성공: \(result.source.url?.absoluteString ?? "")")
                        }
                        .onFailure { error in
                            print("❌ 이미지 로드 실패: \(error.localizedDescription)")
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
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
                    Text("\(challenge.currentMember ?? 0)/\(challenge.maxMember ?? 0)")
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
