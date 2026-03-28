import ExpoModulesCore
import SwiftUI
import DeviceActivity
import os

private let logger = Logger(subsystem: "ReactNativeDeviceActivity", category: "ReportBridgeView")

/// Bridges Apple's DeviceActivityReport SwiftUI view to React Native via ExpoView + UIHostingController.
/// Supports filtering by users (.all, .children) and date intervals.
@available(iOS 16.0, *)
class DeviceActivityReportBridgeView: ExpoView {
  private var hostingController: UIHostingController<AnyView>?
  private var needsRebuild = true

  // Props set from JS — use setNeedsLayout to debounce rebuilds
  var reportContext: String = "totalActivity" {
    didSet { scheduleRebuild() }
  }
  var filterUsers: String = "all" {
    didSet { scheduleRebuild() }
  }
  var filterDateStart: Double? {
    didSet { scheduleRebuild() }
  }
  var filterDateEnd: Double? {
    didSet { scheduleRebuild() }
  }

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
    clipsToBounds = true
    backgroundColor = .clear
  }

  private func scheduleRebuild() {
    needsRebuild = true
    setNeedsLayout()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    if needsRebuild {
      needsRebuild = false
      rebuildView()
    }

    hostingController?.view.frame = bounds
  }

  private func rebuildView() {
    // Clean up old hosting controller with proper containment
    if let hc = hostingController {
      hc.willMove(toParent: nil)
      hc.view.removeFromSuperview()
      hc.removeFromParent()
      hostingController = nil
    }

    let context = DeviceActivityReport.Context(rawValue: reportContext)
    let users: DeviceActivityFilter.Users = (filterUsers == "children") ? .children : .all

    // Build date interval (default: start of today to now)
    var dateInterval = DateInterval(
      start: Calendar.current.startOfDay(for: Date()),
      end: Date()
    )
    if let start = filterDateStart, let end = filterDateEnd {
      dateInterval = DateInterval(
        start: Date(timeIntervalSince1970: start / 1000),
        end: Date(timeIntervalSince1970: end / 1000)
      )
    }

    let filter = DeviceActivityFilter(
      segment: .daily(during: dateInterval),
      users: users
    )

    logger.info("Building report: context=\(self.reportContext), users=\(self.filterUsers)")

    let reportView = DeviceActivityReport(context, filter: filter)
    let hc = UIHostingController(rootView: AnyView(reportView))
    hc.view.backgroundColor = .clear

    // Proper child view controller containment
    if let parentVC = findViewController() {
      parentVC.addChild(hc)
      addSubview(hc.view)
      hc.didMove(toParent: parentVC)
    } else {
      addSubview(hc.view)
    }

    hostingController = hc
  }

  /// Walk the responder chain to find the nearest UIViewController
  private func findViewController() -> UIViewController? {
    var responder: UIResponder? = self
    while let next = responder?.next {
      if let vc = next as? UIViewController {
        return vc
      }
      responder = next
    }
    return nil
  }
}
