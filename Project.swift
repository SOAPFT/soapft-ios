import ProjectDescription

let project = Project(
    name: "SOAPFT",
    targets: [
        .target(
            name: "SOAPFT",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.SOAPFT",
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleIconName": "AppIcon", // 아이콘 이름 지정
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["SOAPFT/Sources/**"],
            resources: ["SOAPFT/Resources/**"], // AppIcon 포함돼야 함
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
