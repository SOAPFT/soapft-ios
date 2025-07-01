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

            // 캐릭터 이미지 (예: 로컬 또는 URL)
            Image("swing_a_whip") // Assets에 있는 파일 이름 (확장자 없이)
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)

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
