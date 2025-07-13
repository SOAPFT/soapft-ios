//
//  FriendsPageView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/4/25.
//

import SwiftUI

struct FriendsPageView: View {
    @Environment(\.diContainer) private var container
    @StateObject private var viewModel: FriendsPageViewModel
        
    init(userUUID: String, accessToken: String) {
        _viewModel = StateObject(wrappedValue: FriendsPageViewModel(userUUID: userUUID, accessToken: accessToken))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단바 (고정)
            topBarView
            
            // 메인 스크롤 영역
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                ProgressView()
                Text(error)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // 프로필 섹션
                        profileSection
                        
                        // 탭 뷰 (스크롤 없이)
                        FriendsCustomTabView(userUUID: viewModel.userUUID)
                    }
                }
            }
        }
        .onAppear() {
            viewModel.fetchOtherUserInfo()
        }
        .navigationBarBackButtonHidden()
    }
    
    // MARK: - 상단바 (고정)
    private var topBarView: some View {
        VStack(spacing: 0) {
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
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            
            Divider()
                .background(Color.gray.opacity(0.3))
        }
    }
    
    // MARK: - 프로필 섹션
    private var profileSection: some View {
        VStack {
            Spacer().frame(height: 20)
            
            VStack(spacing: 20) {
                let trimmedImage = viewModel.userImage.trimmingCharacters(in: .whitespaces)
                
                if !trimmedImage.isEmpty, let imageUrl = URL(string: trimmedImage) {
                    AsyncImage(url: imageUrl) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .foregroundStyle(Color.gray)
                    }
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .foregroundStyle(Color.gray)
                }
                
                Text(viewModel.nickname)
                    .font(Font.Pretend.pretendardMedium(size: 24))
                
                HStack {
                    Button(action: {
                        handleFriendButtonTap()
                    }, label: {
                        HStack {
                            Text(friendButonText)
                                .font(Font.Pretend.pretendardSemiBold(size: 14))
                                .foregroundStyle((viewModel.isFriend || viewModel.isSentFriendRequest) ? Color.gray.opacity(0.8) : Color.white)
                        }
                        .frame(width: 110)
                        .padding(.vertical, 10)
                        .background((viewModel.isFriend || viewModel.isSentFriendRequest) ? Color.gray.opacity(0.2) : Color.orange01.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    })
                    
                    if viewModel.isFriend {
                        Spacer()
                        Button(action: {
                            
                        }, label: {
                            HStack {
                                Text("메시지 보내기")
                                    .font(Font.Pretend.pretendardSemiBold(size: 14))
                                    .foregroundStyle( Color.gray.opacity(0.8))
                            }
                            .frame(width: 110)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        })
                    }
                }
                .padding(.horizontal, 50)
                
                HStack {
                    VStack {
                        Text("\(viewModel.postCount)")
                            .font(Font.Pretend.pretendardRegular(size: 22))
                        Text("Posts")
                            .font(Font.Pretend.pretendardLight(size: 16))
                            .foregroundStyle(Color.gray.opacity(0.8))
                    }
                    
                    Spacer().frame(width: 35)
                    
                    VStack {
                        Text("\(viewModel.friendCount)")
                            .font(Font.Pretend.pretendardRegular(size: 22))
                        Text("Friends")
                            .font(Font.Pretend.pretendardLight(size: 16))
                            .foregroundStyle(Color.gray.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 12)
            
            Spacer().frame(height: 30)
        }
    }
    
    private var friendButonText: String {
        if viewModel.isFriend {
            return "친구 끊기"
        } else if viewModel.isRecievedFriendRequest {
            return "친구 수락"
        } else if viewModel.isSentFriendRequest {
            return "요청됨"
        } else {
            return "친구 신청"
        }
    }
    
    private func handleFriendButtonTap() {
        if viewModel.isFriend {
            viewModel.deleteFriend()
        } else if viewModel.isRecievedFriendRequest {
            viewModel.acceptFriendRequest()
        } else if !viewModel.isSentFriendRequest {
            viewModel.sendFriendRequest()
        }
        // 요청됨 상태일 때는 아무 것도 안 함
    }
}


//#Preview {
//    FriendsPageView()
//}
