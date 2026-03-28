import ExpoModulesCore

/// Expo module that registers the DeviceActivityReportBridgeView as a native view
/// accessible from React Native via requireNativeViewManager.
@available(iOS 16.0, *)
public class DeviceActivityReportModule: Module {
  public func definition() -> ExpoModulesCore.ModuleDefinition {
    Name("DeviceActivityReportModule")

    View(DeviceActivityReportBridgeView.self) {
      Prop("context") { (view: DeviceActivityReportBridgeView, prop: String) in
        view.reportContext = prop
      }

      Prop("filterUsers") { (view: DeviceActivityReportBridgeView, prop: String) in
        view.filterUsers = prop
      }

      Prop("filterDateStart") { (view: DeviceActivityReportBridgeView, prop: Double?) in
        view.filterDateStart = prop
      }

      Prop("filterDateEnd") { (view: DeviceActivityReportBridgeView, prop: Double?) in
        view.filterDateEnd = prop
      }
    }
  }
}
