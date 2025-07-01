//
//  LottieWrapper.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var filename: String
    var loopMode: LottieLoopMode = .loop

    let animationView = LottieAnimationView()

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        let animation = LottieAnimation.named(filename)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // 재생 상태 업데이트 등 필요 시 여기에 작성
    }
}
