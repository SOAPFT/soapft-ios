//
//  MyPageView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/3/25.
//

import SwiftUI
import Kingfisher

struct MyPageView: View {
    @Environment(\.diContainer) private var container
    @StateObject private var viewModel: MyPageViewModel
    @State private var showingPayment = false
    @State private var showingGifticon = false
    
    init() {
        _viewModel = StateObject(wrappedValue: MyPageViewModel(container: DIContainer(router: AppRouter())))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단바 (고정)
            topBarView
            
            // 메인 스크롤 영역
            ScrollView {
                VStack(spacing: 24) {
                    // 프로필 섹션
                    profileSection
                    
                    // 코인 카드 섹션
                    coinCardSection
                    
                    // 탭 뷰 (스크롤 없이)
                    CustomTabView()
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear() {
            viewModel.container = container
            viewModel.fetchUserProfile()
            viewModel.fetchNotificationCount()
        }
        .fullScreenCover(isPresented: $showingPayment) {
            CoinInputView { purchasedCoins in
                viewModel.fetchUserProfile()
            }
        }
        .fullScreenCover(isPresented: $showingGifticon, onDismiss: {
            viewModel.fetchUserProfile()
        }) {
            GifticonShopView(userCoins: viewModel.coins)
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
        VStack(spacing: 20) {
            Spacer().frame(height: 20)
            
            // 프로필 이미지
            ZStack {
                if let userImage = viewModel.userImage, !userImage.isEmpty {
                    KFImage(URL(string: userImage))
                        .placeholder {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "person")
                                        .foregroundColor(.white)
                                        .font(.system(size: 40))
                                )
                        }
                        .onFailure { error in
                            print("프로필 이미지 로드 실패: \(error)")
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white, lineWidth: 4)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "person")
                                .foregroundColor(.white)
                                .font(.system(size: 40))
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white, lineWidth: 4)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
            }
            
            // 이름
            Text(viewModel.userName.isEmpty ? "이름 없음" : viewModel.userName)
                .font(Font.Pretend.pretendardMedium(size: 24))
                .foregroundColor(.black)
            
            // 소개
            if (viewModel.userIntroduction ?? "").isEmpty {
                Button(action: {
                    container.router.push(.mypageEditInfo)
                }, label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12))
                        Text("소개 추가")
                            .font(Font.Pretend.pretendardMedium(size: 14))
                    }
                    .foregroundStyle(Color.gray.opacity(0.8))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.15))
                    )
                })
                .contentShape(Rectangle())
            } else {
                Text(viewModel.userIntroduction ?? "")
                    .font(Font.Pretend.pretendardLight(size: 16))
                    .foregroundStyle(Color.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // 통계 정보
            HStack(spacing: 50) {
                VStack(spacing: 4) {
                    Text("\(viewModel.postCount)")
                        .font(Font.Pretend.pretendardSemiBold(size: 22))
                        .foregroundColor(.black)
                    Text("Posts")
                        .font(Font.Pretend.pretendardLight(size: 14))
                        .foregroundStyle(Color.gray.opacity(0.8))
                }
                
                Button(action: {
                        container.router.push(.friend)
                    }) {
                    VStack {
                        Text("\(viewModel.friendCount)")
                            .font(Font.Pretend.pretendardRegular(size: 22))
                            .foregroundStyle(Color.black)
                        Text("Friends")
                            .font(Font.Pretend.pretendardLight(size: 16))
                            .foregroundStyle(Color.gray.opacity(0.8))
                    }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 코인 카드 섹션
    private var coinCardSection: some View {
        VStack(spacing: 16) {
            // 코인 보유량 카드
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text("보유 코인")
                            .font(Font.Pretend.pretendardMedium(size: 16))
                            .foregroundColor(.gray)
                    }
                    
                    Text("\(viewModel.coins)")
                        .font(Font.Pretend.pretendardBold(size: 28))
                        .foregroundColor(.orange02)
                }
                
                Spacer()
                
                // 코인 아이콘 장식
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange02.opacity(0.2), Color.orange02.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image("coin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            )
            
            // 코인 교환 버튼
            Button(action: {
                showingGifticon = true
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "gift")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("기프티콘 교환")
                            .font(Font.Pretend.pretendardSemiBold(size: 18))
                            .foregroundColor(.white)
                        
                        Text("코인으로 다양한 상품을 받아보세요")
                            .font(Font.Pretend.pretendardRegular(size: 13))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.orange02,
                                    Color.orange02.opacity(0.8),
                                    Color.orange.opacity(0.9)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.orange02.opacity(0.4), radius: 12, x: 0, y: 6)
                )
            }
            .contentShape(Rectangle())
            .scaleEffect(showingGifticon ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: showingGifticon)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 커스텀 버튼 스타일
struct PaymentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    MyPageView()
}
