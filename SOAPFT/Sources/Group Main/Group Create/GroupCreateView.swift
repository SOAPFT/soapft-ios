//
//  GroupCreateView.swift
//  SOAPFT
//
//  Created by 홍지우 on 6/30/25.
//

import SwiftUI

struct GroupCreateView: View {
    @State private var groupName = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var description = ""
    @State private var maxMembers = 10
    @State private var selectedGender = "제한 없음"
    @State private var selectedAgeRange = 20...40
    @State private var selectedGoal = "주 7회"
    @State private var authMethod = ""
    
    let genderOptions = ["제한 없음", "남성", "여성"]
    let goalOptions = ["주 1회", "주 2회", "주 3회", "주 4회","주 5회", "주 6회", "주 7회"]
    
    @State private var selection: ClosedRange<CGFloat> = 20...40
    
    var body: some View {
        VStack {
            // 상단바
            ZStack {
                HStack {
                    Button(action: { }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 18))
                    }
                    Spacer()
                }

                Text("그룹 생성")
                    .font(Font.Pretend.pretendardBold(size: 16))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 25) {
                    // MARK: - 챌린지명
                    VStack(alignment: .leading, spacing: 6) {
                        Text("챌린지명")
                            .font(Font.Pretend.pretendardMedium(size: 16))
                        
                        TextEditor(text: $groupName)
                            .customStyleEditor(placeholder: "그룹명", userInput: $groupName, showCount: false)
                            .frame(height: 43)
                    }
                    
                    // MARK: - 시작일
                    VStack(alignment: .leading, spacing: 6) {
                        Text("시작일")
                            .font(Font.Pretend.pretendardMedium(size: 16))
                        
                        DatePicker("", selection: $startDate, in: ...endDate, displayedComponents: .date)
                            .labelsHidden()
                            .tint(Color.orange01)
                    }
                    
                    // MARK: - 종료일
                    VStack(alignment: .leading, spacing: 6) {
                        Text("종료일")
                            .font(Font.Pretend.pretendardMedium(size: 16))
                        
                        DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                            .labelsHidden()
                            .tint(Color.orange01)
                    }
                    
                    // MARK: - 챌린지 소개
                    VStack(alignment: .leading, spacing: 6) {
                        Text("챌린지 소개")
                            .font(Font.Pretend.pretendardMedium(size: 16))
                        
                        VStack {
                            TextEditor(text: $description)
                                .customStyleEditor(placeholder: "예) 매일 6시에 기상하는 걸 목표로 건강한 생활 습관을 기르고자 합니다!", userInput: $description)
                                .frame(height: 200)
                        }
                    }
                    
                    // MARK: - 최대 인원
                    VStack(alignment: .leading, spacing: 6) {
                        Text("최대 인원")
                            .font(Font.Pretend.pretendardMedium(size: 16))
                        
                        HStack {
                            Picker("최대 인원", selection: $maxMembers) {
                                ForEach(10...50, id: \.self) { number in
                                        Text("\(number)").tag("\(number)")
                                            .foregroundStyle(Color.black)
                                    }
                                }
                            .pickerStyle(.menu)
                            .tint(Color.orange01)
                            
                            Spacer()
                            
                            Text("\(maxMembers)명")
                                .font(Font.Pretend.pretendardRegular(size: 16))
                                .padding(.trailing, 6)
                        }
                    }
                    
                    // MARK: - 성별
                    VStack(alignment: .leading, spacing: 6) {
                        Text("성별")
                            .font(Font.Pretend.pretendardMedium(size: 16))
                        
                        Picker("성별", selection: $selectedGender) {
                            ForEach(genderOptions, id: \.self) { gender in
                                Text(gender)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Color.orange01)
                    }
                    
                    // MARK: - 연령대
                    VStack(alignment: .leading, spacing: 6) {
                        Text("연령대")
                            .font(Font.Pretend.pretendardMedium(size: 16))
                        
                        Text("\(Int(selection.lowerBound/10))0대 ~ \(Int(selection.upperBound/10))0대")
                            .font(Font.Pretend.pretendardLight(size: 18))
                            .padding(.top, 10)
                        
                        RangeSliderView(
                            selection: $selection,
                            range: 10...60,
                            minimumDistance: 0)
                    }
                    
                    // MARK: - 목표 설정
                    VStack(alignment: .leading, spacing: 6) {
                        Text("목표 설정")
                            .font(Font.Pretend.pretendardMedium(size: 16))
                        
                        Picker("목표", selection: $selectedGoal) {
                            ForEach(goalOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Color.orange01)
                    }
                    
                    // MARK: - 인증 방법
                    VStack(alignment: .leading, spacing: 6) {
                        Text("인증 방법")
                            .font(Font.Pretend.pretendardMedium(size: 16))
                        
                        VStack {
                            TextEditor(text: $authMethod)
                                .customStyleEditor(placeholder: "***챌린지가 시작하면 수정이 어려우니 최대한 자세히 적어주세요***\n\n예) 주 5회 이상 5시 30분에서 6시 반 사이에 시간이 나오도록 일어났다는 걸 인증해주시면 됩니다!", userInput: $description)
                                .frame(height: 200)
                        }
                    }
                }
                
                Spacer().frame(height: 30)
                
                Button(action: {
                    if isFormValid {
                        print("다음으로 이동")
                    }
                }, label: {
                    Text("다음")
                        .foregroundStyle(Color.white)
                        .font(Font.Pretend.pretendardSemiBold(size: 14))
                        .padding(.horizontal, 43)
                        .padding(.vertical, 10)
                        .background(isFormValid ? Color.orange01 : Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                })
                .disabled(!isFormValid)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 12)
        }
    }
    
    private var isFormValid: Bool {
        !groupName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
//        endDate > startDate &&
        (10...50).contains(maxMembers) &&
        !selectedGender.isEmpty &&
        !selectedGoal.isEmpty
    }
}

#Preview {
    GroupCreateView()
}
