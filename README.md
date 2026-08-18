# BusKeyMapper

BusKeyMapper is a macOS application designed to map keyboard inputs seamlessly. It runs as a menu bar application for quick access and minimal intrusion.

## Features

- **Menu Bar Integration:** Quick access from the macOS menu bar.
- **Input Mapping:** Rebind and manage your keyboard inputs efficiently.
- **Lightweight:** Runs in the background without a dock icon (`LSUIElement`).
- **Overlay Support:** Features an on-screen overlay for visual feedback.

## Requirements

- macOS 13.0 or later

## Setup & Build

This project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the `.xcodeproj` file.

1. Ensure you have Xcode installed.
2. Install XcodeGen if you haven't already:
   ```bash
   brew install xcodegen
   ```
3. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```
4. Open `KeyMapper.xcodeproj` and build the project.

## License

This project is licensed under the MIT License.
