//
//  MyPageEditView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/5/25.
//

import SwiftUI

struct MyPageEditView: View {
    @Environment(\.diContainer) private var container
    @StateObject private var viewModel: MyPageViewModel
    
    @State private var showActionSheet = false
    @State private var WithdrawalShowActionSheet = false
    @State private var isOn1 = false
    
    @State private var isDeleting = false
    @State private var deleteError: String?
    
    init() {
        _viewModel = StateObject(wrappedValue: MyPageViewModel(container: DIContainer(router: AppRouter())))
    }
    
    var body: some View {
        ZStack {
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
                    
                    Button(action: {
                        withAnimation { WithdrawalShowActionSheet = true }
                    }, label: {
                        HStack {
                            Text("회원 탈퇴")
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
            
            if WithdrawalShowActionSheet {
                ZStack{
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                    
                    VStack(alignment: .center, spacing: 22) {
                        Text("정말 탈퇴하시겠습니까?")
                            .font(Font.Pretend.pretendardSemiBold(size: 20))
                            .foregroundStyle(Color.black)
                        
                        VStack(spacing: 16) {
                            VStack(spacing: 2) {
                                Text("탈퇴하기 클릭 시 바로 탈퇴 처리 됩니다.")
                                Text("탈퇴 후 재가입이 불가합니다.")
                            }
                            .font(Font.Pretend.pretendardMedium(size: 16))
                            .foregroundStyle(Color.black.opacity(0.7))
                            
                            //체크박스
                            Toggle("위 내용을 이해했습니다.", isOn: $isOn1)
                                .toggleStyle(CheckboxToggleStyle(style: .square))
                                .font(Font.Pretend.pretendardMedium(size: 15))
                                .foregroundStyle(Color.black.opacity(0.6))
                            
                            VStack(spacing: 8) {
                                Button(action: {
                                    WithdrawalShowActionSheet = false
                                    isOn1 = false
                                    deleteError = nil
                                }) {
                                    Text("취소하기")
                                        .font(Font.Pretend.pretendardSemiBold(size: 15))
                                        .foregroundStyle(Color.white)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundStyle(Color.orange01)
                                )
                                
                                if let deleteError {
                                    Text(deleteError)
                                        .font(Font.Pretend.pretendardLight(size: 13))
                                        .foregroundStyle(.red)
                                }
                                Button(action: performDelete) {
                                    Text(isDeleting ? "탈퇴 중..." : "탈퇴하기")
                                        .underline()
                                        .font(Font.Pretend.pretendardLight(size: 14))
                                        .foregroundStyle(isOn1 ? Color.gray : Color.gray.opacity(0.6))
                                }
                                .disabled(!isOn1 || isDeleting)
                            }
                        }
                    }
                    .padding(.vertical, 26)
                    .padding(.horizontal, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(Color.white)
                    )
                }
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
    
    
    func performDelete() {
        guard isOn1, !isDeleting else { return } // 체크박스, 중복 클릭 방지
        isDeleting = true
        deleteError = nil
        viewModel.deleteProfile { ok, msg in
            isDeleting = false
            if ok {
                container.router.reset()
                container.router.push(.login)
            } else {
                deleteError = msg ?? "일시적인 오류가 발생했습니다. 잠시 후 다시 시도해 주세요."
            }
            WithdrawalShowActionSheet = !ok // 실패 시 모달 유지
        }
    }
}

#Preview {
    MyPageEditView()
}
