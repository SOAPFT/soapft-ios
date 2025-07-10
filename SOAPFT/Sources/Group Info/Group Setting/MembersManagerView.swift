//
//  MembersManagerView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/2/25.
//

import SwiftUI
import Kingfisher

struct MembersManagerView: View {
    @ObservedObject var viewModel: GroupInfoViewModel
    
    var body: some View {
        VStack {
            // 상단바
            ZStack {
                HStack {
                    Button(action: { }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 18))
                    }
                    Spacer()
                }

                Text("그룹원 관리")
                    .font(Font.Pretend.pretendardBold(size: 16))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            ScrollView {
                LazyVStack {
                    // MARK: 멤버 검색
                    VStack(alignment: .leading, spacing: 12) {
                        Text("멤버 \(viewModel.challenge.participantUuid.count)")
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
                    
                    Spacer().frame(height: 25)
                    
                    // MARK: 멤버 리스트
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
                                        .foregroundColor(.orange)
                                }

                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 12)
            }
        }
    }
}

#Preview {
    //MembersManagerView(viewModel: GroupInfoViewModel(challenge: GroupInfoMockData))
}
