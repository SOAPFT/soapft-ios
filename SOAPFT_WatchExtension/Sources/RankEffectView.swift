//
//  RankEffectView.swift
//  SOAPFT
//
//  Created by 바견규 on 8/7/25.
//

import SwiftUI

// MARK: - Rank Effect View
struct RankEffectView: View {
    let newRank: Int
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.green)
            
            Text("순위 상승!")
                .font(.headline.weight(.bold))
                .foregroundColor(.white)
            
            Text("\(newRank)위")
                .font(.title.weight(.bold))
                .foregroundColor(.yellow)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.green.opacity(0.5), lineWidth: 2)
                )
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                }
            }
        }
    }
}
