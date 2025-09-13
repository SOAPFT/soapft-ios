//
//  GroupInfoView.swift
//  SOAPFT
//
//  Created by 바견규 on 6/30/25.
//

// GroupInfoView.swift
import SwiftUI
import Kingfisher

struct GroupInfoWrapper: View {
    @Environment(\.diContainer) private var container
    let challenge: ChallengeDetailResponse
    
    // 토스트 상태 관리를 최상위에서
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var isToastSuccess = true

    var body: some View {
        VStack(spacing: 0) {
            GroupInfoNavBar(
                ChallengeId: challenge.challengeUuid ?? "",
                showToast: showToastMessage // 토스트 함수 전달
            )
            .navigationBarBackButtonHidden(true)
            
            GroupInfoWrapperBody(viewModel: GroupInfoViewModel(
                challengeService: container.challengeService,
                id: challenge.challengeUuid ?? ""
            ))
        }
        .toast(
            message: toastMessage,
            isSuccess: isToastSuccess,
            isVisible: $showToast
        )
    }
    
    // 토스트 표시 함수
    private func showToastMessage(_ message: String, isSuccess: Bool) {
        toastMessage = message
        isToastSuccess = isSuccess
        withAnimation {
            showToast = true
        }
        print("토스트 표시 - 메시지: \(message), 성공: \(isSuccess)")
    }
}


private struct GroupInfoWrapperBody: View {
    @StateObject var viewModel: GroupInfoViewModel

    var body: some View {
        GroupInfoView(viewModel: viewModel)
    }
}



struct GroupInfoView: View {
    @ObservedObject var viewModel: GroupInfoViewModel

    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    BannerSection(bannerURL: viewModel.challenge.banner)
                    BasicInfoSection(challenge: viewModel.challenge)
                    DescriptionSection(introduce: viewModel.challenge.introduce)
                    CreatorSection(creator: viewModel.creator)
                    MemberSearchSection(viewModel: viewModel)
                    MemberListSection(viewModel: viewModel)
                }
                .padding(.top)
            }
            .navigationBarTitleDisplayMode(.inline)

    }
}

struct BannerSection: View {
    let bannerURL: String?

    var body: some View {
        KFImage(URL(string: bannerURL ?? ""))
            .placeholder {
                Color.gray.opacity(0.2)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                    )
            }
            .onFailure { error in
                print("배너 이미지 로드 실패: \(error)")
            }
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .strokeBorder(Color.gray.opacity(0.5), lineWidth: 0.8)
            )
    }
}

struct BasicInfoSection: View {
    let challenge: ChallengeDetailResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(challenge.title)
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 4) {
                InfoRow(title: "기간", value: formatDateRange(start: challenge.startDate, end: challenge.endDate))
                InfoRow(title: "목표", value: "주 \(challenge.goal)회 활동")
                InfoRow(title: "인원", value: "\(challenge.currentMembers)/\(challenge.maxMember)명")
                InfoRow(title: "성별", value: genderString(challenge.gender))
                InfoRow(title: "나이", value: "\(challenge.startAge ?? 0)세 ~ \(challenge.endAge.map { "\($0)세" } ?? "제한 없음")")
            }
        }
        .padding(.horizontal)
        Divider()
    }

    func genderString(_ value: String) -> String {
        switch value {
        case "MALE": return "남성"
        case "FEMALE": return "여성"
        default: return "전체"
        }
    }
    
    // MARK: - 날짜 포맷 변경
    func formatDateRange(start: String, end: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "ko_KR")
        displayFormatter.dateFormat = "yyyy년 M월 d일"

        if let startDate = formatter.date(from: start),
           let endDate = formatter.date(from: end) {
            let startStr = displayFormatter.string(from: startDate)
            let endStr = displayFormatter.string(from: endDate)
            return "\(startStr) ~ \(endStr)"
        } else {
            return "날짜 형식 오류"
        }
    }
}

struct DescriptionSection: View {
    let introduce: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("설명")
                .font(.headline)
            Text(introduce ?? "")
                .font(Font.Pretend.pretendardLight(size: 14))
        }
        .padding(.horizontal)
        Divider()
    }
}

struct CreatorSection: View {
    let creator: Participant?

    var body: some View {
        HStack(spacing: 12) {
            if let creator = creator {
                let urlString = creator.profileImage ?? ""

                if !urlString.isEmpty, let url = URL(string: urlString) {
                    KFImage(url)
                        .resizable()
                        .placeholder { ProgressView() }
                        .cancelOnDisappear(true)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                }


                Text(creator.nickname ?? "알 수 없음")
                    .font(.headline)

                Spacer()

                Image(systemName: "crown.fill")
                    .foregroundStyle(.orange)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("❗️방장 정보를 불러오지 못했습니다.")
                        .foregroundColor(.red)
                        .font(.subheadline)
                    Text("운영자에게 문의해주시기 바랍니다.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
        Divider()
    }
}

struct MemberSearchSection: View {
    @ObservedObject var viewModel: GroupInfoViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("멤버 \(viewModel.challenge.participants.count)").font(.headline)
            

            TextField("멤버를 검색해주세요", text: $viewModel.searchText)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct MemberListSection: View {
    @ObservedObject var viewModel: GroupInfoViewModel

    var body: some View {
        VStack(spacing: 12) {
                ForEach(viewModel.filteredParticipants, id: \.userUuid) { member in
                    HStack(spacing: 12) {
                        let urlString = member.profileImage ?? ""

                        if !urlString.isEmpty, let url = URL(string: urlString) {
                            KFImage(url)
                                .resizable()
                                .placeholder { ProgressView() }
                                .cancelOnDisappear(true)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                        }

                        
                        Text(member.nickname ?? "알 수 없음")
                        
                        if member.userUuid == viewModel.challenge.creatorUuid {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.orange)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.gray)
                .frame(width: 50, alignment: .leading)
            Text(value)
        }
    }
}

