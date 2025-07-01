//
//  MoreGroupView.swift
//  SOAPFT
//
//  Created by 홍지우 on 6/30/25.
//

import SwiftUI

struct MoreGroupView: View {
    @State private var viewModel = GroupMainViewModel()
    let viewType: GroupMainViewModel.ChallengeViewType
    
    // 2열 그리드
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // 상단바
                HStack {
                    Button(action: {
                        print("뒤로가기")
                    }, label: {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(Color.black)
                    })
                    
                    Spacer()
                    
                    Text(viewType.title)
                        .font(Font.Pretend.pretendardSemiBold(size: 16))
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // 스크롤뷰
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.getChallenges(for: viewType), id: \.id) { challenge in
                            ChallengeGridCard(challenge: challenge)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
            }
        }
    }
}

#Preview {
    MoreGroupView(viewType: .hot)
}
