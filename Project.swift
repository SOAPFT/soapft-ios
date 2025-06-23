import ProjectDescription

let project = Project(
    name: "SOAPFT",
    settings: Settings.settings(
        base: [
            "DEVELOPMENT_TEAM": "MHD24ZMA79",
            "CODE_SIGN_STYLE": "Manual"
        ],
        configurations: [
            .debug(name: "Debug", settings: [
                "CODE_SIGN_IDENTITY": "Apple Development",
                "PROVISIONING_PROFILE_SPECIFIER": "match Development io.tuist.SOAPFT"
            ]),
            .release(name: "Release", settings: [
                "CODE_SIGN_IDENTITY": "Apple Distribution",
                "PROVISIONING_PROFILE_SPECIFIER": "match AppStore io.tuist.SOAPFT 1750692394"
            ])
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
            dependencies: [.target(name: "SOAPFT")]
        )
    ]
)
