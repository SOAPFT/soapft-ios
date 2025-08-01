//
//  MoreGroupView.swift
//  SOAPFT
//
//  Created by 홍지우 on 6/30/25.
//

import SwiftUI

struct MoreGroupView: View {
    @StateObject private var viewModel = GroupMainViewModel()
    let viewType: GroupMainViewModel.ChallengeViewType
    @Environment(\.diContainer) private var container
    
    // 2열 그리드
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단바
            HStack {
                Button(action: {
                    container.router.pop()
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
                    ForEach(viewModel.getChallenges(for: viewType), id: \.self) { challenge in
                        Button(action: {
                            if challenge.isParticipated ?? false {
                                container.router.push(.GroupTabbar(ChallengeID: challenge.challengeUuid))
                            } else {
                                container.router.push(.challengeSignUpWrapper   (ChallengeID: challenge.challengeUuid))
                            }
                        }) {
                            ChallengeGridCard(Name: challenge.banner ?? "", Title: challenge.title)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear() {
            loadChallenges(for: viewType)
        }
    }
    
    private func ChallengeGridCard(Name: String, Title: String) -> some View {
        VStack {
            if let url = URL(string: Name), !Name.isEmpty {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                        )
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .clipped()
                .cornerRadius(12)
            } else {
                // fallback 이미지 또는 기본 색상
                ZStack {
                    Color.gray.opacity(0.3)
                    Image(systemName: "photo")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .cornerRadius(8)
            }

            HStack {
                Text(Title)
                    .font(Font.Pretend.pretendardLight(size: 12))
                    .foregroundStyle(Color.black)
                    .frame(width: 100, height: 30, alignment: .leading)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
        }
    }
    
    private func loadChallenges(for type: GroupMainViewModel.ChallengeViewType) {
        switch type {
        case .hot:
            viewModel.fetchHotChallenges()
        case .recent:
            viewModel.fetchRecentChallenges()
        case .event:
            return
        }
    }
}

#Preview {
    MoreGroupView(viewType: .recent)
}
