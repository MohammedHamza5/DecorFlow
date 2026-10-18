
# 🏠 ElSweedy for Decoration - Flutter App Icons & Splash Screens
# ملفات أيقونات وشاشة البداية لتطبيق السويدي للديكور

## 📁 هيكل المجلدات:

elsweedy_flutter_icons/
├── master/
│   ├── icon_1024x1024.png          ← للاستخدام مع flutter_launcher_icons
│   └── icon_512x512_playstore.png  ← رفع على Google Play Store
│
├── android/
│   ├── mipmap-mdpi/ic_launcher.png     (48×48)
│   ├── mipmap-hdpi/ic_launcher.png     (72×72)
│   ├── mipmap-xhdpi/ic_launcher.png    (96×96)
│   ├── mipmap-xxhdpi/ic_launcher.png   (144×144)
│   ├── mipmap-xxxhdpi/ic_launcher.png  (192×192)
│   ├── ic_launcher_foreground.png      ← للـ Adaptive Icon
│   └── ic_launcher_background.png      ← للـ Adaptive Icon
│
├── ios/
│   ├── Icon-20@1x.png   (20×20)
│   ├── Icon-20@2x.png   (40×40)
│   ├── Icon-20@3x.png   (60×60)
│   ├── Icon-29@1x.png   (29×29)
│   ├── Icon-29@2x.png   (58×58)
│   ├── Icon-29@3x.png   (87×87)
│   ├── Icon-40@1x.png   (40×40)
│   ├── Icon-40@2x.png   (80×80)
│   ├── Icon-40@3x.png   (120×120)
│   ├── Icon-60@2x.png   (120×120)
│   ├── Icon-60@3x.png   (180×180)
│   ├── Icon-76@1x.png   (76×76)
│   ├── Icon-76@2x.png   (152×152)
│   ├── Icon-83.5@2x.png (167×167)
│   └── Icon-1024.png    (1024×1024) ← App Store
│
└── splash/
    ├── splash_main.png              ← الرئيسي لـ flutter_native_splash
    ├── android_normal.png   (480×800)
    ├── android_large.png    (720×1280)
    ├── android_xxlarge.png  (1080×1920)
    ├── android_xxxlarge.png (1440×2560)
    ├── ios_iphone8.png      (750×1334)
    ├── ios_iphoneX.png      (1125×2436)
    ├── ios_iphone8plus.png  (1242×2208)
    ├── ios_iphone14promax.png (1290×2796)
    ├── ios_ipad_pro.png     (2048×2732)
    └── splash_square_1080.png (1080×1080)

## 🚀 طريقة الاستخدام:

### 1. أيقونة التطبيق (flutter_launcher_icons):
في pubspec.yaml:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon_1024x1024.png"
  adaptive_icon_background: "#1E1C1C"
  adaptive_icon_foreground: "assets/icon/ic_launcher_foreground.png"
```
ثم شغّل: flutter pub run flutter_launcher_icons

### 2. شاشة البداية (flutter_native_splash):
في pubspec.yaml:
```yaml
dev_dependencies:
  flutter_native_splash: ^2.3.0

flutter_native_splash:
  color: "#1E1C1C"
  image: assets/splash/splash_main.png
  android: true
  ios: true
```
ثم شغّل: dart run flutter_native_splash:create
