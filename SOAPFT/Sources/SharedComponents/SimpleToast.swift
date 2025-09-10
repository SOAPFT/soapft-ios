//
//  SimpleToast.swift
//  SOAPFT
//
//  Created by 바견규 on 9/7/25.
//

import SwiftUI

// MARK: - Improved Simple Toast View
struct SimpleToast: View {
    let message: String
    let isSuccess: Bool
    @Binding var isVisible: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isSuccess ? .green : .red)
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white) // 검은 배경에 흰색 텍스트
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.75)) // 더 투명한 배경
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.8)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isVisible)
        .onAppear {
            if isVisible {
                // 토스트가 표시되면 2.5초 후 자동으로 숨김
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isVisible = false
                    }
                }
            }
        }
        .onChange(of: isVisible) { oldValue, newValue in
            if newValue {
                // 토스트가 true로 변경될 때마다 타이머 시작
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isVisible = false
                    }
                }
            }
        }
    }
}

// MARK: - Toast Modifier for easy usage
struct ToastModifier: ViewModifier {
    @Binding var isVisible: Bool
    let message: String
    let isSuccess: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                // 토스트를 화면 상단에 표시
                VStack {
                    if isVisible {
                        SimpleToast(
                            message: message,
                            isSuccess: isSuccess,
                            isVisible: $isVisible
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    Spacer()
                },
                alignment: .top
            )
    }
}

// MARK: - View Extension for easy toast usage
extension View {
    func toast(
        message: String,
        isSuccess: Bool = true,
        isVisible: Binding<Bool>
    ) -> some View {
        self.modifier(ToastModifier(
            isVisible: isVisible,
            message: message,
            isSuccess: isSuccess
        ))
    }
}
