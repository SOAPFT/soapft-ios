//
//  PaymentWebView.swift
//  SOAPFT
//
//  Created by 바견규 on 8/9/25.
//

import SwiftUI

// MARK: - 웹뷰 결제 화면
struct PaymentWebView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var webViewModel = PaymentWebViewModel()
    
    let coins: Int
    
    var body: some View {
        NavigationView {
            ZStack {
                // 웹뷰
                WebView(url: webViewModel.buildPaymentURL(coins: coins))
                
                // 로딩 인디케이터
                if webViewModel.isLoading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(1.2)
                        
                        Text("결제 페이지를 불러오는 중...")
                            .font(Font.Pretend.pretendardRegular(size: 14))
                            .foregroundColor(.gray)
                            .padding(.top, 16)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.8))
                }
            }
            .navigationTitle("결제")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .onReceive(webViewModel.$isLoading) { isLoading in
            // 로딩 상태 처리
        }
    }
}
