//
//  coinInputView.swift
//  SOAPFT
//
//  Created by 바견규 on 8/10/25.
//

import SwiftUI
import WebKit

// MARK: - 코인 입력 화면
struct CoinInputView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var coinAmount: String = ""
    @State private var showingWebView = false
    
    let onCoinSelected: (Int) -> Void
    
    private var coins: Int {
        Int(coinAmount) ?? 0
    }
    
    private var price: Int {
        coins * 10  // 1코인당 10원
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // 코인 입력
                VStack(spacing: 16) {
                    Text("충전할 코인을 입력하세요")
                        .font(Font.Pretend.pretendardMedium(size: 18))
                        .foregroundColor(.black)
                    
                    HStack(spacing: 12) {
                        Image("coin")
                            .resizable()
                            .frame(width: 32, height: 32)
                        
                        TextField("코인 수량", text: $coinAmount)
                            .font(Font.Pretend.pretendardRegular(size: 24))
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text("코인")
                            .font(Font.Pretend.pretendardRegular(size: 18))
                            .foregroundColor(.gray)
                    }
                }
                
                // 금액 표시
                if coins > 0 {
                    VStack(spacing: 8) {
                        Text("결제 금액")
                            .font(Font.Pretend.pretendardRegular(size: 14))
                            .foregroundColor(.gray)
                        
                        Text("₩\(price)")
                            .font(Font.Pretend.pretendardBold(size: 28))
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                // 확인 버튼
                Button(action: {
                    showingWebView = true
                }) {
                    Text("결제하기")
                        .font(Font.Pretend.pretendardBold(size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            coins > 0 ? Color.blue : Color.gray.opacity(0.5)
                        )
                        .cornerRadius(12)
                }
                .disabled(coins <= 0)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .navigationTitle("코인 충전")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                Button("취소") {
                    dismiss()
                }
                .foregroundColor(.blue)
            )
        }
        .fullScreenCover(isPresented: $showingWebView) {
            PaymentWebView(
                coins: coins
            )
        }
    }
}
