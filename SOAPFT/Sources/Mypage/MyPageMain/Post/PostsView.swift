//
//  PostsView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/3/25.
//

import SwiftUI
import Kingfisher

struct PostsView: View {
    @Environment(\.diContainer) private var container
    @StateObject private var viewModel: PostViewModel
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init() {
        _viewModel = StateObject(wrappedValue: PostViewModel(container: DIContainer(router: AppRouter())))
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(viewModel.posts, id: \.id) { post in
                Button(action: {
                    container.router.push(.postDetail(postUuid: post.postUuid))
                }) {
                    VStack {
                        // Kingfisher로 이미지 로드
                        KFImage(URL(string: post.imageUrl.first ?? ""))
                            .placeholder {
                                // 로딩 중 플레이스홀더
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .aspectRatio(1, contentMode: .fit)
                                    .overlay(
                                        VStack(spacing: 4) {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                                .scaleEffect(0.7)
                                            
                                            Text("로딩 중...")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                    )
                            }
                            .onFailure { error in
                                print("포스트 이미지 로드 실패: \(post.id), \(error)")
                            }
                            .fade(duration: 0.2)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(Color.gray.opacity(0.3), lineWidth: 0.5)
                            )
                    }
                    .onAppear {
                        if post.id == viewModel.posts.last?.id {
                            viewModel.fetchPosts()
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear() {
            viewModel.container = container
            if viewModel.posts.isEmpty {
                viewModel.fetchPosts()
            }
        }
    }
}

#Preview {
    PostsView()
}
