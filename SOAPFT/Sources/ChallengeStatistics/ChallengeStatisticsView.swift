//
//  ChallengeStatisticsView.swift
//  SOAPFT
//
//  Created by 바견규 on 7/3/25.
//

import SwiftUI

struct ChallengeStatisticsView: View {
    @StateObject var viewModel:ChallengeStatisticsViewModel
    
    var body: some View {
        VStack{
            ChallengeStatisticsNavBar()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text("챌린지 현황")
                        .font(Font.Pretend.pretendardSemiBold(size: 20))
                        .padding(.horizontal, 20)
                    
                    Text("지금 바로 도전해보세요!")
                        .font(Font.Pretend.pretendardRegular(size: 16))
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 4)
                    
                    GoalCompletionRate(
                        goalCompletionRate: viewModel.data.goalCompletionRate,
                        challengeStartDate: viewModel.data.challengeStartDate,
                        challengeEndDate: viewModel.data.challengeEndDate,
                        currentMember: viewModel.data.currentMember,
                        goal: viewModel.data.goal
                    )
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    
                    CalenderView(
                        currentMonth: Calendar.current.date(from: DateComponents(year: viewModel.year, month: viewModel.month))!,
                        startMonth: Calendar.current.date(from: DateComponents(year: viewModel.challenge.startYear, month: viewModel.challenge.startMonth))!,
                        endMonth: Calendar.current.date(from: DateComponents(year: viewModel.challenge.endYear, month: viewModel.challenge.endMonth))!,
                        certifiedCount: viewModel.data.certifiedCount,
                        certifiedMembers: viewModel.data.certifiedMembers
                    )
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct ChallengeStatisticsWrapper: View {
    @Environment(\.diContainer) private var container
    let challenge: ChallengeDetailResponse
    
    var body: some View {
        let viewModel = ChallengeStatisticsViewModel(challengeService: container.challengeService, challenge: challenge)
        ChallengeStatisticsView(viewModel: viewModel)
    }
}

#Preview {
}
