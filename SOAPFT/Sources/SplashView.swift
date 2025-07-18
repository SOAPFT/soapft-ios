//
//  SplashView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/16/25.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.orange02
                .ignoresSafeArea()
            
            Image("logo")
                .resizable()
                .frame(width: 84, height: 75)
                .foregroundStyle(Color.white)
        }
    }
}

#Preview {
    SplashView()
}
