//
//  TermsOfServiceView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/3/25.
//

import SwiftUI

struct TermsOfServiceView: View {
    @StateObject var viewModel = PermitViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Toggle("전체 동의하기", isOn: $viewModel.allPermit)
                    .toggleStyle(CheckboxToggleStyle(style: .circle))
                    .foregroundStyle(Color.gray.opacity(0.8))
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
            }
            .padding(.bottom, 14)
            
            HStack {
                Toggle("만 14세 이상입니다", isOn: $viewModel.fourteenPermit)
                    .toggleStyle(CheckboxToggleStyle(style: .circle))
                    .foregroundStyle(Color.gray.opacity(0.8))
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            HStack {
                Toggle("서비스 이용 약관 동의", isOn: $viewModel.termsOfServicePermit)
                    .toggleStyle(CheckboxToggleStyle(style: .circle))
                    .foregroundStyle(Color.gray.opacity(0.8))
                
                Button(action: {
                    
                }, label: {
                    Text("보기")
                        .underline()
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.gray.opacity(0.4))
                })
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            HStack {
                Toggle("개인정보 처리방침 동의", isOn: $viewModel.informationPermit)
                    .toggleStyle(CheckboxToggleStyle(style: .circle))
                    .foregroundStyle(Color.gray.opacity(0.8))
                
                Button(action: {
                    
                }, label: {
                    Text("보기")
                        .underline()
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.gray.opacity(0.4))
                })
                
                Spacer()
            }
            
            Spacer().frame(height: 35)
            
            //버튼
            Button(action: {
                
            }, label: {
                Text("시작하기")
                    .foregroundStyle(Color.white)
                    .font(Font.Pretend.pretendardSemiBold(size: 14))
                    .padding(.horizontal, 50)
                    .padding(.vertical, 10)
                    .background(isFormValid ? Color.orange01 : Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            })
            .disabled(!isFormValid)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
    }
    
    private var isFormValid: Bool {
        viewModel.fourteenPermit &&
        viewModel.termsOfServicePermit &&
        viewModel.informationPermit
    }
}

#Preview {
    TermsOfServiceView()
}
