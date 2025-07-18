//
//  GroupCreateViewModel.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/12/25.
//

import Foundation
import Combine
import SwiftUI
import Moya

final class GroupCreateViewModel: ObservableObject {
    
    // 기본 정보 (1단계)
    @Published var groupName: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var description: String = ""
    @Published var maxMembers: Int = 10
    @Published var selectedGender: String = "제한 없음"
    @Published var selectedAgeRange: ClosedRange<CGFloat> = 20...40
    @Published var selectedGoal: String = "주 7회"
    @Published var authMethod: String = ""
    @Published var coinAmount: Int = 0
    
    // 이미지 정보 (2단계)
    @Published var profileImage: UIImage?
    @Published var bannerImage: UIImage?
    
    // 챌린지 생성 응답
    @Published var creationResponse: ChallengeCreationResponse?
    @Published var creationError: String?
    
    private let challengeService = ChallengeService()
    private var cancellables = Set<AnyCancellable>()
    
    // 챌린지 생성 요청
    func createChallenge(accessToken: String) {
        guard let profileData = profileImage?.jpegData(compressionQuality: 0.8),
              let bannerData = bannerImage?.jpegData(compressionQuality: 0.8) else {
            creationError = "이미지를 업로드해주세요"
            print("❌ 이미지 없음: profileImage = \(String(describing: profileImage)), bannerImage = \(String(describing: bannerImage))")
            return
        }
        
        let goalValue = goalStringToInt(selectedGoal)
        
        let genderValue: String = {
            switch selectedGender {
            case "제한 없음": return "NONE"
            case "남성": return "MALE"
            case "여성": return "FEMALE"
            default: return "NONE"
            }
        }()
        
        let parameters: [String: Any] = [
            "title": groupName,
            "type": "NORMAL",
            "introduce": description,
            "verificationGuide": authMethod,
            "start_date": iso8601String(from: startDate),
            "end_date": iso8601String(from: endDate),
            "goal": goalValue,
            "start_age": Int(selectedAgeRange.lowerBound),
            "end_age": Int(selectedAgeRange.upperBound),
            "gender": genderValue,
            "max_member": maxMembers,
            "coin_amount": coinAmount,
//            "profile": profileData,
//            "banner": bannerData
        ]
        
        print("🚀 [챌린지 생성 요청] AccessToken: \(accessToken)")
        print("📦 파라미터:")
        for (key, value) in parameters {
            print("    \(key): \(value)")
        }
        print("📸 이미지: profile=\(profileData.count) bytes, banner=\(bannerData.count) bytes")
        
//        challengeService.createChallenge(parameters: parameters) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    self?.creationResponse = response
//                    print("✅ 챌린지 생성 성공: \(response)")
//                case .failure(let error):
//                    self?.creationError = error.localizedDescription
//                    print("❌ 챌린지 생성 실패: \(error.localizedDescription)")
//                }
//            }
//        }
        
        challengeService.createChallengeMultipart(parameters: parameters, profileImage: profileData, bannerImage: bannerData) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.creationResponse = response
                    print("✅ 챌린지 생성 성공: \(response)")
                case .failure(let error):
                    self?.creationError = error.localizedDescription
                    print("❌ 챌린지 생성 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 유효성 검사
    var isFirstFormValid: Bool {
        !groupName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        !authMethod.trimmingCharacters(in: .whitespaces).isEmpty &&
        (10...50).contains(maxMembers) &&
        !selectedGender.isEmpty &&
        !selectedGoal.isEmpty
    }
    
    var isImageFormValid: Bool {
        profileImage != nil && bannerImage != nil
    }
    
    // 날짜 포맷 변환
    private func iso8601String(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
    
    private func goalStringToInt(_ goal: String) -> Int {
        switch goal {
        case "주 1회": return 1
        case "주 2회": return 2
        case "주 3회": return 3
        case "주 4회": return 4
        case "주 5회": return 5
        case "주 6회": return 6
        case "주 7회": return 7
        default: return 0
        }
    }
}
