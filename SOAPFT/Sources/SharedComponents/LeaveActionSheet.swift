//
//  LeaveActionSheet.swift
//  SOAPFT
//
//  Created by 바견규 on 9/7/25.
//

import SwiftUI

// MARK: - Leave Action Sheet
struct LeaveActionSheet: View {
    let onLeave: () -> Void
    let onCancel: () -> Void
    let leaveText:String
    
    var body: some View {
        VStack(spacing: 0) {
            // 드래그 인디케이터
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 32)
            
            VStack(spacing: 16) {
                // 탈퇴하기 버튼
                Button(action: onLeave) {
                    HStack {
                        Image(systemName: "person.badge.minus")
                            .foregroundColor(.red)
                        Text("\(leaveText)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(Color.red.opacity(0.05))
                    .cornerRadius(12)
                }
                
                // 취소 버튼
                Button(action: onCancel) {
                    Text("취소")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer(minLength: 34) // Safe area 고려
        }
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.hidden) // 커스텀 인디케이터 사용
    }
}
