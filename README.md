<div align="center">
<h1>Flutter Text Recognition</h4>
<h3>UAS Mata Kuliah Pengolahan Citra</h3>
</div>

## 🚀 Getting Started

Follow these instructions to set up and run the project locally.

## ⚙️ Prerequisites

Make sure you have the following installed on your system:
```
Flutter SDK (3.35.3 or higher)
Git
Android Studio (For Android Development)
Xcode (For ios development)
```

## 📥 Installation

1. Clone the repository:

```
git clone https://github.com/bert093/Flutter-Text-Recognition.git
```

2. Navigate to project directory:

```
cd flutter-text-recognition
```

3. Install dependencies:

```
flutter pub get
```

4. Run the application:

```
flutter run
```

## 🛠️ Technologies Used

This project is built using:

### Framework & Language
- [x] Flutter - Cross platform framework
- [x] Dart - Programming language

### Packages & Dependencies
- [x] Google ML Kit (packages) - Text Recognition API
- [x] Camera (packages) - Real-time camera access
- [x] Image Picker (packages) - Gallery image selection
- [x] Permission Handler (packages) - Runtime permission

## 📁 Project Structure

```
flutter_text_recognition
├─ android/
├─ ios/
├─ lib/
│  ├─ camera/
│  │  └─ camera_new.dart
│  └─ main.dart
├─ linux/
├─ macos/
├─ web/
└─ windows/
├─ .gitignore
├─ analysis_options.yaml
├─ .metadata
├─ pubspec.lock
├─ pubspec.yaml
├─ README.md
```

## ✨ Features

- Real-time text detection from camera
- Image text recognition from gallery
- Terminal logging for debugging
- Camera & Storage permission handling