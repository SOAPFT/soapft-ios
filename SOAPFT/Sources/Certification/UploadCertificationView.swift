//
//  UploadCertificationView.swift
//  SOAPFT
//
//  Created by 바견규 on 6/30/25.
//

import SwiftUI
import PhotosUI

struct UploadCertificationViewWrapper: View {
    @Environment(\.diContainer) private var container
    let challengeUuid: String

    var body: some View {
        let viewModel = UploadCertificationViewModel(challengeService: container.challengeService)
        UploadCertificationView(viewModel: viewModel, challengeUuid: challengeUuid)
            .navigationBarBackButtonHidden(true)
    }
}

struct UploadCertificationView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var descriptionText: String = ""
    @State private var isVerifying: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    @FocusState private var isFocused: Bool
    @StateObject private var viewModel: UploadCertificationViewModel

    let challengeUuid: String

    init(viewModel: UploadCertificationViewModel, challengeUuid: String) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.challengeUuid = challengeUuid
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CertificationNavBar()
                Divider()

                // 이미지 선택
                PhotosPicker(selection: $selectedItems, maxSelectionCount: 5, matching: .images) {
                    ZStack {
                        if !selectedImages.isEmpty {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(selectedImages, id: \.self) { image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                }.padding(.horizontal)
                            }.frame(height: 140)
                        } else {
                            Rectangle()
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .foregroundStyle(.gray)
                                .frame(height: 300)
                            VStack {
                                Image(systemName: "camera")
                                    .font(.system(size: 30))
                                    .foregroundStyle(.gray)
                                Text("사진을 업로드하세요")
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: selectedItems) { _, newItems in
                    selectedImages = []
                    Task {
                        for item in newItems {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedImages.append(image)
                            }
                        }
                        if !selectedImages.isEmpty {
                            isVerifying = true
                            viewModel.verifyImages(challengeUuid: challengeUuid, images: selectedImages)
                            isVerifying = false
                        }
                    }
                }

                // 검증 결과 뷰
                if let result = viewModel.verificationResult {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                            Text("챌린지: \(result.challengeInfo.title)")
                                .font(.title3)
                                .bold()
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "quote.bubble.fill")
                                .foregroundColor(.blue)
                            Text(result.challengeInfo.verificationGuide)
                                .font(.callout)
                                .foregroundColor(.gray)
                        }

                        Divider()

                        Label {
                            Text("검증 결과: ")
                                + Text(result.verification.overallStatus == "approved" ? "성공" : "검토 필요")
                                    .bold()
                                    .foregroundColor(result.verification.overallStatus == "approved" ? .green : .orange)
                        } icon: {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(result.verification.overallStatus == "approved" ? .green : .orange)
                        }

                        Label("평균 신뢰도: \(result.verification.averageConfidence)%", systemImage: "gauge.with.dots.needle")
                        Label("총 이미지 수: \(result.verification.totalImages)", systemImage: "photo.stack")

                        HStack {
                            Label("승인: \(result.verification.approvedImages)", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(Color.green)
                            Label("거절: \(result.verification.rejectedImages)", systemImage: "xmark.circle.fill")
                                .foregroundStyle(Color.red)
                            Label("검토: \(result.verification.reviewImages)", systemImage: "hourglass.circle.fill")
                                .foregroundStyle(Color.yellow)
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)

                        Divider()

                        ForEach(result.images) { image in
                            VStack(alignment: .leading, spacing: 6) {
                                Label(image.originalName, systemImage: "photo")
                                    .font(.subheadline)
                                    .bold()

                                HStack {
                                    Image(systemName: {
                                        switch image.status {
                                        case "approve": return "checkmark.circle.fill"
                                        case "reject": return "xmark.octagon.fill"
                                        case "review": return "questionmark.diamond.fill"
                                        default: return "exclamationmark.triangle.fill"
                                        }
                                    }())
                                    .foregroundColor({
                                        switch image.status {
                                        case "approve": return .green
                                        case "reject": return .red
                                        case "review": return .orange
                                        default: return .gray
                                        }
                                    }())
                                    
                                    Text("상태: \(image.status.capitalized), 신뢰도: \(image.confidence)%")
                                }
                                
                                if let reason = image.reasoning {
                                    Text("사유: \(reason)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(result.recommendations, id: \.self) { rec in
                                Label(rec, systemImage: "lightbulb.fill")
                                    .font(.callout)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }


                // 텍스트 입력
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $descriptionText)
                        .focused($isFocused)
                        .font(Font.Pretend.pretendardMedium(size: 14))
                        .frame(height: 150)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                        .padding(.horizontal)

                    if descriptionText.isEmpty && !isFocused {
                        Text("텍스트를 입력하세요")
                            .foregroundStyle(.gray)
                            .padding(10)
                            .padding(.leading, 20)
                    }
                }

                // 업로드 버튼
                Button(action: {
                    Task {
                        let success = await viewModel.uploadVerifiedPost(challengeUuid: challengeUuid, description: descriptionText)
                        alertMessage = success ? "게시글 업로드 완료!" : "업로드 실패. 다시 시도해주세요."
                        showAlert = true
                        if success{
                            //상태 초기화
                            selectedItems = []
                            selectedImages = []
                            descriptionText = ""
                            viewModel.verificationResult = nil
                        }
                    }
                }) {
                    Text(isVerifying ? "AI 검증중..." : "업로드")
                        .font(Font.Pretend.pretendardBold(size: 18))
                        .foregroundStyle(.white)
                        .padding(10)
                        .padding(.horizontal, 30)
                        .background(viewModel.canCreatePost ? Color.orange01 : Color.gray)
                        .cornerRadius(20)
                }
                .disabled(!viewModel.canCreatePost)
                .padding()
            }
        }
        .padding(.top)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage))
        }
        .overlay {
            if isVerifying || viewModel.isUploading {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("AI 검증 중입니다...\n잠시만 기다려주세요.")
                        .padding()
                        .multilineTextAlignment(.center)
                        .background(Color.white)
                        .cornerRadius(12)
                }
            }
        }
    }
}
