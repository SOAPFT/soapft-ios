//
//  FriendsRequestView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/13/25.
//

import SwiftUI

struct FriendsRequestView: View {
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
                }

                Text("친구 요청")
                    .font(Font.Pretend.pretendardBold(size: 16))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            ScrollView {
                LazyVStack {
                    // MARK: 친구 검색
                    Text("요청 \(viewModel.receivedRequests.count)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 25)
                    
                    // MARK: 친구 리스트
                    VStack(spacing: 12) {
                        ForEach(viewModel.receivedRequests, id: \.requestId) {  friend in
                            Button(action: {
                                let accessToken = KeyChainManager.shared.read(forKey: "accessToken") ?? ""
                                if let currentUserUuid = viewModel.userUuid {
                                    container.router.push(.friendPage(
                                        userUUID: friend.requesterUuid,
                                        accessToken: accessToken,
                                        currentUserUuid: currentUserUuid   // ✅ 내 UUID 전달
                                    ))
                                } else {
                                    print("❌ 아직 내 UUID 로딩 전")
                                }
                            }) {
                                HStack(spacing: 12) {
                                    AsyncImage(url: URL(string: friend.profileImage ?? "")) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 48, height: 48)
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


                                    Text(friend.nickname)
                                        .font(Font.Pretend.pretendardRegular(size: 16))
                                        .foregroundStyle(Color.black)

                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.top, 12)
            }
        }
        .onAppear {
            viewModel.fetchRequestFriends()
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    FriendsRequestView()
}
