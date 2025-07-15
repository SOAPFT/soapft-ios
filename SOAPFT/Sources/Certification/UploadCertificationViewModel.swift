//
//  UploadCertificationViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 7/15/25.
//

// UploadCertificationViewModel.swift
import Foundation
import SwiftUI

final class UploadCertificationViewModel: ObservableObject, @unchecked Sendable {
    private let challengeService: ChallengeService

    @Published var isUploading: Bool = false
    @Published var verificationResult: PrecheckResponse?
    @Published var uploadSuccessMessage: String?
    @Published var errorMessage: String?
    
    var canCreatePost: Bool {
        verificationResult?.canCreatePost == true
    }

    init(challengeService: ChallengeService) {
        self.challengeService = challengeService
    }

    // AI 이미지 사전검증
    func verifyImages(challengeUuid: String, images: [UIImage]) {
        guard !images.isEmpty else {
            self.errorMessage = "선택된 이미지가 없습니다."
            return
        }

        let imageDatas: [Data] = images.compactMap { $0.jpegData(compressionQuality: 0.8) }
        isUploading = true

        challengeService.precheckImages(challengeUuid: challengeUuid, images: imageDatas) { [weak self] result in
            DispatchQueue.main.async {
                self?.isUploading = false
                switch result {
                case .success(let response):
                    self?.verificationResult = response
                    if !response.canCreatePost {
                        self?.errorMessage = "이미지 검증을 통과하지 못했습니다."
                    }
                case .failure(let error):
                    self?.errorMessage = "검증 실패: \(error.localizedDescription)"
                }
            }
        }
    }

    // 검증된 이미지로 게시글 업로드
    func uploadVerifiedPost(challengeUuid: String, description: String) async -> Bool {
        guard let result = verificationResult, result.canCreatePost else {
            DispatchQueue.main.async {
                self.errorMessage = "AI 검증이 완료되지 않았습니다."
            }
            return false
        }

        let parameters: [String: Any] = [
            "challengeUuid": challengeUuid,
            "content": description,
            "verifiedImageUrls": result.images.map { $0.imageUrl },
            "verificationToken": result.verificationToken,
            "isPublic": true
        ]


        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                self.isUploading = true
            }

            challengeService.createVerifiedPost(parameters: parameters) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isUploading = false

                    switch result {
                    case .success(let response):
                        self?.uploadSuccessMessage = response.message
                        continuation.resume(returning: true)
                    case .failure(let error):
                        self?.errorMessage = "업로드 실패: \(error.localizedDescription)"
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }

}
