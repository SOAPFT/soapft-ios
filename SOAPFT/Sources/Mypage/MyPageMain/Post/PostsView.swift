//
//  PostsView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/3/25.
//

import SwiftUI

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
                VStack {
                    AsyncImage(url: URL(string: post.imageUrl.first ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .onAppear {
                    if post.id == viewModel.posts.last?.id {
                        viewModel.fetchPosts()
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
//            viewModel.loadMockData()
        }
    }
}

#Preview {
    PostsView()
}
