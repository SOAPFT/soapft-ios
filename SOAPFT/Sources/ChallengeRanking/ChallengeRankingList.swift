//
//  Untitled.swift
//  SOAPFT
//
//  Created by 바견규 on 7/2/25.
//

import SwiftUI
import Kingfisher

struct ChallengeRankingListView: View {
    let others: [RankUser]

    var body: some View {
            LazyVStack(spacing: 0) {
                ForEach(others) { user in
                    HStack {
                        Text("\(user.rank)")
                            .frame(width: 30)
                            .font(Font.Pretend.pretendardRegular(size: 18))
                        
                        KFImage(URL(string: user.image))
                            .placeholder {
                                Circle().fill(Color.gray.opacity(0.3))
                                    .frame(width: 40, height: 40)
                            }
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        
                        Text(user.name)
                            .font(Font.Pretend.pretendardRegular(size: 18))
                        
                        Spacer()
                        
                        Text("\(user.score)")
                            .font(Font.Pretend.pretendardRegular(size: 14))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                
                // ScrollView 끝 여백
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 100)
            }
    }
}



