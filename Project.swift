import ProjectDescription

let project = Project(
    name: "SOAPFT",
    packages: [
        .package(url: "https://github.com/MessageKit/MessageKit.git", .upToNextMajor(from: "4.3.0")),
        .package(url: "https://github.com/nathantannar4/InputBarAccessoryView.git", .upToNextMajor(from: "6.5.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.0.0"))
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
                    ]
                ]
            ),
            sources: ["SOAPFT/Sources/**"],
            resources: ["SOAPFT/Resources/**"],
            dependencies: [
                // ✅ MessageKit 관련
                .package(product: "MessageKit"),
                .package(product: "InputBarAccessoryView"),
                .package(product: "Kingfisher")
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
