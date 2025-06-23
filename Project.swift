import ProjectDescription

let settings = Settings.settings(
  base: [
    "CODE_SIGN_STYLE": "Manual",       // ✅ 수동 서명 방식
    "CODE_SIGN_IDENTITY": "Apple Distribution",
    "DEVELOPMENT_TEAM": ProcessInfo.processInfo.environment["DEVELOPMENT_TEAM"] ?? "",
    "PROVISIONING_PROFILE_SPECIFIER": ProcessInfo.processInfo.environment["PROFILE_SPECIFIER"] ?? ""
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
