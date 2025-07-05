//
//  MyPageEditView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/5/25.
//

import SwiftUI

struct MyPageEditView: View {
    @State private var showActionSheet = false
    
    var body: some View {
        VStack {
            // 상단바
            ZStack {
                HStack {
                    Button(action: {
                        
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
                
            }

            Button("취소", role: .cancel) {}
        }
    }
}

#Preview {
    MyPageEditView()
}
