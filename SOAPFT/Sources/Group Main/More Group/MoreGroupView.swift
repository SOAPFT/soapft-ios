//
//  MoreGroupView.swift
//  SOAPFT
//
//  Created by 홍지우 on 6/30/25.
//

import SwiftUI
import Kingfisher

struct MoreGroupView: View {
    @StateObject private var viewModel = GroupMainViewModel()
    let viewType: GroupMainViewModel.ChallengeViewType
    @Environment(\.diContainer) private var container
    
    // 2열 그리드 - 간격 조정
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단바 - 터치 영역 개선
            HStack {
                Button(action: {
                    container.router.pop()
                }, label: {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(Color.black)
                        .font(.system(size: 18))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                })
                
                Spacer()
                
                Text(viewType.title)
                    .font(Font.Pretend.pretendardSemiBold(size: 16))
                
                Spacer()
                
                // 오른쪽 균형을 위한 투명한 뷰
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // 스크롤뷰
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.getChallenges(for: viewType), id: \.self) { challenge in
                        Button(action: {
                            if challenge.isParticipated ?? false {
                                container.router.push(.GroupTabbar(ChallengeID: challenge.challengeUuid ?? ""))
                            } else {
                                container.router.push(.challengeSignUpWrapper(ChallengeID: challenge.challengeUuid ?? ""))
                            }
                        }) {
                            ChallengeGridCard(Name: challenge.banner ?? "", Title: challenge.title)
                        }
                        .contentShape(Rectangle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear() {
            loadChallenges(for: viewType)
        }
    }
    
    private func ChallengeGridCard(Name: String, Title: String) -> some View {
        VStack(spacing: 12) {
            // 이미지 영역 - 아이패드 최적화
            ZStack {
                if !Name.isEmpty, let url = URL(string: Name) {
                    // Kingfisher 이미지 - aspectRatio로 비율 유지하면서 채우기
                    KFImage(url)
                        .placeholder {
                            // 로딩 중 표시
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    VStack(spacing: 4) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                            .scaleEffect(0.7)
                                        
                                        Text("로딩 중...")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                )
                        }
                        .onFailure { error in
                            print("❌ 이미지 로딩 실패: \(Name)")
                        }
                        .fade(duration: 0.2)
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fill) // 1:1 비율로 채우기
                        .frame(height: 140)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.gray.opacity(0.5), lineWidth: 0.8)
                        )
                } else {
                    // 빈 URL일 때 fallback
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                                .font(.title2)
                        )
                        .frame(height: 140)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.gray.opacity(0.5), lineWidth: 0.8)
                        )
                }
            }

            // 제목 텍스트
            Text(Title)
                .font(Font.Pretend.pretendardLight(size: 14)) // 폰트 크기 약간 증가
                .foregroundStyle(Color.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 40) // 최소 높이로 변경
        }
        .padding(12) // 카드 내부 패딩 증가
        .background(Color.white) // 카드 배경
        .cornerRadius(16) // 카드 전체 모서리
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.gray.opacity(0.3), lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // 그림자 효과
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
