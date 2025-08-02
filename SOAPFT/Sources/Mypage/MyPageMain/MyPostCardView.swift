//
//  MyPostCardView.swift
//  SOAPFT
//
//  Created by 홍지우 on 8/3/25.
//

import SwiftUI
import Kingfisher

struct MyPostCardView: View {
    let post: Post
    let createdTime: String
    @ObservedObject var state: PostUIState
    let toggleLike: () -> Void
    let toggleComment: () -> Void
    let toggleSuspicious: () -> Void
    
    @State private var showSuspiciousAlert = false
    @State private var currentImageIndex: Int = 0
    
    let commentCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            profileSection
            imageSection
            indicatorSection
            actionButtons
            if !post.content.isEmpty {
                postContent
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2))
        )
    }

    // MARK: - Subviews

    private var profileSection: some View {
        HStack {
            KFImage(URL(string: post.user?.profileImage ?? ""))
                .placeholder { Circle().fill(Color.gray.opacity(0.3)) }
                .resizable()
                .frame(width: 32, height: 32)
                .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(post.user?.nickname ?? "")
                    .font(.subheadline).bold()
                Text(timeAgoString(from: createdTime))
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Spacer()
        }
    }

    private var imageSection: some View {
        TabView(selection: $currentImageIndex) {
            ForEach(Array(post.imageUrl.enumerated()), id: \.offset) { index, imageUrl in
                KFImage(URL(string: imageUrl))
                    .placeholder { Rectangle().fill(Color.gray.opacity(0.2)) }
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipped()
                    .tag(index)
            }
        }
        .frame(height: 300)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }

    private var indicatorSection: some View {
        HStack(spacing: 6) {
            ForEach(0..<post.imageUrl.count, id: \.self) { index in
                Circle()
                    .fill(index == currentImageIndex ? Color.gray : Color.gray.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
    }

    private var actionButtons: some View {
        HStack(spacing: 20) {
            Button(action: toggleLike) {
                Label("\(post.likeCount)", systemImage: state.isLiked ? "heart.fill" : "heart")
                    .foregroundStyle(state.isLiked ? .red : .gray)
            }
             

            Button(action: toggleComment) {
                Label("\(commentCount)", systemImage: "text.bubble")
                    .foregroundStyle(.gray)
            }

            Button(action: {
                if state.isSuspicious {
                    toggleSuspicious() // 이미 의심한 상태이면 즉시 취소
                } else {
                    showSuspiciousAlert = true // 처음 누르면 Alert 표시
                }
            }) {
                HStack(spacing: 4) {
                    Image("spectacle-lenses")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 14, height: 14)
                }
                .foregroundStyle(state.isSuspicious ? .orange : .gray)
            }
            .alert(isPresented: $showSuspiciousAlert) {
                Alert(
                    title: Text("의심하시겠습니까?"),
                    message: Text("허위 신고는 제재받을 수 있습니다."),
                    primaryButton: .destructive(Text("의심하기")) {
                        toggleSuspicious()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .font(.caption)
    }

    private var commentField: some View {
        TextField("댓글을 입력하세요...", text: .constant(""))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.top, 4)
    }

    private var postContent: some View {
        Text(post.content)
            .font(Font.Pretend.pretendardMedium(size: 14))
            .padding(.top, 4)
    }
}


