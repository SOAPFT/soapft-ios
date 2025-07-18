//
//  ChallengeSearchView.swift
//  SOAPFT
//
//  Created by 바견규 on 7/3/25.
//

import SwiftUI

struct ChallengeSearchWrapper: View {
    @Environment(\.diContainer) private var container
    
    var body: some View {
        let viewModel = ChallengeSearchViewModel(challengeService: container.challengeService)
        ChallengeSearchView(viewModel: viewModel)
    }
}


struct ChallengeSearchView: View {
    @StateObject var viewModel: ChallengeSearchViewModel

    var body: some View {
        VStack {
            ChallengeSearchNavBar()

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)

                TextField("새로운 챌린지를 검색해 보세요", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)

            ScrollView {
                if viewModel.filteredChallenges.isEmpty {
                    Text("검색 결과가 없습니다.")
                        .foregroundStyle(.gray)
                        .padding()
                } else {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.filteredChallenges, id: \.challengeUuid) { challenge in
                            ChallengeRowView(challenge: challenge)
                        }
                    }
                    .padding(.top, 10)
                }
            }
            .onAppear { // 가입 후 동기화
                let keyword = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                if !keyword.isEmpty {
                    viewModel.fetchSearchChallenges(keyword: keyword)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct ChallengeRowView: View {
    let challenge: Challenge
    @Environment(\.diContainer) private var container
    
    var body: some View {
        if challenge.isParticipated ?? false {
            Button(action: {container.router.push(.GroupTabbar(ChallengeID: challenge.challengeUuid))}) {
                HStack(alignment: .top, spacing: 12) {
                    AsyncImage(url: URL(string: challenge.profile ?? "")) { phase in
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
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray)
                        .font(.caption)
                }
                .padding(.horizontal)
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            Button(action: {container.router.push(.challengeSignUpWrapper   (ChallengeID: challenge.challengeUuid))}) {
                HStack(alignment: .top, spacing: 12) {
                    AsyncImage(url: URL(string: challenge.profile ?? "")) { phase in
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
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray)
                        .font(.caption)
                }
                .padding(.horizontal)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}


#Preview {
    
}
