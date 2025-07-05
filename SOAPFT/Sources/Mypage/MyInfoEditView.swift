//
//  MyInfoEditView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/5/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct FileDetails: Identifiable {
    var id: String { name }
    let name: String
    let fileType: UTType
}

struct MyInfoEditView: View {
    @State private var selectedItem: PhotosPickerItem? = nil

    @State private var profileImage: UIImage? = nil
    
    @State private var showCamera = false
    @State private var showActionSheet = false
    @State private var showPhotosPicker = false
    
    @State var nickname: String = "Jiwoo"
    @State var intro: String = ""
    
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
                        showActionSheet = true
                    }, label: {
                        ZStack {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipped()
                                    .clipShape(Circle())
                                    .frame(width: 150)
                            } else {
                                AsyncImage(url: URL(string: "https://example.com/image.png")) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                            .clipped()
                                            .clipShape(Circle())
                                            .frame(width: 150)
                                    } else if phase.error != nil {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 150, height: 150)
                                            .foregroundStyle(Color.gray)
                                    } else {
                                        ProgressView()
                                    }
                                }
                            }
                            
                            Image(systemName: "camera.circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .offset(x: 50, y: 50)
                                .foregroundStyle(Color.black)
                        }
                    })
                    .confirmationDialog("사진을 어떻게 추가할까요?", isPresented: $showActionSheet, titleVisibility: .visible) {
                        Button("앨범에서 가져오기") {
                            showPhotosPicker = true
                        }

                        Button("카메라로 촬영하기") {
                            showCamera = true
                        }

                        Button("취소", role: .cancel) {}
                    }
                    .sheet(isPresented: $showCamera) {
                        CameraPicker { image in
                            profileImage = image
                        }
                    }
                    .photosPicker(isPresented: $showPhotosPicker, selection: $selectedItem, matching: .images)
                            .onChange(of: selectedItem) { oldItem,newItem in
                                guard let item = newItem else { return }
                                Task {
                                    if let data = try? await item.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        profileImage = image
                                    }
                                }
                                
                            }
                    
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
