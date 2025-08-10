//
//  GifticonShopView.swift
//  SOAPFT
//
//  Created by Developer on 8/10/25.
//

import SwiftUI

// MARK: - 기프티콘 상품 모델
struct GifticonProduct: Identifiable, Codable {
    let id: String
    let name: String
    let brand: String
    let price: Int
    let coinPrice: Int
    let imageUrl: String
    let category: String
    let discount: Int?
    let isPopular: Bool
    let description: String
    let originalPrice: Int?
    
    var discountText: String? {
        guard let discount = discount, discount > 0 else { return nil }
        return "\(discount)% 할인"
    }
    
    var finalPrice: Int {
        guard let originalPrice = originalPrice, let discount = discount else { return price }
        return originalPrice - (originalPrice * discount / 100)
    }
}

struct GifticonShopView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: GifticonShopViewModel
    @State private var selectedCategory = "전체"
    @State private var selectedProduct: GifticonProduct?
    @State private var showingPurchaseSheet = false
    
    init(userCoins: Int) {
        _viewModel = StateObject(wrappedValue: GifticonShopViewModel(userCoins: userCoins))
    }
    
    let categories = ["전체", "카페", "편의점", "치킨", "피자", "상품권", "디저트"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 상단바
                topBarView
                
                // 현재 보유 코인
                currentCoinView
                
                // 카테고리 필터
                categoryFilterView
                
                // 상품 목록
                productGridView
            }
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            viewModel.loadProducts()
        }
        .sheet(item: $selectedProduct) { product in
            GifticonDetailView(
                product: product,
                userCoins: viewModel.userCoins,
                onPurchase: { product in
                    viewModel.purchaseGifticon(product: product) { success in
                        if success {
                            selectedProduct = nil
                            viewModel.userCoins = viewModel.userCoins - product.coinPrice
                        }
                    }
                }
            )
        }
    }
    
    // MARK: - 상단바
    private var topBarView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
                    .font(.system(size: 18))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            
            Spacer()
            
            Text("기프티콘 쇼핑")
                .font(Font.Pretend.pretendardSemiBold(size: 18))
                .foregroundColor(.black)
            
            Spacer()
            
            // 오른쪽 공간 균형을 위한 투명한 뷰
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal)
        .background(Color(.systemBackground))
        .overlay(
            Divider()
                .background(Color.gray.opacity(0.3)),
            alignment: .bottom
        )
    }
    
    // MARK: - 현재 보유 코인
    private var currentCoinView: some View {
        HStack {
            Image("bigCoin")
                .resizable()
                .frame(width: 24, height: 24)
            
            Text("보유 코인:")
                .font(Font.Pretend.pretendardRegular(size: 16))
                .foregroundColor(.gray)
            
            Text("\(viewModel.userCoins)")
                .font(Font.Pretend.pretendardSemiBold(size: 18))
                .foregroundColor(.orange02)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - 카테고리 필터
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category)
                            .font(Font.Pretend.pretendardMedium(size: 14))
                            .foregroundColor(selectedCategory == category ? .white : .gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedCategory == category ? Color.orange02 : Color.gray.opacity(0.2))
                            )
                    }
                    .contentShape(Rectangle())
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - 상품 그리드
    private var productGridView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 16) {
                ForEach(filteredProducts) { product in
                    GifticonProductCard(product: product) {
                        selectedProduct = product
                    }
                }
            }
            .padding()
        }
    }
    
    private var filteredProducts: [GifticonProduct] {
        if selectedCategory == "전체" {
            return viewModel.products
        } else {
            return viewModel.products.filter { $0.category == selectedCategory }
        }
    }
}

// MARK: - 상품 카드
struct GifticonProductCard: View {
    let product: GifticonProduct
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // 상품 이미지
                ZStack(alignment: .topTrailing) {
                    Image(product.imageUrl)
                        .resizable()
                        .scaledToFit()  // fill -> fit으로 변경하여 이미지 잘림 방지
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)  // 최대 너비 설정
                        .clipped()
                        .cornerRadius(12)
                        .padding(10)
                    
                    VStack(spacing: 4) {
                        // 할인 뱃지
                        if let discountText = product.discountText {
                            Text(discountText)
                                .font(Font.Pretend.pretendardBold(size: 10))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.red)
                                .cornerRadius(6)
                        }
                        
