# LabibaVoiceAssistant Framework

A comprehensive iOS Voice Assistant framework that provides intelligent conversational AI capabilities with support for both Arabic and English languages, voice recognition, text-to-speech, and customizable UI themes.

## Features

### Core Functionality
- 🎤 **Voice Recognition**: Advanced speech-to-text capabilities
- 🔊 **Text-to-Speech**: Natural voice synthesis for bot responses
- 🌐 **Multi-language Support**: Arabic and English language support
- 💬 **Chat Interface**: Rich messaging UI with multiple message types
- 🎨 **Customizable Themes**: Fully customizable UI components
- 📱 **Flexible Presentation**: Sheet and full-screen presentation modes

### Message Types Support
- Text messages (User & Bot)
- Image messages with GIF support
- Choice/Button selections
- Custom cell types
- Typing indicators
- Media attachments

## Installation

### Requirements
- iOS 12.0+
- Swift 5.0+
- Xcode 12.0+

## Quick Start

### 1. Configuration Setup

First, configure the voice assistant with your API endpoints and bot credentials:

```swift
import LabibaVoiceAssistant

// Configure the assistant
let config = ClientConfig(
    baseURL: "https://your-api-base-url.com",
    messagingEndPoint: "/api/messaging",
    voiceEndPoint: "/api/voice",
    voiceURL: "https://your-voice-api-url.com",
    botIdAR: "your-arabic-bot-id",
    botIdEN: "your-english-bot-id"
)

// Set additional configuration
config.timeoutInterval = 60.0
config.listeningDuration = 2.0
config.autoListen = false

// Apply configuration
AssistantConfig.setClientConfig(configuration: config)
```

### 2. Basic Usage

```swift
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegate to handle assistant events
        LabibaVoiceAssistant.shared.delegate = self
        
        // Start the voice assistant
        LabibaVoiceAssistant.shared.start(view: self, type: .Sheet)
    }
}

// MARK: - LabibaVoiceAssistantDelegate
extension ViewController: LabibaVoiceAssistantDelegate {
    
    func onInitSuccess(vc: UIViewController) {
        print("Voice Assistant initialized successfully")
    }
    
    func onError(sheet: UIViewController, error: LabibaErrors) {
        print("Error: \(error.rawValue)")
    }
    
    func onResult(tableView: UITableView, sheet: UIViewController, results: [String: Any]) -> UITableViewCell? {
        // Handle custom results if needed
        return nil
    }
    
    func onMessageSent() {
        print("Message sent successfully")
    }
}
```

## Advanced Configuration

### Voice Settings

Configure voice parameters for both Arabic and English:

```swift
// Set voice types
AssistantConfig.setVoiceMan(ar: "ar-XA-Wavenet-A", en: "en-US-Wavenet-F")

// Configure voice settings
let voice = Voice()
voice.voiceRateEN = 0.7
voice.VoiceRateAR = 0.7
voice.enableAutoListening = true
config.voices = voice
```

### Custom Themes

Customize the appearance of different UI components:

```swift
// Bot message theme
let botTheme = BotChatViewTheme()
// Configure bot theme properties...
AssistantConfig.setBotViewTheme(theme: botTheme)

// User message theme
let userTheme = UserChatViewTheme()
// Configure user theme properties...
AssistantConfig.setUserViewTheme(theme: userTheme)

// Voice assistant view theme
let micTheme = VoiceAssistantViewTheme()
// Configure mic theme properties...
AssistantConfig.setMicViewTheme(theme: micTheme)

// Sheet presentation theme
let sheetTheme = SheetTheme()
// Configure sheet theme properties...
AssistantConfig.setSheetViewTheme(theme: sheetTheme)
```

### Custom Fonts

Set custom fonts for Arabic and English text:

```swift
config.font = (
    regAR: "YourArabicRegularFont",
    boldAR: "YourArabicBoldFont",
    regEN: "YourEnglishRegularFont",
    boldEN: "YourEnglishBoldFont"
)
```

### Custom Cells Registration

Register your custom cell types for specialized message handling:

