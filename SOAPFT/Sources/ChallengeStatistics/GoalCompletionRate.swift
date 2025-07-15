//
//  GoalCompletionRateView.swift
//  SOAPFT
//
//  Created by 바견규 on 7/3/25.
//

import SwiftUI

struct GoalCompletionRate: View {
    private let goalCompletionRate: Int
    private let challengeStartDate: String
    private let challengeEndDate: String
    private let currentMember: Int
    private let goal:Int
    
    init(goalCompletionRate: Int, challengeStartDate: String,challengeEndDate: String, currentMember: Int, goal:Int) {
        self.goalCompletionRate = goalCompletionRate
        self.challengeStartDate = challengeStartDate
        self.challengeEndDate = challengeEndDate
        self.currentMember = currentMember
        self.goal = goal
    }
    
    var body: some View {
        VStack{
            //목표 달성률 텍스트, lottie
            HStack{
                (
                    Text("어제까지 당신의\n목표 달성률은 ")
                        .font(Font.Pretend.pretendardRegular(size: 18)) +
                    Text("\(goalCompletionRate)%")
                        .bold() +
                    Text(" 예요.")
                        .font(Font.Pretend.pretendardRegular(size: 18))
                )
                .multilineTextAlignment(.leading)
                Spacer()
                LottieView(filename: "Fire")  // Fire.json 파일 사용
                    .frame(width: 80,height: 60)
            }
            .padding(.horizontal)
            
            //목표
            HStack{
                Text("목표")
                    .font(.system(size: 14))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.gray.opacity(0.2))
                    .foregroundStyle(.black)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                Text("주 \(goal)회 인증")
                    .font(Font.Pretend.pretendardLight(size: 16))
                
                Spacer()
                
                Image(systemName:"person.3.sequence.fill")
                    .font(.system(size: 14))
                Text("\(currentMember)명 도전 중")
                    .font(Font.Pretend.pretendardRegular(size: 14))
            }
            .padding()
            
            HStack{
                Image(systemName:"calendar")
                    .font(.system(size: 14))
                Text("\(formatDateRange(start:challengeStartDate,end:challengeEndDate))")
                    .font(Font.Pretend.pretendardLight(size: 14))
                
                Spacer()
                
            
            }
            .padding(.horizontal)
            
            HStack {
                StripedProgressBar(progress: Double(goalCompletionRate) * 0.01)
                Text("\(goalCompletionRate)%")
            }
            .padding(.horizontal)

        }
        .padding()
        .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.3))
        )
        
    }
    
    // MARK: - 날짜 포맷 변경
    func formatDateRange(start: String, end: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "ko_KR")
        displayFormatter.dateFormat = "yyyy년 M월 d일"

        if let startDate = formatter.date(from: start),
           let endDate = formatter.date(from: end) {
            let startStr = displayFormatter.string(from: startDate)
            let endStr = displayFormatter.string(from: endDate)
            return "\(startStr) ~ \(endStr)"
        } else {
            return "날짜 형식 오류"
        }
    }
}

#Preview {
    GoalCompletionRate(goalCompletionRate:40, challengeStartDate: "2025-07-01", challengeEndDate: "2025-07-31" , currentMember: 30, goal: 1)
}
