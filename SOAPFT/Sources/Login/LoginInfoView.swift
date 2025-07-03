//
//  LoginInfoView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/3/25.
//

import SwiftUI

struct LoginInfoView: View {
    @State private var showTermsOfService = false
    
    @State private var nickname: String = ""
    @State private var gender: String = "남성"
    @State private var birth: Date = Date()
    
    let genderOptions = ["남성", "여성"]
    
    private var birthFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: birth)
    }
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 45)  {
                    // 닉네임
                    VStack(alignment: .leading, spacing: 25) {
                        Text("닉네임을 입력해주세요")
                            .font(Font.Pretend.pretendardBold(size: 22))
                        TextField("닉네입을 입력해주세요", text: $nickname)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // 성별
                    VStack(alignment: .leading, spacing: 25) {
                        Text("성별을 선택해주세요")
                            .font(Font.Pretend.pretendardBold(size: 22))
                        HStack {
                            Picker("성별", selection: $gender) {
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
                            Text(birthFormatted)
                                .font(Font.Pretend.pretendardSemiBold(size: 18))
                                .foregroundStyle(Color.gray.opacity(0.8))
                            DatePicker("날짜를 선택하세요", selection: $birth, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .frame(maxHeight: 400)
                                .tint(Color.orange01)
                        }
                    }
                    
                    Spacer()
                }
            }
            
            //버튼
            Button(action: {
                showTermsOfService = true
            }, label: {
                Text("다음")
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
        .sheet(isPresented: $showTermsOfService) {
            TermsOfServiceView()
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var isFormValid: Bool {
        !nickname.trimmingCharacters(in: .whitespaces).isEmpty &&
        !gender.trimmingCharacters(in: .whitespaces).isEmpty &&
        !birth.description.isEmpty
    }
}

#Preview {
    LoginInfoView()
}
