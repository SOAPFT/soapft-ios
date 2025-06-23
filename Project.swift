import ProjectDescription

let settings = Settings.settings(
  base: [
    "DEVELOPMENT_TEAM": "MHD24ZMA79",  // ✅ 본인의 팀 ID
    "CODE_SIGN_STYLE": "Manual",       // ✅ 수동 서명 방식
    "CODE_SIGN_IDENTITY": "Apple Distribution",
    "PROVISIONING_PROFILE_SPECIFIER": "match AppStore io.tuist.SOAPFT 1750679207"
  ]
)

let project = Project(
    name: "SOAPFT",
    settings: settings,
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
