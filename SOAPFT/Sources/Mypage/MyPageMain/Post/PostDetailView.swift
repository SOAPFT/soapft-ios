import SwiftUI
import Kingfisher

struct PostDetailView: View {
    @Environment(\.diContainer) private var container
    @StateObject private var viewModel: PostDetailViewModel
    @StateObject private var uiState: PostUIState

    @State private var showCommentSheet = false
    // 런타임용
    init(postUuid: String) {
        let di = DIContainer(router: AppRouter())
        _viewModel = StateObject(wrappedValue:
            PostDetailViewModel(container: di, postUuid: postUuid)
        )
        _uiState = StateObject(wrappedValue:
            PostUIState(postUuid: postUuid, likeService: di.likeService)
        )
    }

    // 주입용(프리뷰/테스트)
    init(viewModel: PostDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _uiState = StateObject(wrappedValue:
            PostUIState(postUuid: viewModel.postUuid, likeService: viewModel.container.likeService)
        )
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: { container.router.pop() }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                        .font(.system(size: 18))
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else if let post = viewModel.post {
                detailContent(post)
                    .sheet(isPresented: $showCommentSheet) {
                    PostchatSheetWrapper(postUuid: post.postUuid) { _ in
                        viewModel.fetchDetail()
                    }
                }
            } else {
                EmptyView()
            }
        }
        .onAppear {
            viewModel.container = container
            if viewModel.post == nil { viewModel.fetchDetail() }
        }
        .navigationBarBackButtonHidden()
    }
}

private extension PostDetailView {
    var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("불러오는 중…").font(.caption).foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text("불러오지 못했어요 😢").font(.headline)
            Text(message).font(.caption).foregroundStyle(.secondary)
            Button("다시 시도") { viewModel.fetchDetail() }
                .buttonStyle(.borderedProminent)
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func detailContent(_ post: PostDetailDTO) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // 1) 작성자
                HStack(spacing: 12) {
                    KFImage(URL(string: post.user.profileImage))
                        .placeholder { Circle().fill(.gray.opacity(0.25)) }
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.user.nickname)
                            .font(.subheadline).bold()
                        Text(timeAgoString(from: post.createdAt))
                            .font(.caption).foregroundStyle(.gray)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // 2) 이미지 캐러셀
                if !post.imageUrl.isEmpty {
                    ImageCarousel(imageUrls: post.imageUrl)
                        .frame(height: 360)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 16)
                }

                // 3) 제목/내용
                VStack(alignment: .leading, spacing: 8) {
                    if !post.title.isEmpty {
                        Text(post.title)
                            .font(.title3.weight(.semibold))
                    }
                    if !post.content.isEmpty {
                        Text(post.content)
                            .font(.body)
                            .lineSpacing(4)
                    }
                }
                .padding(.horizontal, 16)

                // 4) 액션바 (좋아요/댓글/의심)
                HStack(spacing: 20) {
                    Button {
                        uiState.isLiked.toggle()
                        viewModel.toggleLike(for: post)
                    } label: {
                        Label("좋아요", systemImage: uiState.isLiked ? "heart.fill" : "heart")
                            .labelStyle(.iconOnly)
                            .foregroundStyle(uiState.isLiked ? .red : .gray)
                    }

                    Button {
                        showCommentSheet = true
                    } label: {
                        Label("댓글", systemImage: "text.bubble")
                            .labelStyle(.iconOnly)
                            .foregroundStyle(.gray)
                    }

                    Button {
                        uiState.isSuspicious.toggle()
                        viewModel.toggleSuspicion(for: post)
                    } label: {
                        Image("spectacle-lenses")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 16, height: 16)
                            .foregroundStyle(uiState.isSuspicious ? .orange : .gray)
                    }

                    Spacer()

                    // 5) 메타
                    HStack(spacing: 8) {
                        Image(systemName: "eye")
                        Text("\(post.views)")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)

                // 구분선
                Divider().padding(.horizontal, 16)
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Image Carousel
private struct ImageCarousel: View {
    let imageUrls: [String]
    @State private var index: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $index) {
                ForEach(Array(imageUrls.enumerated()), id: \.offset) { i, url in
                    KFImage(URL(string: url))
                        .placeholder { Rectangle().fill(.gray.opacity(0.2)) }
                        .resizable()
                        .scaledToFill()
                        .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // 인디케이터
            HStack(spacing: 6) {
                ForEach(imageUrls.indices, id: \.self) { i in
                    Circle()
                        .fill(i == index ? Color.gray : Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
            .padding(10)
            .padding(10)
        }
    }
}


#Preview {
    // 1) 모의 컨테이너 (필요 시)
    let mockContainer = DIContainer(router: AppRouter())

    // 2) 모의 VM 생성
    let vm = PostDetailViewModel(container: mockContainer, postUuid: "mock-uuid-1234")
    vm.isLoading = false
    vm.errorMessage = nil
    vm.post = PostDetailDTO(
        id: 1,
        postUuid: "mock-uuid-1234",
        title: "프리뷰 타이틀",
        challengeUuid: "challenge-uuid",
        content: "프리뷰 본문입니다.\n줄바꿈도 테스트해요.",
        imageUrl: [
            "https://picsum.photos/seed/preview1/800/600",
            "https://picsum.photos/seed/preview2/800/600"
        ],
        isPublic: true,
        createdAt: "2025-07-03T10:10:00Z",
        updatedAt: "2025-07-04T10:10:00Z",
        userUuid: "user-uuid-123",
        isMine: true,
        views: 123,
        user: UserDTO(userUuid: "user-uuid-123",
                      nickname: "홍지우",
                      profileImage: "https://picsum.photos/seed/profile/100/100")
    )

    // 3) 주입 이니셜라이저 사용
    return PostDetailView(viewModel: vm)
        .environment(\.diContainer, mockContainer)
}
