//
//  StripeProgressBar.swift
//  SOAPFT
//
//  Created by 바견규 on 7/3/25.
//

import SwiftUI

struct StripedProgressBar: View {
    var progress: CGFloat // 0.0 ~ 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 배경
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)

                // 진행 영역 + 줄무늬
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(gradient: Gradient(colors: [Color.orange01, Color.orange]), startPoint: .leading, endPoint: .trailing)
                        )

                    Stripes()
                        .opacity(0.3)
                        .mask(RoundedRectangle(cornerRadius: 8))
                }
                .frame(width: geometry.size.width * progress, height: 20)
            }
        }
        .frame(height: 20)
    }
}

// 스트라이프 패턴 뷰
struct Stripes: View {
    var body: some View {
        GeometryReader { geo in
            let stripeWidth: CGFloat = 10
            let spacing: CGFloat = 10
            let count = Int(geo.size.width / (stripeWidth + spacing)) + 10

            HStack(spacing: spacing) {
                ForEach(0..<count, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.white)
                        .rotationEffect(.degrees(45))
                        .frame(width: stripeWidth*0.7, height: 40)
                }
            }
            .frame(height: geo.size.height)
        }
    }
}


#Preview {
    StripedProgressBar(progress: 0.75)
}