                        // 인기 뱃지
                        if product.isPopular {
                            Text("인기")
                                .font(Font.Pretend.pretendardBold(size: 8))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.orange02)
                                .cornerRadius(6)
                        }
                    }
                    .padding(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // 브랜드
                    Text(product.brand)
                        .font(Font.Pretend.pretendardMedium(size: 12))
                        .foregroundColor(.gray)
                    
                    // 상품명
                    Text(product.name)
                        .font(Font.Pretend.pretendardSemiBold(size: 14))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    // 가격 정보
                    HStack {
                        if let originalPrice = product.originalPrice, product.discount != nil {
                            Text("\(originalPrice)원")
                                .font(Font.Pretend.pretendardRegular(size: 12))
                                .foregroundColor(.gray)
                                .strikethrough()
                        }
                        
                        Text("\(product.price)원")
                            .font(Font.Pretend.pretendardSemiBold(size: 14))
                            .foregroundColor(.black)
                    }
                    
                    // 코인 가격
                    HStack {
                        Image("bigCoin")
                            .resizable()
                            .frame(width: 16, height: 16)
                        
                        Text("\(product.coinPrice) 코인")
                            .font(Font.Pretend.pretendardSemiBold(size: 14))
                            .foregroundColor(.orange02)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
            }
        }
        .contentShape(Rectangle())  // 전체 카드 영역을 터치 가능하게
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 상품 상세 뷰
struct GifticonDetailView: View {
    let product: GifticonProduct
    let userCoins: Int
    let onPurchase: (GifticonProduct) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingPurchaseAlert = false
    @State private var showingInsufficientCoinsAlert = false
    @Environment(\.diContainer) private var container
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 상품 이미지 - 아이패드 최적화
                    Image(product.imageUrl)
                        .resizable()
                        .scaledToFit()  // fill -> fit으로 변경
                        .frame(maxHeight: 300)  // 최대 높이 제한
                        .frame(maxWidth: .infinity)
                        .cornerRadius(16)
                        .padding(10)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // 브랜드 & 상품명
                        VStack(alignment: .leading, spacing: 8) {
                            Text(product.brand)
                                .font(Font.Pretend.pretendardMedium(size: 16))
                                .foregroundColor(.orange02)
                            
                            Text(product.name)
                                .font(Font.Pretend.pretendardSemiBold(size: 20))
                                .foregroundColor(.black)
                        }
                        
                        // 가격 정보
                        VStack(alignment: .leading, spacing: 8) {
                            if let originalPrice = product.originalPrice, let discount = product.discount {
                                HStack {
                                    Text("\(discount)% 할인")
                                        .font(Font.Pretend.pretendardBold(size: 14))
                                        .foregroundColor(.red)
                                    
                                    Text("\(originalPrice)원")
                                        .font(Font.Pretend.pretendardRegular(size: 16))
                                        .foregroundColor(.gray)
                                        .strikethrough()
                                }
                            }
                            
                            Text("\(product.price)원")
                                .font(Font.Pretend.pretendardSemiBold(size: 24))
                                .foregroundColor(.black)
                            
                            HStack {
                                Image("bigCoin")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                
                                Text("\(product.coinPrice) 코인으로 교환")
                                    .font(Font.Pretend.pretendardSemiBold(size: 18))
                                    .foregroundColor(.orange02)
                            }
                        }
                        
                        Divider()
                        
                        // 상품 설명
                        VStack(alignment: .leading, spacing: 8) {
                            Text("상품 설명")
                                .font(Font.Pretend.pretendardSemiBold(size: 16))
                                .foregroundColor(.black)
                            
                            Text(product.description)
                                .font(Font.Pretend.pretendardRegular(size: 14))
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                        }
                        
                        // 현재 보유 코인
                        HStack {
                            Text("현재 보유 코인:")
                                .font(Font.Pretend.pretendardRegular(size: 16))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("\(userCoins) 코인")
                                .font(Font.Pretend.pretendardSemiBold(size: 16))
                                .foregroundColor(userCoins >= product.coinPrice ? .orange02 : .red)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                        )
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                    .foregroundStyle(.black)
                }
            }
            .safeAreaInset(edge: .bottom) {
                // 구매 버튼
                Button(action: {
                    if userCoins >= product.coinPrice {
                        showingPurchaseAlert = true
                    } else {
                        showingInsufficientCoinsAlert = true
                    }
                }) {
                    Text(userCoins >= product.coinPrice ? "기프티콘 교환하기" : "코인이 부족합니다")
                        .font(Font.Pretend.pretendardSemiBold(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: userCoins >= product.coinPrice ?
                                    [Color.orange02, Color.orange02.opacity(0.8)] :
                                    [Color.gray, Color.gray.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                .disabled(userCoins < product.coinPrice)
                .contentShape(Rectangle())
                .padding()
                .background(Color(.systemBackground))
            }
        }
        .alert("기프티콘 교환", isPresented: $showingPurchaseAlert) {
            Button("취소", role: .cancel) {}
            Button("교환하기") {
                container.paymentService.withdrawGifticon(amount: product.coinPrice) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let response):
                            // 교환 성공
                            print("✅ 교환 성공: \(response.message)")
                            onPurchase(product)
                            
                        case .failure(let error):
                            // 교환 실패
                            print("❌ 교환 실패: \(error.localizedDescription)")
                            // 실패 알림 표시 (옵션)
                        }
                    }
                }
            }
        } message: {
            Text("\(product.name)을(를) \(product.coinPrice) 코인으로 교환하시겠습니까?")
        }
        .alert("코인 부족", isPresented: $showingInsufficientCoinsAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("기프티콘 교환에 필요한 코인이 부족합니다.\n필요: \(product.coinPrice) 코인\n보유: \(userCoins) 코인")
        }
    }
}

