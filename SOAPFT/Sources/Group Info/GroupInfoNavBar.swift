//
//  GroupInfoNavBar.swift
//  SOAPFT
//
//  Created by 바견규 on 6/30/25.
//

import SwiftUI

struct GroupInfoNavBar: View {
    let ChallengeId: String
    let showToast: (String, Bool) -> Void // 토스트 표시 콜백
    
    @Environment(\.diContainer) private var container
    @State private var showLeaveModal = false

    var body: some View {
        ZStack {
            Text("그룹 정보")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)

            HStack {
                Button(action: {
                    container.router.pop()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.black)
                }

                Spacer()

                Button(action: { container.router.push(.alert) }) {
                    Image(systemName: "bell")
                        .foregroundStyle(.black)
                }

                Button(action: { showLeaveModal = true }) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.black)
                        .frame(width: 18, height: 24)
                        .contentShape(Rectangle())
                }
            }
            .padding()
        }
        .background(Color.white)
        .sheet(isPresented: $showLeaveModal) {
            LeaveActionSheet(
                onLeave: {
                    showLeaveModal = false
                    container.challengeService.leaveChallenge(id: ChallengeId) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let response):
                                print("성공 응답: \(response.message)")
                                showToast(response.message, true)
                                container.challengeRefreshSubject.send()
                                container.chatRefreshSubject.send()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    container.router.pop()
                                }
                            case .failure(let error):
                                let errorMessage = (error as? APIError)?.message ?? "오류가 발생했습니다."
                                print("실패 응답: \(errorMessage)")
                                showToast(errorMessage, false)
                            }
                        }
                    }
                },
                onCancel: {
                    showLeaveModal = false
                },
                leaveText: "탈퇴하기"
            )
        }
    }
}

