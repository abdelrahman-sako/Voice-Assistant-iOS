// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Voice-Assistant-iOS",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Voice-Assistant-iOS",
            targets: ["Voice-Assistant-iOS"]),
    ],
    targets: [
        .target(
            name: "Voice-Assistant-iOS",
            path: "VoiceAssistant",
            resources: [
                .process("View/Cells/BotTextMessageCell.xib"),
                .process("View/Cells/ImageCell/ImageCell.xib"),
                .process("View/Cells/ChoicesCell/ChoicesCell.xib"),
                .process("View/Cells/ChipCell/ChipCell.xib"),
                .process("View/Cells/SuggestionCell/SuggestionCell.xib"),
                .process("View/Cells/UserCell/UserTextMessageCell.xib"),
                .process("View/Cells/TypingCell/TypingCell.xib"),
                .process("View/Controllers/VoiceAssistantController/VoiceAssistantViewController.xib"),
                .process("View/Controllers/VoiceAssistantController/FullScreen/VoiceFullScreenViewController.xib"),
                .process("View/Controllers/ImageController/ImageViewController.xib"),
                .process("View/Custom/VoiceAssistantView/VoiceAssistantView.xib"),
                .process("Assets.xcassets"),
                .process("loading.gif")
            ]
        ),
        .testTarget(
            name: "VoiceAssistantTests",
            dependencies: ["Voice-Assistant-iOS"],
            path: "VoiceAssistantTests"
        )
    ]
)
