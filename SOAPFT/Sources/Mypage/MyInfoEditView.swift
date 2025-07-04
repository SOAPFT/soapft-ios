//
//  MyInfoEditView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/5/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct MyInfoEditView: View {
    @State var nickname: String = "Jiwoo"
    @State var intro: String = ""
    
    @State var showingSheet = false
    @State private var showImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage? = nil //실제로 가져온 이미지
    
    var body: some View {
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
            
                    Button(action: { }) {
                        Text("저장")
                            .font(Font.Pretend.pretendardMedium(size: 16))
                            .foregroundStyle(Color.black)
                    }
                }
                
                Text("프로필 수정")
                    .font(Font.Pretend.pretendardBold(size: 16))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            ScrollView {
                VStack(spacing: 40) {
                    Button(action: {
                        print("프로필 바꾸기")
                        self.showingSheet = true
                    }, label: {
                        ZStack {
                            AsyncImage(url: URL(string: "https://example.com/image.png")) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fill)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else if phase.error != nil {
                                    Circle()
                                        .frame(width: 150)
                                        .foregroundStyle(Color.gray)
                                } else {
                                    ProgressView()
                                }
                            }
                            
                            Image(systemName: "camera.circle.fill")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .offset(x: 50, y: 50)
                                .foregroundStyle(Color.black)
                        }
                    })
                    
                    VStack(spacing: 12) {
                        Divider()
                        HStack {
                            HStack {
                                Text("닉네임")
                                    .font(Font.Pretend.pretendardMedium(size: 16))
                                Spacer()
                            }
                            .frame(width: 100)
                            
                            ZStack(alignment: .leading) {
                                if nickname.isEmpty {
                                    Text("닉네임")
                                        .foregroundStyle(Color.gray)
                                        .font(Font.Pretend.pretendardRegular(size: 16))
                                }
                                TextField("", text: $nickname)
                                    .font(Font.Pretend.pretendardRegular(size: 16))
                            }
                        }
                        
                        Divider()
                        HStack {
                            HStack {
                                Text("소개")
                                    .font(Font.Pretend.pretendardMedium(size: 16))
                                Spacer()
                            }
                            .frame(width: 100)
                            
                            ZStack(alignment: .leading) {
                                if intro.isEmpty {
                                    Text("소개")
                                        .foregroundStyle(Color.gray)
                                        .font(Font.Pretend.pretendardRegular(size: 16))
                                }
                                TextField("", text: $intro)
                                    .font(Font.Pretend.pretendardRegular(size: 16))
                            }
                        }
                        
                        Divider()
                    }
                    .padding(.horizontal, 12)
                }
                .padding(.top, 18)
            }
        }
    }
}

#Preview {
    MyInfoEditView()
}
