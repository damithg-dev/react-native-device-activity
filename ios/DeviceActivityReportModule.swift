import ExpoModulesCore
import os

private let reportModuleLogger = Logger(subsystem: "ReactNativeDeviceActivity", category: "ReportModule")

/// Expo module that registers the DeviceActivityReportBridgeView as a native view
/// accessible from React Native via requireNativeViewManager.
@available(iOS 16.0, *)
public class DeviceActivityReportModule: Module {
  public func definition() -> ExpoModulesCore.ModuleDefinition {
    Name("DeviceActivityReportModule")

    OnCreate {
      reportModuleLogger.info("DeviceActivityReportModule created")
    }

    View(DeviceActivityReportBridgeView.self) {
      Prop("context") { (view: DeviceActivityReportBridgeView, prop: String) in
        reportModuleLogger.debug("Prop set: context=\(prop, privacy: .public)")
        view.reportContext = prop
      }

      Prop("filterUsers") { (view: DeviceActivityReportBridgeView, prop: String) in
        reportModuleLogger.debug("Prop set: filterUsers=\(prop, privacy: .public)")
        view.filterUsers = prop
      }

      Prop("filterDateStart") { (view: DeviceActivityReportBridgeView, prop: Double?) in
        reportModuleLogger.debug("Prop set: filterDateStart=\(prop ?? 0, privacy: .public)")
        view.filterDateStart = prop
      }

      Prop("filterDateEnd") { (view: DeviceActivityReportBridgeView, prop: Double?) in
        reportModuleLogger.debug("Prop set: filterDateEnd=\(prop ?? 0, privacy: .public)")
        view.filterDateEnd = prop
      }
    }
  }
}
