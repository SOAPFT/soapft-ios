//
//  FriendsView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/12/25.
//

import SwiftUI

struct FriendsView: View {
    @Environment(\.diContainer) private var container
    @StateObject var viewModel = FriendsViewModel()
    
    var body: some View {
        VStack {
            // 상단바
            ZStack {
                HStack {
                    Button(action: {
                        container.router.pop()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 18))
                    }
                    Spacer()
                    Button(action: {
                        container.router.push(.friendsRequest)
                    }) {
                        Image(systemName: "person.2.badge.plus")
                            .foregroundColor(.black)
                            .font(.system(size: 18))
                    }
                }

                Text("친구 목록")
                    .font(Font.Pretend.pretendardBold(size: 16))
            }
            .padding(.horizontal, 16)
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
                    VStack(alignment: .leading, spacing: 18) {
                        if !viewModel.searchText.isEmpty {
                            // MARK: 검색된 유저 리스트 (친구 아님)
                            if !viewModel.filteredFriends.isEmpty {
                                Text("검색 결과")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(viewModel.filteredFriends, id: \.userUuid) { user in
//                                    userRow(user: user)
                                    userRow(user: SearchedFriend(
                                        userUuid: user.userUuid,
                                        nickname: user.nickname,
                                        profileImage: user.profileImage,
                                        isFriend: user.isFriend
                                    ))
                                }
                            } else {
                                Text("검색 결과가 없습니다.")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            }
                        }

                        // MARK: 기존 친구 리스트
                        if !viewModel.friends.isEmpty {
                            Text("친구 목록")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(viewModel.friends, id: \.friendUuid) { friend in
                                userRow(user: SearchedFriend(
                                    userUuid: friend.friendUuid,
                                    nickname: friend.nickname ?? "알 수 없음",
                                    profileImage: friend.profileImage ?? "",
                                    isFriend: true
                                ))
                            }
                        }
                    }

                }
                .padding(.top, 12)
            }
        }
        .onAppear {
            viewModel.fetchFriends()
        }
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder
    private func userRow(user: SearchedFriend) -> some View {
        Button(action: {
            let token = KeyChainManager.shared.read(forKey: "accessToken") ?? ""
            container.router.push(.friendPage(userUUID: user.userUuid, accessToken: token, currentUserUuid: user.userUuid))
        }) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: user.profileImage)) { phase in
                    switch phase {
                    case .empty:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.gray)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                    case .failure(_):
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.gray)
                    @unknown default:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.gray)
                    }
                }

                Text(user.nickname)
                    .font(Font.Pretend.pretendardRegular(size: 16))
                    .foregroundStyle(.black)

                Spacer()

                if user.isFriend {
                    Text("친구")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
        }
    }

}

#Preview {
    FriendsView()
}

