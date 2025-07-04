//
//  MyPageView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/3/25.
//

import SwiftUI

struct MyPageView: View {
    
    private var notificationCount: Int = 3
    private var nickname: String = "Jiwoo"
    private var postCount: Int = 12
    private var friendCount: Int = 4
    private var coinCount: Int = 39
    
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
            HStack(spacing: 12) {
                Spacer()
                
                ZStack {
                    Button(action: { }) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.black)
                            .font(.system(size: 18))
                    }
                    
                    if notificationCount > 0 {
                        Text("\(notificationCount)")
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 8, y: -8)
                    }
                }
                
                Button(action: { }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.black)
                        .font(.system(size: 18))
                }
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
            Spacer().frame(height: 8)
            
            HStack {
                Spacer()
                Image("coin")
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text("\(coinCount)")
                    .font(Font.Pretend.pretendardLight(size: 16))
                    .foregroundStyle(Color.black.opacity(0.8))
                Spacer().frame(width: 16)
            }
            
            Spacer().frame(height: 8)
            
            VStack(spacing: 20) {
                Circle()
                    .frame(width: 150)
                
                Text("\(nickname)")
                    .font(Font.Pretend.pretendardMedium(size: 24))
                
                Button(action: {
                    
                }, label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("소개 추가")
                            .font(Font.Pretend.pretendardSemiBold(size: 14))
                    }
                    .foregroundStyle(Color.gray.opacity(0.8))
                    .padding(.horizontal, 23)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                })
                
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
}

#Preview {
    MyPageView()
}
