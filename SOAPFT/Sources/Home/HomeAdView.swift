//
//  HomeAdView.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI

struct AdBannerView: View {
    var body: some View {
        ZStack {
            // 배경 카드
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.orange.opacity(0.4), Color.orange.opacity(0.2)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)

            HStack(spacing: 16) {
                // 아이콘 또는 이모지
                Text("⌚️")
                    .font(.largeTitle)
                    .padding(.leading, 8)

                // 텍스트 그룹
                VStack(alignment: .leading, spacing: 6) {
                    Text("이벤트 챌린지 준비 중!")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    Text("Apple Watch와 연동해 더 스마트하게!")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.7))
                }

                Spacer()

                // 배너 오른쪽 화살표 또는 버튼 느낌
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.trailing, 20)
            }
            .padding(.vertical, 12)
        }
        .frame(height: 90)
        .padding(.horizontal, 16)
    }
}

#Preview {
    AdBannerView()
}
