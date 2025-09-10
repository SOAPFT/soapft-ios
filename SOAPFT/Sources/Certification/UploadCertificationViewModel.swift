//
//  UploadCertificationViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 7/15/25
//

import Foundation
import SwiftUI

final class UploadCertificationViewModel: ObservableObject, @unchecked Sendable {
    private let challengeService: ChallengeService
    
    @Published var isUploading: Bool = false
    @Published var isPolling: Bool = false
    @Published var verificationResult: PrecheckResponse?
    @Published var uploadSuccessMessage: String?
    @Published var errorMessage: String?
    
    private var pollingTask: Task<Void, Never>?


    var canCreatePost: Bool {
        verificationResult?.canCreatePost == true
    }

    init(challengeService: ChallengeService) {
        self.challengeService = challengeService
    }
    
    deinit {
        pollingTask?.cancel()
    }

    // ❗ ADDED: 검증 상태를 리셋하는 함수
    func resetVerification() {
        DispatchQueue.main.async {
            self.verificationResult = nil
            self.errorMessage = nil
            self.pollingTask?.cancel()
            self.isPolling = false
        }
    }


    func verifyImages(challengeUuid: String, images: [UIImage]) async {
        pollingTask?.cancel()
        
        await MainActor.run {
            self.verificationResult = nil
            self.errorMessage = nil
        }
        
        guard !images.isEmpty else {
            await MainActor.run { self.errorMessage = "선택된 이미지가 없습니다." }
            return
        }

        let imageDatas: [Data] = images.compactMap { $0.jpegData(compressionQuality: 0.8) }
        
        await MainActor.run { isUploading = true }

        challengeService.precheckImages(challengeUuid: challengeUuid, images: imageDatas) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isUploading = false
                switch result {
                case .success(let flatResponse):
                    self.verificationResult = self.convertToNestedResponse(from: flatResponse)
                    
                    if flatResponse.overallStatus == "processing" || flatResponse.overallStatus == "review" {
                        self.startPolling(postUuid: flatResponse.postUuid)
                    }

                case .failure(let error):
                    self.errorMessage = "검증 실패: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func convertToNestedResponse(from flatResponse: VerificationStatusResponse, originalImages: [VerifiedImage]? = nil) -> PrecheckResponse {
        
        let verificationSummary = VerificationSummary(
            overallStatus: flatResponse.overallStatus,
            averageConfidence: Int(flatResponse.averageConfidence ?? 0),
            totalImages: flatResponse.totalImages,
            approvedImages: flatResponse.approvedImages,
            rejectedImages: flatResponse.rejectedImages,
            reviewImages: flatResponse.reviewImages,
            pendingImages: flatResponse.pendingImages
        )

        let verifiedImages = flatResponse.images.map { statusImage in
            let confidenceValue = Int(Double(statusImage.confidence ?? "0") ?? 0)
            
            return VerifiedImage(
                imageUrl: statusImage.imageUrl,
                originalName: "Uploaded Image",
                status: statusImage.status,
                confidence: confidenceValue,
                reasoning: statusImage.reasoning,
                isRelevant: statusImage.isRelevant
            )
        }
        
        return PrecheckResponse(
            success: flatResponse.success,
            message: flatResponse.message ?? flatResponse.recommendedAction ?? "상태 업데이트", postUuid: flatResponse.postUuid,
            verification: verificationSummary,
            images: verifiedImages,
            verificationToken: flatResponse.verificationToken ?? self.verificationResult?.verificationToken ?? "",
            canCreatePost: flatResponse.canCreatePost,
            recommendations: [flatResponse.recommendedAction].compactMap { $0 }
        )
    }

    private func startPolling(postUuid: String) {
        pollingTask = Task {
            await MainActor.run { self.isPolling = true }
            
            defer { Task { @MainActor in self.isPolling = false } }

            for _ in 0..<10 {
                if Task.isCancelled { break }
                
                let statusResult = await checkVerificationStatus(postUuid: postUuid)
                // 'processing'이나 'review'가 아닌 모든 최종 상태('approved', 'rejected' 등)에서 폴링 중단
                if let newStatus = statusResult, newStatus.overallStatus != "processing", newStatus.overallStatus != "review" {
                     await updateVerificationResult(with: newStatus)
                     break
                }
                
                try? await Task.sleep(for: .seconds(3))
            }
        }
    }
    
    private func checkVerificationStatus(postUuid: String) async -> VerificationStatusResponse? {
        await withCheckedContinuation { continuation in
            challengeService.getVerificationStatus(postUuid: postUuid) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    print("Polling failed with error: \(error)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    @MainActor
    private func updateVerificationResult(with statusResponse: VerificationStatusResponse) {
        self.verificationResult = convertToNestedResponse(from: statusResponse, originalImages: self.verificationResult?.images)
    }

    func uploadVerifiedPost(challengeUuid: String, description: String) async -> Bool {
        pollingTask?.cancel()
        
        guard let result = verificationResult, result.canCreatePost else {
            DispatchQueue.main.async { self.errorMessage = "AI 검증을 통과하지 못해 업로드할 수 없습니다." }
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
            DispatchQueue.main.async { self.isUploading = true }

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
