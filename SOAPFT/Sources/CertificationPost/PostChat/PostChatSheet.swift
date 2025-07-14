//
//  Untitled.swift
//  SOAPFT
//
//  Created by 바견규 on 7/2/25.
//

import SwiftUI
import Kingfisher

struct PostChatSheet: View {
    @ObservedObject var viewModel: PostChatViewModel
    @State private var newCommentText: String = ""
    @State private var replyTextMap: [Int: String] = [:]
    @State private var replyingToCommentId: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            Text("댓글")
                .font(.headline)
                .padding()

            Divider()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.comments) { comment in
                        CommentView(
                            comment: comment,
                            isReplying: replyingToCommentId == comment.id,
                            replyText: replyTextMap[comment.id, default: ""],
                            onReplyTextChange: { replyTextMap[comment.id] = $0 },
                            onReplySubmit: {
                                let replyContent = replyTextMap[comment.id, default: ""]
                                if !replyContent.isEmpty {
                                    viewModel.addReply(to: comment.id, content: replyContent)
                                    replyTextMap[comment.id] = ""
                                    replyingToCommentId = nil
                                }
                            },
                            onReplyButtonTap: {
                                replyingToCommentId = comment.id
                            }
                        )
                        Divider().padding(.vertical, 8)
                    }
                }
            }

            Divider()

            HStack {
                TextField("댓글을 입력하세요", text: $newCommentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    if !newCommentText.isEmpty {
                        viewModel.addComment(content: newCommentText)
                        newCommentText = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(newCommentText.isEmpty ? Color.gray.opacity(0.5) : Color.orange01)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.loadMockData()
        }
    }
}

struct CommentView: View {
    let comment: Comment
    var isReplying: Bool
    var replyText: String
    var onReplyTextChange: (String) -> Void
    var onReplySubmit: () -> Void
    var onReplyButtonTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                KFImage(URL(string: comment.author.profileImage))
                    .placeholder { Circle().fill(Color.gray) }
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())

                VStack(alignment: .leading) {
                    HStack {
                        Text(comment.author.nickname)
                            .font(.subheadline).bold()
                        Text(
                            comment.updatedAt != comment.createdAt
                            ? "· 수정됨 \(timeAgoString(from: comment.updatedAt))"
                            : "· \(timeAgoString(from: comment.createdAt))"
                        )
                        .font(.caption)
                        .foregroundStyle(.gray)
                    }
                }
            }

            Text(comment.content)
                .font(.body)
                .padding(.horizontal, 40)

            ForEach(comment.replies) { reply in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "arrow.turn.down.left")
                        .scaleEffect(x: -1, y: 1) // 좌우 반전
                        .font(.caption)
                        .foregroundStyle(.gray)

                    KFImage(URL(string: reply.author.profileImage))
                        .placeholder { Circle().fill(Color.gray) }
                        .resizable()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())

                    VStack(alignment: .leading) {
                        HStack {
                            Text(reply.author.nickname)
                                .font(.subheadline).bold()
                            Text(
                                "· \(timeAgoString(from: reply.createdAt))"
                            )
                            .font(.caption)
                            .foregroundStyle(.gray)
                        }
                        Text(reply.content)
                            .font(.body)
                    }
                }
                .padding(.leading, 60)
            }

            if isReplying {
                HStack {
                    TextField("답글을 입력하세요", text: Binding(
                        get: { replyText },
                        set: { onReplyTextChange($0) }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: onReplySubmit) {
                        Image(systemName: "paperplane.fill")
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(replyText.isEmpty ? Color.gray.opacity(0.5) : Color.orange01)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 4)
            } else {
                Button("답글 달기", action: onReplyButtonTap)
                    .font(.caption)
                    .foregroundStyle(Color.orange01)
                    .padding(.horizontal, 40)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - 시간 포맷팅 헬퍼
func timeAgoString(from isoDateString: String) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    guard let date = formatter.date(from: isoDateString) else {
        return "알 수 없음"
    }

    let now = Date()
    let secondsAgo = Int(now.timeIntervalSince(date))
    
    switch secondsAgo {
    case ..<60:
        return "방금 전"
    case 60..<3600:
        return "\(secondsAgo / 60)분 전"
    case 3600..<86400:
        return "\(secondsAgo / 3600)시간 전"
    case 86400..<172800:
        return "어제"
    default:
        return "\(secondsAgo / 86400)일 전"
    }
}

#Preview {
    PostChatSheet(viewModel: PostChatViewModel(postUuid: "dummy-uuid"))
}
