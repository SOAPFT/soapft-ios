//
//  TypingIndicator.swift
//  SOAPFT
//
//  Created by 바견규 on 8/9/25.
//

import SwiftUI

// MARK: - 타이핑 인디케이터 뷰
struct TypingIndicatorView: View {
    let text: String
    @State private var animationScale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 8) {
            // 애니메이션 점들
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 6, height: 6)
                        .scaleEffect(animationScale)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animationScale
                        )
                }
            }
            
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
                .italic()
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .onAppear {
            animationScale = 0.5
        }
        .onDisappear {
            animationScale = 1.0
        }
    }
}
