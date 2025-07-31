//
//  CreateWarningView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/5/25.
//

import SwiftUI

struct WarningView: View {
    @Environment(\.diContainer) private var container
    @Binding var showPopUp: Bool
//    @ObservedObject var viewModel: GroupCreateViewModel
    @Environment(\.dismiss) private var dismiss
    
    let viewModel: GroupCreateViewModel
    
    let title: String // 공지 이름
    let message: String // 공지 내용
    let btn1: String // 왼쪽 버튼 text
    let btn2: String // 오른쪽 버튼 text
    let onConfirm: () -> Void // 확인 버튼 눌렀을 때 실행할 동작
    
    var body: some View {
        ZStack {
            /// Background - 팝업 띄울 때 뒷 배경 어둡게
            Rectangle()
                .background(.black)
                .opacity(0.2)
            
            VStack {
                Text(title)
                    .frame(height: 30)
                    .font(Font.Pretend.pretendardSemiBold(size: 16))
                    .padding(.top, 12)
                
                Divider()
                
                Text(message)
                    .font(Font.Pretend.pretendardLight(size: 15))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.vertical, 8)
                
                HStack(spacing: 8) {
                    
                    Button(action: {
                        
                        print("확인 누름")
                        print("2. \(viewModel.groupName), \(viewModel.description), \(viewModel.authMethod)")
                        onConfirm()          // createChallenge() 실행됨
                    }, label: {
                        Text(btn1)
                            .font(Font.Pretend.pretendardMedium(size: 16))
                            .foregroundStyle(.white)
                            .padding(.vertical, 8)
                            .frame(width: 100)
                    })
                    .background(
                        /// 버튼 테두리
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.orange01)
                        
                    )
                    
                    Button(action: {
                        
                        print("취소 누름")
                        showPopUp = false
                        
                    }, label: {
                        Text(btn2)
                            .font(Font.Pretend.pretendardMedium(size: 16))
                            .foregroundStyle(.gray)
                            .padding(.vertical, 8)
                            .frame(width: 100)
                        
                        
                    })
                    .background(
                        /// 버튼 테두리
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 1)
                    )
                }
                .frame(height: 44)
                .padding(.bottom, 12)
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 20)
        }
        .ignoresSafeArea(.all)
    }
}

//#Preview {
//    WarningView(showPopUp: .constant(false),
//              title: "챌린지를 생성하시겠습니까?",
//              message: "챌린지 생성 후 수정 및 삭제가 불가합니다.\n가입 조건 및 인증 조건을 정확하게 입력하였는지 확인해주세요.",
//              btn1: "생성하기",
//              btn2: "취소",
//                onConfirm: {
//                    print("챌린지 생성 API 호출") // 실제 생성 로직 실행
//                }
//    )
//}
