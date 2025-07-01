//
//  GroupInfoView.swift
//  SOAPFT
//
//  Created by 바견규 on 6/30/25.
//

import SwiftUI
import Kingfisher

struct GroupInfoView: View {
    @ObservedObject var viewModel: GroupInfoViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: - 0. 네비게이션바
                GroupInfoNavBar()
                
                // MARK: - 1. 배너
                AsyncImage(url: URL(string: viewModel.challenge.banner)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 200)
                .clipped()

                // MARK: - 2. 제목 + 기본 정보
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.challenge.title)
                        .font(.title2.bold())

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            InfoRow(title: "기간", value: "\(viewModel.challenge.startDate) ~ \(viewModel.challenge.endDate)")
                            InfoRow(title: "목표", value: "주 \(viewModel.challenge.goal)회 활동")
                            InfoRow(title: "인원", value: "\(viewModel.challenge.currentMember)/\(viewModel.challenge.maxMember)명")
                            InfoRow(title: "성별", value: genderString(viewModel.challenge.gender))
                            InfoRow(title: "나이", value: "\(viewModel.challenge.startAge)세 ~ \(viewModel.challenge.endAge)세")
                        }
                    }
                }
                .padding(.horizontal)

                Divider()

                // MARK: - 3. 설명
                VStack(alignment: .leading, spacing: 8) {
                    Text("설명")
                        .font(.headline)
                    
                    Text(viewModel.challenge.introduce)
                        .font(Font.Pretend.pretendardLight(size: 14))
                    
                }
                .padding(.horizontal)

                Divider()

                
                // MARK: - 4. 방장 표시
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: viewModel.challenge.creator.profileImage)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Circle().fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())

                    Text(viewModel.challenge.creator.nickname)
                        .font(.headline)

                    Spacer()

                    Image(systemName: "crown.fill")
                        .foregroundStyle(.orange)
                }
                .padding(.horizontal)

                Divider()

                // MARK: - 5. 멤버 검색
                VStack(alignment: .leading, spacing: 8) {
                    Text("멤버 \(viewModel.challenge.participants.count)")
                        .font(.headline)

                    TextField("멤버를 검색해주세요", text: $viewModel.searchText)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .onChange(of: viewModel.searchText) { _, _ in
                            viewModel.filterMembers()
                        }
                }
                .padding(.horizontal)

                // MARK: - 6. 멤버 리스트
                VStack(spacing: 12) {
                    ForEach(viewModel.filteredParticipants, id: \.userUuid) { member in
                        HStack(spacing: 12) {
                            KFImage(URL(string: member.profileImage))
                                .resizable()
                                .placeholder {
                                    ProgressView()
                                }
                                .cancelOnDisappear(true)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())

                            Text(member.nickname)

                            if member.userUuid == viewModel.hostUuid {
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(.orange)
                            }

                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle("챌린지 정보")
        .navigationBarTitleDisplayMode(.inline)
    }

    func genderString(_ value: String) -> String {
        switch value {
        case "MALE": return "남성"
        case "FEMALE": return "여성"
        default: return "전체"
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.gray)
                .frame(width: 50, alignment: .leading)
            Text(value)
        }
    }
}


#Preview {
    GroupInfoView(viewModel: GroupInfoViewModel(challenge: GroupInfoMockData))
}
