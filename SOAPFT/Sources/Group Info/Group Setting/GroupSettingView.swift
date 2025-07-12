//
//  GroupSettingView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/1/25.
//

import SwiftUI

struct GroupSettingView: View {
    @Environment(\.diContainer) private var container
    
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
            
            ScrollView {
                LazyVStack {
                    Button(action: {
                        container.router.push(.groupEdit)
                    }, label: {
                        HStack {
                            Text("내용 수정")
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
                        
                    }, label: {
                        HStack {
                            Text("그룹원 관리")
                                .font(Font.Pretend.pretendardLight(size: 17))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    })
                    
                    Divider()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    GroupSettingView()
}
