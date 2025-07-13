//
//  FriendsPostsView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/13/25.
//

import SwiftUI

struct FriendsPostsView: View {
    @Environment(\.diContainer) private var container
    @StateObject private var viewModel: FriendsPostViewModel
    
    let userUUID: String
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(userUUID: String) {
        self.userUUID = userUUID
        _viewModel = StateObject(wrappedValue: FriendsPostViewModel(container: DIContainer(router: AppRouter()), userUUID: userUUID))
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
    }}

#Preview {
//    FriendsPostsView()
}
