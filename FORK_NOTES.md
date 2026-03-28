# Fork Notes — damithg-dev/react-native-device-activity

**Upstream:** [kingstinct/react-native-device-activity](https://github.com/kingstinct/react-native-device-activity)
**Fork created:** 2026-03-28
**Upstream version at fork:** v0.5.3 (commit `30e57ad`)

## Changes vs upstream

### 1. DeviceActivityReport native bridge (NEW)
- `ios/DeviceActivityReportBridgeView.swift` — ExpoView wrapping Apple's DeviceActivityReport via UIHostingController
- `ios/DeviceActivityReportModule.swift` — Expo module registering the bridge view
- `src/DeviceActivityReportView.ios.tsx` — React Native component with TypeScript types
- `src/DeviceActivityReportView.tsx` — Non-iOS stub
- Supports `DeviceActivityFilter(users: .children)` for parent viewing child screen time

### 2. DeviceActivityReportExtension scaffold (NEW)
- `targets/DeviceActivityReportExtension/` — Default report extension with TotalActivityReport scene
- `expo-target.config.js` — Config plugin integration

### 3. FamilyActivitySelection decode fix (BUG FIX)
- `ios/ReactNativeDeviceActivityModule.swift` — Changed `.map` to `.compactMap` for FamilyActivitySelection decoding
- Bad base64 tokens now return `nil` (skip category) instead of `FamilyActivitySelection()` (monitor ALL apps)
- Prevents N× screen time inflation when category tokens are corrupted

## Dependencies
- Targets `@kingstinct/expo-apple-targets` v0.1.19
- `device-activity-report` type is NOT yet in expo-apple-targets — uses `device-activity-monitor` as base type with Info.plist override

## Upstream sync plan
- Check upstream monthly for updates
- Submit decode fix as upstream PR
- DeviceActivityReport feature is a larger addition — evaluate upstreaming after stabilization
