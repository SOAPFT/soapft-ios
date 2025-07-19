//
//  Untitled.swift
//  SOAPFT
//
//  Created by 바견규 on 7/2/25.
//

// MARK: - View
import SwiftUI

struct CertificationPostViewWrapper: View {
    @Environment(\.diContainer) private var container
    let ChallengeId: String
    
    var body: some View {
        let viewModel = CertificationPostViewModel(postService: container.postService, likeServie: container.likeService, challengeId: ChallengeId)
        CertificationPostView(viewModel: viewModel)
            .navigationBarBackButtonHidden(true)
    }
}

struct CertificationPostView: View {
    @StateObject var viewModel: CertificationPostViewModel
    @State private var selectedPostForComment: Post?

    
    var body: some View {
        VStack {
            CertificationPostNavBar()
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.posts) { post in
                        if let state = viewModel.postUIStates[post.postUuid] {
                            PostCardView(
                                post: post,
                                createdTime: post.createdAt,
                                state: state,
                                toggleLike: { viewModel.toggleLike(for: post) },
                                toggleComment: {
                                    selectedPostForComment = post
                                },
                                toggleSuspicious: { viewModel.toggleSuspicion(for: post) },
                                commentCount: viewModel.commentCounts[post.postUuid, default: post.commentCount!]
                            )
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(item: $selectedPostForComment) { post in
            PostchatSheetWrapper(postUuid: post.postUuid) { addedCount in
                print("💬 댓글 추가 수: \(addedCount)")
                viewModel.commentCounts[post.postUuid, default: post.commentCount!] += addedCount
            }
        }
        .onAppear {
            viewModel.fetchPosts()
        }
    }
}


#Preview {
   
}
