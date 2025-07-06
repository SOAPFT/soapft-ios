//
//  NaverSignButton.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/6/25.
//

import SwiftUI
import NidThirdPartyLogin

struct NaverSignButton: View {
    @State private var accessToken: String = ""
    @State private var loginError: String = ""
    @State private var userName: String = ""
    
    var body: some View {
        VStack {
            Button(action: {
                loginWithNaver()
            }) {
                Image("naverButton")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width * 0.9)
            }
            
            if !accessToken.isEmpty {
                Text("Access Token: \(accessToken)")
                    .font(.footnote)
                    .padding()
            }
            
            if !loginError.isEmpty {
                Text("Error: \(loginError)")
                    .foregroundColor(.red)
                    .font(.footnote)
            }
        }
    }
    
    func loginWithNaver() {
        NidOAuth.shared.requestLogin { result in
            switch result {
            case .success(let loginResult):
                DispatchQueue.main.async {
                    accessToken = loginResult.accessToken.tokenString
                    loginError = ""
                    fetUserProfile(with: loginResult.accessToken.tokenString)
                }
                print("Access Token: ", loginResult.accessToken.tokenString)
            case .failure(let error):
                DispatchQueue.main.async {
                    loginError = error.localizedDescription
                    accessToken = ""
                }
                print("Error: ", error.localizedDescription)
            }
        }
    }
    
    func fetUserProfile(with token: String) {
        NidOAuth.shared.getUserProfile(accessToken: token) { result in
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    userName = profile["name"] ?? "이름 없음"
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    loginError = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    NaverSignButton()
}
