//
//  ChallengeSearchView.swift
//  SOAPFT
//
//  Created by 바견규 on 7/3/25.
//

import SwiftUI

struct ChallengeSearchView: View {
    @StateObject private var viewModel = ChallengeSearchViewModel()

    var body: some View {
        VStack {
            
            //상단 네비게이션 바
            ChallengeSearchNavBar()
            
            // 검색창
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("새로운 챌린지를 검색해 보세요", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)

            // 챌린지 리스트
            ScrollView {
                if viewModel.filteredChallenges.isEmpty {
                    Text("검색 결과가 없습니다.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.filteredChallenges) { challenge in
                            Button(action: {
                                // TODO: 나중에 상세화면 등으로 이동하는 로직 추가 예정
                            }) {
                                HStack(alignment: .top, spacing: 12) {
                                    AsyncImage(url: URL(string: challenge.challengeImageURL)) { phase in
                                        if let image = phase.image {
                                            image.resizable().scaledToFill()
                                        } else {
                                            Circle().fill(Color.gray.opacity(0.2))
                                        }
                                    }
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(challenge.title)
                                            .font(.headline)
                                        Text("챌린지 시작일: \(challenge.startDate) ~ 종료일: \(challenge.endDate)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle()) // 시스템 버튼 스타일 제거
                        }
                    }
                    .padding(.top, 10)
                }
            }
        }
    }
}

#Preview {
    ChallengeSearchView()
}
