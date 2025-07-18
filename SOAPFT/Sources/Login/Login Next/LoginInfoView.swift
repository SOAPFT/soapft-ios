//
//  LoginInfoView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/3/25.
//

import SwiftUI

struct LoginInfoView: View {
    @StateObject private var viewModel = LoginInfoViewModel()
    
    let genderOptions = ["남성", "여성"]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 45)  {
                    // 닉네임
                    VStack(alignment: .leading, spacing: 25) {
                        Text("닉네임을 입력해주세요")
                            .font(Font.Pretend.pretendardBold(size: 22))
                    
                        HStack(spacing: 8) {
                            TextField("닉네임을 입력해주세요", text: $viewModel.nickname)
                                .padding(.horizontal, 12)
                                .frame(height: 44)
                                .background(Color(uiColor: .secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(maxWidth: .infinity)
                            
                            Button(action: {
                                viewModel.fetchNickname()
                            }, label: {
                                Image(systemName: "arrow.trianglehead.2.clockwise")
                                    .foregroundStyle(Color.gray.opacity(0.8))
                                    .frame(width: 30, height: 30)
                            })
                        }
                    }
                    
                    // 성별
                    VStack(alignment: .leading, spacing: 25) {
                        Text("성별을 선택해주세요")
                            .font(Font.Pretend.pretendardBold(size: 22))
                        HStack {
                            Picker("성별", selection: $viewModel.gender) {
                                ForEach(genderOptions, id: \.self) { gender in
                                    Text(gender)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    
                    // 연령
                    VStack(alignment: .leading, spacing: 25) {
                        Text("생일을 선택해주세요")
                            .font(Font.Pretend.pretendardBold(size: 22))
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text(viewModel.birthFormatted)
                                .font(Font.Pretend.pretendardSemiBold(size: 18))
                                .foregroundStyle(Color.gray.opacity(0.8))
                            DatePicker("날짜를 선택하세요", selection: $viewModel.birth, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .frame(maxHeight: 400)
                                .tint(Color.orange01)
                        }
                        .frame(height: .infinity)
                    }
                    
                    Spacer()
                }
            }
            
            //버튼
            Button(action: {
                viewModel.openTerms()
            }, label: {
                Text("다음")
                    .foregroundStyle(Color.white)
                    .font(Font.Pretend.pretendardSemiBold(size: 14))
                    .padding(.horizontal, 50)
                    .padding(.vertical, 10)
                    .background(viewModel.isFormValid ? Color.orange01 : Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            })
            .disabled(!viewModel.isFormValid)
        }
        .padding(.horizontal, 12)
        .onAppear {
            viewModel.fetchNickname()
        }
        .sheet(isPresented: $viewModel.showTermsOfService) {
            TermsOfServiceView(loginInfoViewModel: viewModel)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    LoginInfoView()
}

