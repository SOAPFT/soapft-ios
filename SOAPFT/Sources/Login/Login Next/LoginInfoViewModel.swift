//
//  LoginInfoViewModel.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/11/25.
//

import SwiftUI

final class LoginInfoViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var gender: String = "남성"
    @Published var birth: Date = Date()
    @Published var showTermsOfService: Bool = false
    
    var isFormValid: Bool {
        !nickname.trimmingCharacters(in: .whitespaces).isEmpty &&
        !gender.trimmingCharacters(in: .whitespaces).isEmpty &&
        !birth.description.isEmpty
    }
    
    var birthFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: birth)
    }
    
    var genderForServer: String {
        switch gender {
        case "남성": return "MALE"
        case "여성": return "FEMALE"
        default: return ""
        }
    }
    
    func fetchNickname() {
        AuthService.shared.testNickname { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ 닉네임 받아옴: \(response.nickname)")
                    self?.nickname = response.nickname
                case .failure(let error):
                    print("❌ 닉네임 요청 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func openTerms() {
        showTermsOfService = true
    }
}

extension LoginInfoViewModel {
    var birthFormattedServerFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: birth)
    }
}
