//
//  GroupEditView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/1/25.
//

import SwiftUI
import PhotosUI

struct GroupEditView: View {
    let initialProfileURL: String
    let initialBannerURL: String
    
    @State private var selectedProfileImage: UIImage?
    @State private var selectedProfileItem: PhotosPickerItem?
    @State private var selectedBannerImage: UIImage?
    @State private var selectedBannerItem: PhotosPickerItem?
    
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
                }

                Text("그룹 수정")
                    .font(Font.Pretend.pretendardBold(size: 16))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            ScrollView {
                LazyVStack {
                    // 프로필 이미지 업로드
                    imageSection(
                        title: "프로필 이미지 선택",
                        selectedImage: $selectedProfileImage,
                        pickerItem: $selectedProfileItem
                    )
                    
                    Spacer().frame(height: 35)
                    
                    // MARK: - 배너 이미지
                    imageSection(
                        title: "배너 이미지 선택",
                        selectedImage: $selectedBannerImage,
                        pickerItem: $selectedBannerItem
                    )
                    
                    Spacer().frame(height: 35)
                    
                    // 버튼
                    Button(action: {
                        // 수정 요청
                    }, label: {
                        Text("그룹 수정하기")
                            .foregroundStyle(.white)
                            .font(Font.Pretend.pretendardSemiBold(size: 14))
                            .padding(.horizontal, 43)
                            .padding(.vertical, 10)
                            .background(Color.orange01)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    })
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
            }
        }
        .onAppear {
            // 처음 진입 시 URL → UIImage 로드
            loadImage(from: initialProfileURL) { image in
                self.selectedProfileImage = image
            }
            loadImage(from: initialBannerURL) { image in
                self.selectedBannerImage = image
            }
        }
    }
    
    // MARK: - 이미지 섹션 공통 컴포넌트
    @ViewBuilder
    private func imageSection(
        title: String,
        selectedImage: Binding<UIImage?>,
        pickerItem: Binding<PhotosPickerItem?>
    ) -> some View {
        HStack {
            Text(title)
                .font(Font.Pretend.pretendardMedium(size: 16))
            Spacer()
        }
        
        Spacer().frame(height: 10)
        
        PhotosPicker(selection: pickerItem, matching: .images) {
            ZStack {
                if let image = selectedImage.wrappedValue {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    VStack {
                        Image(systemName: "camera")
                            .font(.system(size: 30))
                            .foregroundStyle(.white.opacity(0.8))
                            .shadow(radius: 4)
                    }
                } else {
                    placeholderImage
                }
            }
        }
        .onChange(of: pickerItem.wrappedValue) { oldItem, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage.wrappedValue = uiImage
                }
            }
        }
    }
    
    // MARK: - URL → UIImage 변환 함수
    private func loadImage(from urlString: String, completion: @escaping(UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: - placeholder
        private var placeholderImage: some View {
            Rectangle()
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundStyle(Color.gray)
                .frame(height: 250)
                .overlay(
                    VStack {
                        Image(systemName: "camera")
                            .font(.system(size: 30))
                            .foregroundStyle(Color.gray)
                        Text("사진을 업로드하세요")
                            .foregroundStyle(Color.gray)
                    }
                )
        }
}

#Preview {
    GroupEditView(
        initialProfileURL: GroupInfoMockData.profile,
        initialBannerURL: GroupInfoMockData.banner
    )
}
