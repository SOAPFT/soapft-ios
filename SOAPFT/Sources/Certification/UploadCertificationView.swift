//
//  UploadCertificationView.swift
//  SOAPFT
//
//  Created by 바견규 on 6/30/25.
//

import SwiftUI
import PhotosUI

struct UploadCertificationView: View {
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var descriptionText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack() {
            
            //상단 네비게이션바
            CertificationNavBar()
            
            Divider()
            
            // 이미지 업로드 영역
            PhotosPicker(selection: $selectedItem, matching: .images) {
                ZStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Rectangle()
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundColor(.gray)
                            .frame(height: 300)
                        VStack {
                            Image(systemName: "camera")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                            Text("사진을 업로드하세요")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
            }
            .onChange(of: selectedItem) { oldItem,newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                }
            }

            // 텍스트 입력 영역
            ZStack(alignment: .topLeading) {
                        TextEditor(text: $descriptionText)
                            .focused($isFocused)
                            .font(Font.Pretend.pretendardMedium(size: 14))
                            .frame(height: 150)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                            .padding(.horizontal)
                            .padding(.bottom)

                        if descriptionText.isEmpty && !isFocused {
                            Text("텍스트를 입력하세요")
                                .foregroundColor(.gray)
                                .padding(10)
                                .padding(.leading, 20)
                        }
                    }

            // 업로드 버튼
            Button(action: {
                // 업로드 처리
            }) {
                Text("업로드")
                    .font(Font.Pretend.pretendardBold(size: 18))
                    .foregroundColor(.white)
                    .padding(10)
                    .padding(.horizontal, 30)
                    .background(Color.orange01)
                    .cornerRadius(20)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
    }
}

#Preview {
    UploadCertificationView()
}
