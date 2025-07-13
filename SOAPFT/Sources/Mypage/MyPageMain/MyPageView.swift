//
//  MyPageView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/3/25.
//

import SwiftUI

struct MyPageView: View {
    @Environment(\.diContainer) private var container
    @StateObject private var viewModel: MyPageViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: MyPageViewModel(container: DIContainer(router: AppRouter())))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단바 (고정)
            topBarView
            
            // 메인 스크롤 영역
            ScrollView {
                VStack {
                    // 프로필 섹션
                    profileSection
                    
                    // 탭 뷰 (스크롤 없이)
                    CustomTabView()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear() {
            viewModel.container = container
            viewModel.fetchUserProfile()
            viewModel.fetchNotificationCount()
        }
    }
    
    // MARK: - 상단바 (고정)
    private var topBarView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Spacer()
                
                ZStack {
                    Button(action: {
                        container.router.push(.alert)
                    }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")
                                .foregroundStyle(Color.black)
                                .font(.system(size: 18))

                            if viewModel.notificationCount > 0 {
                                Text("\(viewModel.notificationCount)")
                                    .font(.caption2)
                                    .foregroundStyle(.white)
                                    .padding(5)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
                
                Button(action: {
                    container.router.push(.mypageEdit)
                }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.black)
                        .font(.system(size: 18))
                }
            }
            .padding()
            
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
                
                Text("\(viewModel.coins)")
                    .font(Font.Pretend.pretendardLight(size: 16))
                    .foregroundStyle(Color.black.opacity(0.8))
                Spacer().frame(width: 16)
            }
            
            Spacer().frame(height: 8)
            
            VStack(spacing: 18) {
                if let userImage = viewModel.userImage, !userImage.isEmpty {
                    AsyncImage(url: URL(string: userImage)) { image in
                        image.resizable()
                    } placeholder: {
//                        Circle().foregroundStyle(Color.gray.opacity(0.3))
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
                
                Text(viewModel.userName.isEmpty ? "이름 없음" : viewModel.userName)
                    .font(Font.Pretend.pretendardMedium(size: 24))
                
                if (viewModel.userIntroduction ?? "").isEmpty {
                    Button(action: {
                        container.router.push(.mypageEditInfo)
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
                } else {
                    Text(viewModel.userIntroduction ?? "")
                        .font(Font.Pretend.pretendardLight(size: 16))
                        .foregroundStyle(Color.gray.opacity(0.8))
                }
                
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
}

#Preview {
    MyPageView()
}
