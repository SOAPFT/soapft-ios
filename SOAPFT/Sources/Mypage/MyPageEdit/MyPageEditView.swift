//
//  MyPageEditView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/5/25.
//

import SwiftUI

struct MyPageEditView: View {
    @Environment(\.diContainer) private var container
    
    @State private var showActionSheet = false
    
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
                
                Text("설정")
                    .font(Font.Pretend.pretendardBold(size: 16))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            VStack {
                Button(action: {
                    container.router.push(.mypageEditInfo)
                }, label: {
                    HStack {
                        Text("프로필 수정")
                            .font(Font.Pretend.pretendardLight(size: 17))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                })
                
                Divider()
                
                Spacer()
                
                Button(action: {
                    withAnimation{
                        showActionSheet = true
                    }
                }) {
                    Text("로그아웃")
                        .font(Font.Pretend.pretendardLight(size: 16))
                        .foregroundStyle(Color.orange01)
                }
                .padding(.bottom, 20)
            }
        }
        .confirmationDialog("로그아웃을 하시겠습니까?", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("로그아웃 하기", role: .destructive) {
                print("로그아웃 버튼 클릭")
                logout()
            }

            Button("취소", role: .cancel) { print("로그아웃 취소") }
        }
        .navigationBarBackButtonHidden()
    }
    
    private func logout() {
        guard let accessToken = KeyChainManager.shared.readAccessToken() else {
            print("❌ 토큰 없음")
            return
        }
        
        container.userService.logout(accessToken: accessToken) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ 로그아웃 성공: \(response.message)")
                    
                    // 토큰 삭제
                    KeyChainManager.shared.delete(forKey: "jwtToken")
                    KeyChainManager.shared.delete(forKey: "refreshToken")
                    
                    // 라우터 초기화 및 로그인화면으로 이동 (예시)
                    container.router.reset()
                    container.router.push(.login) // 로그인 뷰로 보내도 됨
                    
                case .failure(let error):
                    print("❌ 로그아웃 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    MyPageEditView()
}