// MARK: - 뷰모델
final class GifticonShopViewModel: ObservableObject {
    @Published var products: [GifticonProduct] = []
    @Published var userCoins: Int
    @Published var isLoading = false
    
    init(userCoins: Int){
        self.userCoins = userCoins
    }
    
    private let paymentService = PaymentService()
    
    func loadProducts() {
        // 실제 네이버페이 기프티콘 상품들
        products = [
            // 카페
            GifticonProduct(
                id: "1",
                name: "스타벅스 아메리카노 T",
                brand: "스타벅스",
                price: 4500,
                coinPrice: 45,
                imageUrl: "Starbucks",
                category: "카페",
                discount: nil,
                isPopular: true,
                description: "스타벅스에서 즐기는 신선한 아메리카노 T 사이즈입니다.",
                originalPrice: 5000
            ),
            GifticonProduct(
                id: "2",
                name: "투썸플레이스 연유라떼 R",
                brand: "투썸플레이스",
                price: 4000,
                coinPrice: 40,
                imageUrl: "TwoSome",
                category: "카페",
                discount: nil,
                isPopular: false,
                description: "투썸플레이스의 프리미엄 아메리카노 레귤러 사이즈입니다.",
                originalPrice: nil
            ),
            
            // 편의점
            GifticonProduct(
                id: "3",
                name: "CU 모바일상품권 5000원",
                brand: "CU",
                price: 5000,
                coinPrice: 50,
                imageUrl: "CU",
                category: "편의점",
                discount: nil,
                isPopular: false,
                description: "CU 편의점에서 사용 가능한 5000원 모바일상품권입니다.",
                originalPrice: nil
            ),
            GifticonProduct(
                id: "4",
                name: "GS25 모바일상품권 3000원",
                brand: "GS25",
                price: 3000,
                coinPrice: 30,
                imageUrl: "GS",
                category: "편의점",
                discount: nil,
                isPopular: false,
                description: "GS25 편의점에서 사용 가능한 3000원 모바일상품권입니다.",
                originalPrice: nil
            ),
            
            // 치킨
            GifticonProduct(
                id: "5",
                name: "교촌치킨 허니콤보 + 콜라",
                brand: "교촌치킨",
                price: 18000,
                coinPrice: 180,
                imageUrl: "Kyochon",
                category: "치킨",
                discount: nil,
                isPopular: false,
                description: "교촌치킨의 인기 메뉴 허니콤보와 콜라 세트입니다.",
                originalPrice: 21000
            ),
            GifticonProduct(
                id: "6",
                name: "BHC 뿌링클 순살치킨",
                brand: "BHC",
                price: 16000,
                coinPrice: 160,
                imageUrl: "BHC",
                category: "치킨",
                discount: nil,
                isPopular: false,
                description: "BHC의 시그니처 메뉴 뿌링클 순살치킨입니다.",
                originalPrice: nil
            ),
            
            // 피자
            GifticonProduct(
                id: "7",
                name: "도미노피자 페퍼로니 라지",
                brand: "도미노피자",
                price: 22000,
                coinPrice: 220,
                imageUrl: "Domino",
                category: "피자",
                discount: nil,
                isPopular: false,
                description: "도미노피자의 클래식 페퍼로니 피자 라지 사이즈입니다.",
                originalPrice: 27500
            ),
            
            // 상품권
            GifticonProduct(
                id: "8",
                name: "네이버페이 포인트",
                brand: "네이버페이",
                price: 10000,
                coinPrice: 100,
                imageUrl: "Naver",
                category: "상품권",
                discount: nil,
                isPopular: false,
                description: "네이버페이에서 사용 가능한 10000원 포인트입니다.",
                originalPrice: nil
            ),
            GifticonProduct(
                id: "9",
                name: "컬쳐랜드 문화상품권",
                brand: "컬쳐랜드",
                price: 5000,
                coinPrice: 50,
                imageUrl: "Cultureland",
                category: "상품권",
                discount: nil,
                isPopular: false,
                description: "컬쳐랜드에서 사용 가능한 5000원 문화상품권입니다.",
                originalPrice: nil
            ),
            
            // 디저트
            GifticonProduct(
                id: "10",
                name: "베스킨라빈스 하프갤런",
                brand: "베스킨라빈스",
                price: 15000,
                coinPrice: 150,
                imageUrl: "Baskinrobbins",
                category: "디저트",
                discount: nil,
                isPopular: false,
                description: "베스킨라빈스 아이스크림 하프갤런 교환권입니다.",
                originalPrice: 16700
            )
        ]
    }
    
    func purchaseGifticon(product: GifticonProduct, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        paymentService.withdrawGifticon(amount: product.coinPrice) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.userCoins -= product.coinPrice
                    completion(true)
                case .failure:
                    completion(false)
                }
            }
        }
    }
}

// MARK: - MyPageView에 추가할 코드
/*
MyPageView.swift의 body 끝부분 .onAppear() 뒤에 다음 modifier를 추가하세요:

.fullScreenCover(isPresented: $showingGifticon) {
    GifticonShopView()
}
*/

#Preview {
    GifticonShopView(userCoins: 250)
}
