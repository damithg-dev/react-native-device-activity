const getAppGroupFromExpoConfig = require("react-native-device-activity/config-plugin/getAppGroupFromExpoConfig");

/**
 * DeviceActivityReport extension configuration.
 *
 * Note: expo-apple-targets does not yet support "device-activity-report" as a known type.
 * We use the raw NSExtensionPointIdentifier via the Info.plist instead.
 * The target is registered as a generic extension and the Info.plist defines
 * the correct extension point (com.apple.deviceactivity.report-extension).
 *
 * @type {import('@kingstinct/expo-apple-targets/build/config-plugin').ConfigFunction}
 */
module.exports = (config) => {
  const appGroup = getAppGroupFromExpoConfig(config);

  return {
    // Use "device-activity-monitor" as the base type since expo-apple-targets
    // doesn't support "device-activity-report" yet. The Info.plist overrides
    // the NSExtensionPointIdentifier to the correct report extension value.
    type: "device-activity-monitor",
    entitlements: {
      "com.apple.developer.family-controls": true,
      "com.apple.security.application-groups": [appGroup],
    },
  };
};
