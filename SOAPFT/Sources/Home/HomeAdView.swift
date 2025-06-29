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
            Color.gray.opacity(0.2) // 배경색 또는 광고 이미지

            Text("📢")
                .font(.headline)
                .foregroundColor(.black)
        }
        .frame(height: 80) // 원하는 높이로 조정
        .frame(maxWidth: .infinity)
    }
}

#Preview{
    AdBannerView()
}
