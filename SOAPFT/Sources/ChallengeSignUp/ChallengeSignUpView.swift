//
//  ChallengeSignUpView.swift
//  SOAPFT
//
//  Created by 바견규 on 7/1/25.
//

import SwiftUI




struct ChallengeSignUpWrapper: View {
    @Environment(\.diContainer) private var container
    let challengeUuid: String

    var body: some View {
        let viewModel = ChallengeSignUpViewModel(challengeService: container.challengeService, id: challengeUuid)
        ChallengeSignUpView(viewModel: viewModel)
            .navigationBarBackButtonHidden(true)
    }
}



struct ChallengeSignUpView: View {
    @StateObject var viewModel: ChallengeSignUpViewModel
    @State private var showJoinSheet: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                //0.네비게이션 바
                ChallengeSignUpNavBar(challengeName: viewModel.challenge.title)
                
                // 1. 커버 이미지 (배경)
                ZStack(alignment: .bottom) {
                    AsyncImage(url: URL(string: viewModel.challenge.banner ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 180)
                    .clipped()
                }
                
                // 2. 흰색 박스 위에 겹치는 프로필 이미지 + 그룹명 박스
                ZStack(alignment: .top) {
                    // 흰 박스
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(radius: 3)
                        .frame(height: 120)
                    
                    VStack(spacing: 8) {
                        // 겹쳐진 원형 프로필
                        AsyncImage(url: URL(string: viewModel.challenge.profile ?? "")) { image in
                            image
                                .resizable()
                                .clipShape(Circle())
                        } placeholder: {
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 80, height: 80)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .offset(y: -40) // 흰 박스 위로 겹치기
                        
                        // 그룹명
                        Text(viewModel.challenge.title)
                            .font(.headline)
                            .bold()
                            .padding(.top, -30) // 프로필 겹친 만큼 보정
                    }
                }
                .padding(.horizontal)
                .padding(.top, -40) // 배너 아래에 자연스럽게 겹침


                // 3. 요약 정보
                VStack(alignment: .leading, spacing: 8) {
                    infoRow(title: "기간", value: "\(viewModel.challenge.startDate) ~ \(viewModel.challenge.endDate)")
                    infoRow(title: "목표", value: "주 \(viewModel.challenge.goal)회 인증")
                    infoRow(title: "인원", value: "\(viewModel.challenge.currentMembers)/\(viewModel.challenge.maxMember)명")
                    infoRow(title: "성별", value: viewModel.challenge.gender == "ALL" ? "제한 없음" : viewModel.challenge.gender)
                    infoRow(title: "나이", value: "\(viewModel.challenge.startAge ?? 0)세 ~ \(viewModel.challenge.endAge.map { "\($0)세" } ?? "제한 없음")")
                    infoRow(title: "참여 코인", value: "\(viewModel.challenge.coinAmount)개")
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))

                // 5. 소개
                Text(viewModel.challenge.introduce)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
                
                Spacer()
                
                
                // 결과 안내 메시지
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }

                if viewModel.isJoinCompleted {
                    Text("가입 신청이 완료되었습니다!")
                        .foregroundStyle(.green)
                        .font(.subheadline)
                }
                
                // 8. 가입 버튼
                Button(action: {
                    showJoinSheet = true
                }) {
                    Text("가입 신청하기")
                        .font(Font.Pretend.pretendardSemiBold(size: 18))
                        .foregroundStyle(.white)
                        .padding(10)
                        .padding(.horizontal, 30)
                }
                .background(viewModel.isJoinable ? Color.orange01 : Color.gray)
                .cornerRadius(20)
                .disabled(!viewModel.isJoinable)
                .sheet(isPresented: $showJoinSheet) {
                    JoinConfirmationSheet {
                        viewModel.applyToChallenge()
                        showJoinSheet = false
                    }
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("그룹 정보")
        .navigationBarTitleDisplayMode(.inline)
    }

    // 재사용 가능한 정보 행
    @ViewBuilder
    func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.gray)
                .frame(alignment: .leading)
            Spacer()
            Text(value)
        }
    }
}


#Preview {
    
}
