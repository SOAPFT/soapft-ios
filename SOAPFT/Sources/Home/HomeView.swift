//
//  Home.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI
import Lottie

struct Home: View {
    @StateObject var viewModel = HomeViewModel(useMock: true)
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack{
            //Nav 영역
            homeNavBar()
            
            Divider()
            
            ScrollView{
                LazyVStack {
                    //Lottie 영역
                    LottieView(filename: "Fire")  // Fire.json 파일 사용
                        .frame(width: 120,height: 90)
                        .padding(.top, 33)
                    Text("7")
                        .font(Font.Pretend.pretendardBold(size: 60))
                    Text("Challenges You've Completed")
                        .font(Font.Pretend.pretendardSemiBold(size: 15))
                        .padding(.bottom, 33)
                    
                    // Advertise
                    AdBannerView()
                        .padding(.vertical)
                    
                    //Toggle
                    HomeChallengeToggleView(selectedTab: $viewModel.selectedTab)
                        .padding()
                    
                    //챌린지 item
                    if viewModel.filteredChallenges.isEmpty { // 없는 경우
                        Image("NoneParticipateChallenge")
                            .padding()
                        Text("참여하는 챌린지가 없어요")
                            .font(Font.Pretend.pretendardSemiBold(size: 18))
                            .foregroundStyle(.gray)
                        
                        Text("챌린지에 참여해보세요!")
                            .font(Font.Pretend.pretendardLight(size: 15))
                            .foregroundStyle(.gray)
                            .padding(1)
                    }else{
                        // 챌린지 2열 목록
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.filteredChallenges) { challenge in
                                ChallengeItemView(challenge: challenge)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

#Preview {
    Home()
}
