//
//  GroupTabbarView.swift
//  SOAPFT
//
//  Created by 홍지우 on 6/25/25.
//

import SwiftUI

struct GroupTabbarWrapper: View {
    @Environment(\.diContainer) private var container
    let challengeID: String

    @State private var challenge: ChallengeDetailResponse?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        contentView
            .onAppear {
                loadChallenge()
            }
    }

    @ViewBuilder
    private var contentView: some View {
        if isLoading {
            ProgressView("챌린지를 불러오는 중입니다...")
        } else if let challenge = challenge {
            GroupTabbarView(Challenge: challenge)
        } else {
            VStack {
                Text("❗️챌린지 정보를 불러오지 못했습니다.")
                    .foregroundColor(.red)
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private func loadChallenge() {
        container.challengeService.getChallengeDetail(id: challengeID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.challenge = data
                    self.isLoading = false
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}





struct GroupTabbarView: View {
    @State private var selectedTab: String = "Info"
    let Challenge:ChallengeDetailResponse
    
    
    
    var body: some View{
        VStack(spacing: 0) {
            TabView (selection: $selectedTab){
                GroupInfoWrapper(challenge: Challenge)
                    .tag("Info")
                ChallengeStatisticsWrapper(challenge: Challenge)
                    .tag("Status")
                UploadCertificationViewWrapper(challengeUuid: Challenge.challengeUuid)
                    .tag("Check")
                CertificationPostViewWrapper(ChallengeId: Challenge.challengeUuid)
                    .tag("List")
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack {
                tabButton(title: "Info", selectedImage: "info.circle")
                tabButton(title: "Status", selectedImage: "checkmark.seal")
                tabButton(title: "Check", selectedImage: "camera")
                tabButton(title: "List", selectedImage: "newspaper")
            }
            .padding()
            .background(Color.white)
        }
    }
    
    @ViewBuilder
    private func tabButton(title: String, selectedImage: String) -> some View {
        Button {
            selectedTab = title
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedImage)
                    .foregroundStyle(selectedTab == title ? Color.orange01 : .gray)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(selectedTab == title ? Color.orange01 : .gray)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
   
}
