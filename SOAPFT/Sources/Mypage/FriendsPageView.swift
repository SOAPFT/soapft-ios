//
//  FriendsPageView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/4/25.
//

import SwiftUI

struct FriendsPageView: View {
    
    private var notificationCount: Int = 3
    private var nickname: String = "Haru"
    private var postCount: Int = 12
    private var friendCount: Int = 4
    private var coinCount: Int = 39
    
    private var isFriend: Bool = false // 친구인가
    private var isSentFriendRequest: Bool = false // 요청을 보냈는 가
    private var isRecievedFriendRequest: Bool = false // 요청을 받았는 가
    private var buttonMessage: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단바 (고정)
            topBarView
            
            // 메인 스크롤 영역
            ScrollView {
                VStack(spacing: 0) {
                    // 프로필 섹션
                    profileSection
                    
                    // 탭 뷰 (스크롤 없이)
                    CustomTabView()
                }
            }
        }
    }
    
    // MARK: - 상단바 (고정)
    private var topBarView: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { }) {
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
                Circle()
                    .frame(width: 150)
                
                Text("\(nickname)")
                    .font(Font.Pretend.pretendardMedium(size: 24))
                
                HStack {
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            Text(friendButonText)
                                .font(Font.Pretend.pretendardSemiBold(size: 14))
                                .foregroundStyle((isFriend || isSentFriendRequest) ? Color.gray.opacity(0.8) : Color.white)
                        }
                        .frame(width: 110)
                        .padding(.vertical, 10)
                        .background((isFriend || isSentFriendRequest) ? Color.gray.opacity(0.2) : Color.orange01.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    })
                    
                    if isFriend {
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
                        Text("\(postCount)")
                            .font(Font.Pretend.pretendardRegular(size: 22))
                        Text("Posts")
                            .font(Font.Pretend.pretendardLight(size: 16))
                            .foregroundStyle(Color.gray.opacity(0.8))
                    }
                    
                    Spacer().frame(width: 35)
                    
                    VStack {
                        Text("\(friendCount)")
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
        if isFriend {
            return "친구 끊기"
        } else if isRecievedFriendRequest {
            return "친구 수락"
        } else if isSentFriendRequest {
            return "요청됨"
        } else {
            return "친구 신청"
        }
    }
}


#Preview {
    FriendsPageView()
}
