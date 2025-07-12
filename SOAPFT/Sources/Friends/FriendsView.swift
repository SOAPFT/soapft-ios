//
//  FriendsView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/12/25.
//

import SwiftUI
import Kingfisher

struct FriendsView: View {
    @StateObject var viewModel = FriendsViewModel()
    
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

                Text("친구 목록")
                    .font(Font.Pretend.pretendardBold(size: 16))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            ScrollView {
                LazyVStack {
                    // MARK: 친구 검색
                    VStack(alignment: .leading, spacing: 12) {
                        Text("친구 \(viewModel.friends.count)")
                            .font(.headline)

                        TextField("친구를 검색해주세요", text: $viewModel.searchText)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 25)
                    
                    // MARK: 친구 리스트
                    VStack(spacing: 12) {
                        ForEach(viewModel.filteredFriends, id: \.friendUuid) { friend in
                            HStack(spacing: 12) {
                                KFImage(URL(string: friend.profileImage))
                                    .resizable()
                                    .placeholder {
                                        ProgressView()
                                    }
                                    .cancelOnDisappear(true)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 48, height: 48)
                                    .clipShape(Circle())

                                Text(friend.nickname)

                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 12)
            }
        }
        .onAppear {
            viewModel.fetchFriends()
        }
    }
}

#Preview {
    FriendsView()
}
