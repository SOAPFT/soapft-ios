//
//  ChallengeGridCard.swift
//  SOAPFT
//
//  Created by 홍지우 on 6/30/25.
//

import SwiftUI

struct ChallengeGridCard: View {
    let challenge: Challenge
    
    var body: some View {
        VStack(spacing: 12) {
            Image(challenge.banner ?? "")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 120)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                )
            
            HStack {
                Text(challenge.title)
                    .font(Font.Pretend.pretendardMedium(size: 14))
                    .foregroundStyle(Color.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white)
        )
        .onTapGesture {
            print("챌린지 선택: \(challenge.title)")
        }
    }
}

