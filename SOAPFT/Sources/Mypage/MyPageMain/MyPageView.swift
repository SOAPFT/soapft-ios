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
        .fullScreenCover(isPresented: $showingPayment) {
            CoinInputView { purchasedCoins in
                // 코인 구매 완료 후 처리
                viewModel.fetchUserProfile()
                // 또는 viewModel.fetchUserProfile() 호출하여 최신 코인 정보 업데이트
            }
        }
        .fullScreenCover(isPresented: $showingGifticon, onDismiss: {
            // 기프티콘 쇼핑 화면이 닫힐 때마다 사용자 정보 새로고침
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
            
            /*
            HStack{
                Spacer()
                // 결제 버튼
                Button(action: {
                    showingPayment = true
                }) {
                    HStack(spacing: 8) {
                        
                        Text("코인 충전")
                            .font(Font.Pretend.pretendardMedium(size: 16))
                    }
                    .foregroundColor(.white)
                    .padding(5)
                    .background(
                        LinearGradient(
                            colors: [Color.orange02, Color.orange02.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)
                .buttonStyle(PaymentButtonStyle())
                 
            }
            */
            
            HStack{
                Spacer()
                // 결제 버튼
                Button(action: {
                    showingGifticon = true
                }) {
                    HStack(spacing: 8) {
                        
                        Text("코인 교환")
                            .font(Font.Pretend.pretendardMedium(size: 12))
                    }
                    .foregroundColor(.white)
                    .padding(5)
                    .background(
                        LinearGradient(
                            colors: [Color.orange02, Color.orange02.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
                    .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)
                .buttonStyle(PaymentButtonStyle())
                 
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
