//
//  WebViewPresentable.swift
//  SOAPFT
//
//  Created by 바견규 on 8/9/25.
//

import SwiftUI
@preconcurrency import WebKit


// MARK: - WebView UIViewRepresentable
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
