//
//  GroupCreateNextView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/1/25.
//

import SwiftUI
import PhotosUI

struct GroupCreateNextView: View {
    @State private var selectedProfileImage: UIImage?
    @State private var selectedProfileItem: PhotosPickerItem?
    @State private var selectedBannerImage: UIImage?
    @State private var selectedBannerItem: PhotosPickerItem?
    @State private var showPopUp: Bool = false
    
    private var isFormValid: Bool {
        selectedProfileItem != nil && selectedBannerItem != nil
    }
    
    var body: some View {
        ZStack {
            VStack {
                // 상단바
                ZStack {
                    HStack {
                        Button(action: { }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .font(.system(size: 18))
                        }
                        Spacer()
                    }
                    
                    Text("그룹 생성")
                        .font(Font.Pretend.pretendardBold(size: 16))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                ScrollView {
                    LazyVStack {
                        // 프로필 이미지 업로드
                        HStack {
                            Text("프로필 이미지 선택")
                                .font(Font.Pretend.pretendardMedium(size: 16))
                            Spacer()
                        }
                        
                        Spacer().frame(height: 10)
                        
                        PhotosPicker(selection: $selectedProfileItem, matching: .images) {
                            ZStack {
                                if let image = selectedProfileImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 300)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    Rectangle()
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                        .foregroundStyle(Color.gray)
                                        .frame(height: 250)
                                    VStack {
                                        Image(systemName: "camera")
                                            .font(.system(size:30))
                                            .foregroundStyle(Color.gray)
                                        Text("사진을 업로드하세요")
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                            }
                        }
                        .onChange(of: selectedProfileItem) { oldItem, newItem in
                            Task {
                                if let data = try? await
                                    newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    selectedProfileImage = uiImage
                                }
                            }
                        }
                        
                        Spacer().frame(height: 35)
                        
                        // 배너 이미지 업로드
                        HStack {
                            Text("배너 이미지 선택")
                                .font(Font.Pretend.pretendardMedium(size: 16))
                            Spacer()
                        }
                        
                        Spacer().frame(height: 10)
                        
                        PhotosPicker(selection: $selectedBannerItem, matching: .images) {
                            ZStack {
                                if let image = selectedBannerImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 300)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    Rectangle()
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                        .foregroundStyle(Color.gray)
                                        .frame(height: 250)
                                    VStack {
                                        Image(systemName: "camera")
                                            .font(.system(size:30))
                                            .foregroundStyle(Color.gray)
                                        Text("사진을 업로드하세요")
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                            }
                        }
                        .onChange(of: selectedBannerItem) { oldItem, newItem in
                            Task {
                                if let data = try? await
                                    newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    selectedBannerImage = uiImage
                                }
                            }
                        }
                        
                        // 버튼
                        Button(action: {
                            if isFormValid {
                                print("그룹 생성하기")
                                withAnimation{
                                    showPopUp = true
                                }
                            }
                        }, label: {
                            Text("그룹 생성하기")
                                .foregroundStyle(Color.white)
                                .font(Font.Pretend.pretendardSemiBold(size: 14))
                                .padding(.horizontal, 43)
                                .padding(.vertical, 10)
                                .background(isFormValid ? Color.orange01 : Color.gray.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        })
                        .disabled(!isFormValid)
                        .padding(.bottom, 20)
                        .padding(.top, 35)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                }
            }
            
            if showPopUp {
                showPopUpView(title: "챌린지를 생성하시겠습니까?",
                              message: "챌린지 생성 후 수정 및 삭제가 불가합니다.\n가입 조건 및 인증 조건을 정확하게 입력하였는지 확인해주세요.",
                              btn1: "생성하기",
                              btn2: "취소"
                )
            }
        }
    }
}

extension GroupCreateNextView {
    func showPopUpView (
        title: String,
        message: String,
        btn1: String,
        btn2: String
    ) -> some View {
        WarningView(
            showPopUp: $showPopUp,
            title: title,
            message: message,
            btn1: btn1,
            btn2: btn2
        )
    }
}

#Preview {
    GroupCreateNextView()
}
