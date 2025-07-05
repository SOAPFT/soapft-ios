import ProjectDescription

let project = Project(
    name: "SOAPFT",
    packages: [
        .package(url: "https://github.com/kakao/kakao-ios-sdk", .upToNextMajor(from: "2.24.4")),
        .package(url: "https://github.com/Moya/Moya.git", .exact("15.0.0")),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.2"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/naver/naveridlogin-sdk-ios-swift", .upToNextMajor(from: "5.0.1"))

    ],
    settings: .settings(
        configurations: [
            .debug(name: "SecretOnly", xcconfig: .relativeToRoot("../SOAPFT_iOS/Configuration/Secret.xcconfig"))
        ]
    ),
    targets: [
        .target(
            name: "SOAPFT",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.SOAPFT",
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleIconName": "AppIcon",
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": ""
                    ],
                    // ✅ Secret.xcconfig에서 가져올 값들
                    "API_URL": "$(API_URL)",
                    "Kakao_AppKey": "$(Kakao_AppKey)",
                ]
            ),
            sources: ["SOAPFT/Sources/**"],
            resources: ["SOAPFT/Resources/**"],
            dependencies: [
                .package(product: "KakaoSDKCommon"),
                .package(product: "KakaoSDKAuth"),
                .package(product: "KakaoSDKUser"),
                .package(product: "Moya"),
                .package(product: "Lottie"),
                .package(product: "Kingfisher"),
                .package(product: "NidThirdPartyLogin")
            ]
        ),
        .target(
            name: "SOAPFTTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.SOAPFTTests",
            infoPlist: .default,
            sources: ["SOAPFT/Tests/**"],
            dependencies: [.target(name: "SOAPFT")]
        )
    ]
)
