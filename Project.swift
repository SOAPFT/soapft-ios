import ProjectDescription

let settings = Settings.settings(
  base: [
    "CODE_SIGN_STYLE": "Manual",
    "CODE_SIGN_IDENTITY": "Apple Distribution"
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
