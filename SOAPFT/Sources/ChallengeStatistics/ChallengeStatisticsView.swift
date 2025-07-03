//
//  ChallengeStatisticsView.swift
//  SOAPFT
//
//  Created by 바견규 on 7/3/25.
//

import SwiftUI

struct ChallengeStatisticsView: View {
    @StateObject private var viewModel = ChallengeStatisticsViewModel()

    var body: some View {
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
                currentMonth: Calendar.current.date(from: DateComponents(year: 2024, month: 10))!,
                startMonth: Calendar.current.date(from: DateComponents(year: 2024, month: 9))!,
                endMonth: Calendar.current.date(from: DateComponents(year: 2024, month: 12))!,
                certifiedCount: viewModel.data.certifiedCount,
                certifiedMembers: viewModel.data.certifiedMembers
            )
        }
    }
}

#Preview {
    ChallengeStatisticsView()
}