```swift
// Define your custom cell types
let customCells: [UITableViewCell.Type] = [
    YourCustomMessageCell.self,
    AnotherCustomCell.self
]

// Register with bundle
config.registerCells(cells: customCells, bundle: Bundle.main)
```

### Suggestions Configuration

Set up suggestion prompts for user interactions:

```swift
let suggestions = [
    "How can I help you?",
    "Tell me about your services",
    "What's the weather like?",
    "Schedule an appointment"
]

config.setSuggestions(suggestions: suggestions)
```

## API Methods

### Core Methods

```swift
// Start the assistant with presentation type
LabibaVoiceAssistant.shared.start(view: viewController, type: .Sheet) // or .FullScreen

// Send a message programmatically
LabibaVoiceAssistant.shared.sendMessage(message: "Hello", isAdded: true)

// Show GIF animation
LabibaVoiceAssistant.shared.showGifImage(url: "https://example.com/animation.gif")

// Read custom messages aloud
LabibaVoiceAssistant.shared.readCustomMessage(messages: ["Hello", "How are you?"])

// Add typing indicator
LabibaVoiceAssistant.shared.addTyping()

// Remove typing indicator
LabibaVoiceAssistant.shared.removeTyping(withReload: true)
```

### User Parameters

Set user-specific parameters for personalized interactions:

```swift
config.setUserParams(
    first_name: "John",
    last_name: "Doe",
    email: "john.doe@example.com",
    gender: "male",
    location: "New York",
    country: "USA",
    customParameters: ["preference": "tech"]
)
```

## Presentation Modes

### Sheet Mode (Default)
Presents the assistant as a bottom sheet overlay:

```swift
LabibaVoiceAssistant.shared.start(view: self, type: .Sheet)
```

### Full Screen Mode
Presents the assistant in full-screen mode:

```swift
LabibaVoiceAssistant.shared.start(view: self, type: .FullScreen)
```

## Error Handling

Handle common errors that may occur:

```swift
func onError(sheet: UIViewController, error: LabibaErrors) {
    switch error {
    case .missingConfig:
        print("Configuration is missing. Please set up AssistantConfig first.")
    case .voicesAreRequired:
        print("Voice configuration is required for speech functionality.")
    }
}
```

## Language Support

The framework automatically detects the language of user input and responds accordingly. You can also set the bot language explicitly:

```swift
config.setBotLanguage(LangCode: .arabic) // or .english
```

## SSL Configuration

For development environments, you can bypass SSL certificate validation:

```swift
config.bypassSSLCertificateValidation = true
```

## Best Practices

### 1. Always Configure Before Use
Ensure `AssistantConfig` is properly set up before starting the assistant:

```swift
guard AssistantConfig.getConfig() != nil else {
    print("Configuration required before starting assistant")
    return
}
```

### 2. Handle Delegate Methods
Implement all necessary delegate methods to provide smooth user experience:

```swift
extension YourViewController: LabibaVoiceAssistantDelegate {
    // Implement all required methods
}
```

### 3. Custom Cell Implementation
When implementing custom cells, ensure they conform to the expected protocols and handle data properly.

### 4. Memory Management
The framework handles most memory management, but ensure you properly manage any custom resources or delegates.

## Troubleshooting

### Common Issues

1. **"No such module 'UIKit'" Error**
   - Ensure your project targets iOS and has proper UIKit import statements

2. **Voice Recognition Not Working**
   - Check microphone permissions in Info.plist
   - Verify network connectivity for voice processing

3. **Assistant Not Responding**
   - Verify API endpoints are correctly configured
   - Check network connectivity
   - Ensure bot IDs are valid

4. **Custom Themes Not Applied**
   - Set themes before calling `start()` method
   - Ensure theme objects are properly configured

### Debug Mode

Enable debug logging by setting appropriate log levels in your app's configuration.

## Support

For additional support or questions:
1. Check the inline documentation in the source files
2. Review the delegate method implementations
3. Test with different configuration options
4. Verify API endpoint connectivity

## Version History

- **Current Version**: Check the framework version in your project settings
- Features may vary based on the version you're using

---

**Note**: This framework requires active API endpoints for full functionality. Ensure your backend services are properly configured and accessible. 