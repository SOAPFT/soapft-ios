//
//  UploadCertificationView.swift
//  SOAPFT
//
//  Created by 바견규 on 6/30/25.
//

import SwiftUI

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
    @State private var selectedImages: [UIImage] = []
    @State private var descriptionText: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isShowingCamera: Bool = false

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
                
                // Display images that have been taken
                if !selectedImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(selectedImages.enumerated()), id: \.element) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipped()
                                        .cornerRadius(8)

                                    Button(action: {
                                        selectedImages.remove(at: index)
                                        viewModel.resetVerification()
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .offset(x: -5, y: 5)
                                }
                            }
                        }.padding(.horizontal)
                    }.frame(height: 140)
                }

                // Button to open the camera and take a photo
                if selectedImages.count < 5 {
                    Button(action: {
                        isShowingCamera = true
                    }) {
                        if selectedImages.isEmpty {
                            ZStack {
                                Rectangle()
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                    .foregroundStyle(.gray)
                                    .frame(height: 300)
                                VStack(spacing: 8) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 30))
                                        .foregroundStyle(.gray)
                                    Text("카메라로 촬영하여 인증하세요")
                                        .foregroundStyle(.gray)
                                }
                            }
                            .padding()
                        } else {
                            Label("사진 추가 촬영 (\(selectedImages.count)/5)", systemImage: "camera")
                                .font(Font.Pretend.pretendardBold(size: 16))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                    }
                } else {
                    Text("최대 5장의 사진을 모두 등록했습니다.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding()
                }


                if !selectedImages.isEmpty {
                    Button(action: {
                        Task {
                            await viewModel.verifyImages(challengeUuid: challengeUuid, images: selectedImages)
                        }
                    }) {
                        Label(viewModel.verificationResult == nil ? "AI 검증하기" : "재검증하기", systemImage: "sparkles")
                            .font(Font.Pretend.pretendardBold(size: 16))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    .disabled(viewModel.isUploading || viewModel.isPolling) // 검증 중 비활성화
                }
                
                // 검증 결과 뷰
                if let result = viewModel.verificationResult {
                    VStack(alignment: .leading, spacing: 16) {


                        HStack(spacing: 8) {
                            Image(systemName: "quote.bubble.fill")
                                .foregroundColor(.blue)
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
                        Text("인증과 관련된 내용을 작성해주세요.")
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
                            selectedImages = []
                            descriptionText = ""
                            viewModel.verificationResult = nil
                        }
                    }
                }) {
                    Text(viewModel.isUploading ? "업로드 중..." : "업로드")
                        .font(Font.Pretend.pretendardBold(size: 18))
                        .foregroundStyle(.white)
                        .padding(10)
                        .padding(.horizontal, 30)
                        .background(viewModel.canCreatePost ? Color.orange01 : Color.gray)
                        .cornerRadius(20)
                }
                .disabled(!viewModel.canCreatePost || viewModel.isUploading || viewModel.isPolling)
                .padding()
            }
        }
        .padding(.top)
        .sheet(isPresented: $isShowingCamera) {
            CameraView(onImagePicked: { newImage in
                guard selectedImages.count < 5 else { return }
                selectedImages.append(newImage)
                viewModel.resetVerification()
            })
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage))
        }
        .overlay {
            if viewModel.isUploading || viewModel.isPolling {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView(viewModel.isPolling ? "AI 검증 결과 업데이트 중..." : "AI 검증 중입니다...\n잠시만 기다려주세요.")
                        .padding()
                        .multilineTextAlignment(.center)
                        .background(Color.white)
                        .cornerRadius(12)
                }
            }
        }
    }
}
