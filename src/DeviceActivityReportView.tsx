import type { DeviceActivityReportViewProps } from "./DeviceActivityReportView.ios";

/**
 * Non-iOS stub — DeviceActivityReport is only available on iOS 16+.
 * Returns null on all other platforms.
 */
export function DeviceActivityReportView(_props: DeviceActivityReportViewProps) {
  return null;
}

export type {
  DeviceActivityReportViewProps,
  DeviceActivityReportFilter,
  DeviceActivityReportUsers,
} from "./DeviceActivityReportView.ios";
