//
//  JoinConfirmationSheet.swift
//  SOAPFT
//
//  Created by 바견규 on 7/1/25.
//

import SwiftUI

struct JoinConfirmationSheet: View {
    var onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("지금 당장 참여하시겠습니까?")
                .font(.headline)
                .padding(.top)

            Button(action: {
                onConfirm()
            }) {
                Text("참여하기")
                    .foregroundStyle(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 40)
                    .background(Color.orange01)
                    .cornerRadius(20)
            }

            Spacer()
        }
        .padding()
        .presentationDetents([.height(400)]) // 시트 높이 조절
    }
}

#Preview {
    JoinConfirmationSheet {
        print("✅ 쪼앙 버튼 눌림")
    }
}
