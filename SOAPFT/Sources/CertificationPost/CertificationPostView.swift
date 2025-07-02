//
//  Untitled.swift
//  SOAPFT
//
//  Created by 바견규 on 7/2/25.
//

// MARK: - View
import SwiftUI

struct CertificationPostView: View {
    @StateObject var viewModel: CertificationPostViewModel
    @State private var selectedPostForComment: ChallengePost?

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
                                toggleSuspicious: { viewModel.toggleSuspicion(for: post) }
                            )
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(item: $selectedPostForComment) { post in
            PostChatSheet(viewModel: PostChatViewModel(postUuid: post.postUuid))
        }
        .onAppear {
            viewModel.fetchPosts()
        }
    }
}


#Preview {
    CertificationPostView(viewModel: CertificationPostViewModel())
}
