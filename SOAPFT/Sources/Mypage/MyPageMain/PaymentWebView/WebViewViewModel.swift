//
//  WebViewViewModel.swift
//  SOAPFT
//
//  Created by 바견규 on 8/9/25.
//

import SwiftUI
@preconcurrency import WebKit


// MARK: - 웹뷰 ViewModel
class PaymentWebViewModel: ObservableObject {
    @Published var isLoading = false
    
    func buildPaymentURL(coins: Int) -> URL {
        guard let baseURLString = Bundle.main.object(forInfoDictionaryKey: "PaymentURL") as? String,
              !baseURLString.isEmpty else {
            return URL(string: "https://default-payment-url.com")!
        }
        
        var components = URLComponents(string: baseURLString)!
        var queryItems: [URLQueryItem] = []
        
        // 액세스 토큰
        if let accessToken = KeyChainManager.shared.readAccessToken() {
            queryItems.append(URLQueryItem(name: "token", value: accessToken))
        }
        
        // 코인과 가격 정보
        queryItems.append(URLQueryItem(name: "amount", value: "\(coins)"))
        
        components.queryItems = queryItems
        
        let finalURL = components.url!
        print("🔗 결제 URL: \(finalURL.absoluteString)")
        
        return finalURL
    }
}
