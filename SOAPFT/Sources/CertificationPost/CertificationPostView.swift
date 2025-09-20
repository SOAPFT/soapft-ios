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
    @Environment(\.diContainer) private var container
    
    var body: some View {
        VStack {
            CertificationPostNavBar()
            
            if viewModel.isLoading {
                // 로딩 상태
                Spacer()
                ProgressView("인증글을 불러오는 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
            } else if viewModel.posts.isEmpty {
                // 빈 상태 - 인증글이 없을 때
                EmptyPostsView()
            } else {
                // 인증글이 있을 때
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
                                .onAppear {
                                    // ✅ 마지막 글이 나타나면 다음 페이지 요청
                                    if let last = viewModel.posts.last,
                                       post.postUuid == last.postUuid,
                                       viewModel.hasMore,
                                       !viewModel.isLoading {
                                        viewModel.fetchPosts()
                                    }
                                }
                            }
                        }
                        
                        // ✅ 로딩 인디케이터 (다음 페이지 로드 중)
                        if viewModel.isLoading && viewModel.currentPage > 1 {
                            ProgressView("불러오는 중...")
                                .padding()
                        }
                    }
                    .padding()
                }

            }
        }
        .sheet(item: $selectedPostForComment) { post in
            PostchatSheetWrapper(postUuid: post.postUuid) { addedCount in
                print("💬 댓글 추가 수: \(addedCount)")
                viewModel.commentCounts[post.postUuid, default: post.commentCount!] += addedCount
            }
        }
        .onReceive(container.postRefreshSubject) {
            viewModel.fetchPosts(refresh: true)
        }
    }
}

// MARK: - 빈 상태 뷰
struct EmptyPostsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            // 이미지
            Image("NoneParticipateChallenge")
                .padding()
            
            // 메시지
            VStack(spacing: 8) {
                Text("인증글이 없어요")
                    .font(Font.Pretend.pretendardSemiBold(size: 18))
                    .foregroundStyle(.gray)
                
                Text("첫 번째 인증글을 작성해보세요!")
                    .font(Font.Pretend.pretendardLight(size: 15))
                    .foregroundStyle(.gray)
                    .padding(1)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

#Preview {
    CertificationPostView(viewModel: CertificationPostViewModel(postService: PostService(), likeServie: LikeService(), challengeId: "test"))
}
