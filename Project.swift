import ProjectDescription

let settings = Settings.settings(
  base: [
    "DEVELOPMENT_TEAM": "MHD24ZMA79",         // ✅ 본인의 Apple Developer Team ID
    "CODE_SIGN_STYLE": "Automatic",           // ✅ 자동 서명 방식 사용
  ]
)

let project = Project(
    name: "SOAPFT",
    settings: settings,  // ← 여기에 설정 적용!
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
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["SOAPFT/Sources/**"],
            resources: ["SOAPFT/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "SOAPFTTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.SOAPFTTests",
            infoPlist: .default,
            sources: ["SOAPFT/Tests/**"],
            resources: [],
            dependencies: [.target(name: "SOAPFT")]
        ),
    ]
)
