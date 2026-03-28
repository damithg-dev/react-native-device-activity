import { requireNativeViewManager } from "expo-modules-core";
import React from "react";
import { Platform, type StyleProp, type ViewStyle } from "react-native";

/**
 * Filter users for DeviceActivityReport.
 * - 'all': Shows data for all users the current iCloud account has permission to see
 * - 'children': Shows data specifically for children in the iCloud family
 */
export type DeviceActivityReportUsers = "children" | "all";

export interface DeviceActivityReportFilter {
  /** Which users to show data for. Defaults to 'all'. */
  users?: DeviceActivityReportUsers;
  /** Date interval for the report. Defaults to today. */
  dateInterval?: {
    /** Start timestamp in milliseconds */
    start: number;
    /** End timestamp in milliseconds */
    end: number;
  };
}

export interface DeviceActivityReportViewProps {
  /** Report context identifier matching a DeviceActivityReportScene in the extension */
  context?: string;
  /** Filter configuration */
  filter?: DeviceActivityReportFilter;
  /** View style */
  style?: StyleProp<ViewStyle>;
}

const NativeReportView = requireNativeViewManager("DeviceActivityReportModule");

/**
 * Renders Apple's DeviceActivityReport as a native SwiftUI view.
 * Requires iOS 16+ and FamilyControls authorization.
 *
 * The report content is provided by the app's DeviceActivityReportExtension.
 * Data is rendered on-device by the extension process — it cannot be extracted programmatically.
 *
 * @example
 * // Parent viewing children's screen time
 * <DeviceActivityReportView
 *   context="totalActivity"
 *   filter={{ users: 'children' }}
 *   style={{ height: 300 }}
 * />
 *
 * @example
 * // Child viewing their own screen time
 * <DeviceActivityReportView
 *   context="totalActivity"
 *   filter={{ users: 'all' }}
 *   style={{ height: 300 }}
 * />
 */
export function DeviceActivityReportView({
  context = "totalActivity",
  filter,
  style,
}: DeviceActivityReportViewProps) {
  if (Platform.OS !== "ios" || parseInt(Platform.Version as string, 10) < 16) {
    return null;
  }

  return (
    <NativeReportView
      context={context}
      filterUsers={filter?.users ?? "all"}
      filterDateStart={filter?.dateInterval?.start}
      filterDateEnd={filter?.dateInterval?.end}
      style={style}
    />
  );
}
