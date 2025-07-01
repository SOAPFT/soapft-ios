//
//  SwiftUIView.swift
//  SOAPFT
//
//  Created by 바견규 on 7/2/25.
//

import SwiftUI


struct ChallengeRankingView: View {
    let myRank = RankUser(rank: 28, name: "챌린저 이름", image: "https://i.pravatar.cc/100?img=12", score: "12,345")
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ChallengeRankingNavBar(ChallengeName: "걷기 챌린지")
                ScrollView {
                    ChallengeTop3PodiumView()
                    ChallengeRankingListView()
                        .padding(.bottom, 100)
                }
                Spacer()
            }
            
            
            
            //나의 기록(하단 고정)
            VStack {
                Spacer() // 👈 맨 아래로 밀어내기
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("나의 기록")
                            .font(Font.Pretend.pretendardBold(size: 18))
                            .foregroundStyle(Color.orange01)
                        
                        Spacer()
                        
                        Button(action: {
                            // 인증하기 액션
                        }) {
                            Text("지금 인증하기")
                                .font(Font.Pretend.pretendardSemiBold(size: 14))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Color.orange01)
                                .cornerRadius(12)
                        }
                    }
                        
                        HStack(spacing: 4) {
                            Text("\(myRank.rank)")
                                .font(Font.Pretend.pretendardSemiBold(size: 16))
                            Text(myRank.name)
                                .font(Font.Pretend.pretendardSemiBold(size: 16))
                            
                            Spacer()
                            
                            Text("\(myRank.score) 보")
                                .font(Font.Pretend.pretendardSemiBold(size: 16))
                        }
                    
                    
                    
                   
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.85))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
                )
                .padding(.horizontal)
                .padding(.bottom, 10) // 안전하게 하단 여백
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}


#Preview {
    ChallengeRankingView()
}
