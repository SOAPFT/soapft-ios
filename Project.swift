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
        
        // MARK: - iOS Main App
        .target(
            name: "SOAPFT",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.SOAPFT",
            infoPlist: .extendingDefault(with: [
                "CFBundleIconName": "AppIcon",
                "UILaunchScreen": [
                    "UIColorName": "",
                    "UIImageName": ""
                ],
                "NSHealthShareUsageDescription": "이 앱은 걸음 수, 칼로리, 운동 거리 등의 건강 데이터를 표시하기 위해 HealthKit 데이터를 읽습니다.",
                "NSHealthUpdateUsageDescription": "이 앱은 건강 데이터를 기록하거나 수정하기 위해 HealthKit 접근이 필요합니다.",
                "UIBackgroundModes": ["remote-notification"],
                "API_URL": "$(API_URL)",
                "ChatWebSocket_URL": "$(ChatWebSocket_URL)",
                "Kakao_AppKey": "$(Kakao_AppKey)",
                "NidClientID": "$(NidClientID)",
                "NidClientSecret": "$(NidClientSecret)",
                "NidAppName": "SOAPFT",
                "NidServiceAppUrlScheme": "naver.$(NidClientID)",
                "NidUrlScheme": "$(NidUrlScheme)",
                "PaymentURL": "$(PaymentURL)",
                "UIUserInterfaceStyle": "Light"
            ]),
            sources: ["SOAPFT/Sources/**"],
            resources: ["SOAPFT/Resources/**"],
            entitlements: .file(path: .relativeToRoot("SOAPFT/Sources/SOAPFT.entitlements")), // 기존 iOS entitlements
            dependencies: [
                .target(name: "SOAPFT_WatchApp"),
                .package(product: "KakaoSDKCommon"),
                .package(product: "KakaoSDKAuth"),
                .package(product: "KakaoSDKUser"),
                .package(product: "Moya"),
                .package(product: "Lottie"),
                .package(product: "Kingfisher"),
                .package(product: "NidThirdPartyLogin")
            ],
            settings: .settings(base: [
                "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                "EMBEDDED_CONTENT_CONTAINS_SWIFT": "YES"
            ])
        ),
        
        // MARK: - Watch App (stub app)
        .target(
            name: "SOAPFT_WatchApp",
            destinations: .watchOS,
            product: .watch2App,
            bundleId: "io.tuist.SOAPFT.watchapp",
            infoPlist: .extendingDefault(with: [
                "WKWatchKitApp": true,
                "WKCompanionAppBundleIdentifier": "io.tuist.SOAPFT"
            ]),
            sources: [],
            resources: ["SOAPFT_WatchApp/Resources/**"],
            dependencies: [
                .target(name: "SOAPFT_WatchExtension")
            ],
            settings: .settings(base: [
                "WATCHOS_DEPLOYMENT_TARGET": "10.0"
            ])
        ),
        
        // MARK: - Watch Extension (HealthKit entitlements 추가)
        .target(
            name: "SOAPFT_WatchExtension",
            destinations: .watchOS,
            product: .watch2Extension,
            bundleId: "io.tuist.SOAPFT.watchapp.watchkitextension",
            infoPlist: .extendingDefault(with: [
                "NSExtension": [
                    "NSExtensionPointIdentifier": "com.apple.watchkit",
                    "NSExtensionAttributes": [
                        "WKAppBundleIdentifier": "io.tuist.SOAPFT.watchapp"
                    ]
                ],
                "NSHealthShareUsageDescription": "운동 중 걸음 수, 거리, 칼로리 데이터를 읽기 위해 사용합니다.",
                "NSHealthUpdateUsageDescription": "운동 데이터를 기록하기 위해 사용합니다."
            ]),
            sources: ["SOAPFT_WatchExtension/Sources/**"],
            resources: ["SOAPFT_WatchExtension/Resources/**"],
            entitlements: .file(path: .relativeToRoot("SOAPFT_WatchExtension/Sources/SOAPFT_WatchExtension.entitlements")), // HealthKit entitlements
            settings: .settings(base: [
                "WATCHOS_DEPLOYMENT_TARGET": "10.0",
                "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym"
            ])
        )
    ]
)
