import DeviceActivity
import SwiftUI
import os

private let logger = Logger(subsystem: "DeviceActivityReportExtension", category: "Report")

/// Default DeviceActivityReport extension scaffold.
/// Consuming apps should customize the report scenes to match their design.
///
/// Register report scenes by returning DeviceActivityReportScene instances.
/// Each scene receives DeviceActivityResults in makeConfiguration() and
/// returns a SwiftUI view configuration.
@available(iOS 16.0, *)
extension DeviceActivityReportExtension: DeviceActivityReportScene {

  var body: some DeviceActivityReportScene {
    TotalActivityReport { totalActivity in
      TotalActivityView(totalActivity: totalActivity)
    }
  }
}

// MARK: - Total Activity Report

@available(iOS 16.0, *)
struct TotalActivityReport: DeviceActivityReportScene {
  let context: DeviceActivityReport.Context = .init(rawValue: "totalActivity")
  let content: (ActivityReport) -> TotalActivityView

  func makeConfiguration(
    representing data: DeviceActivityResults<DeviceActivityData>
  ) async -> ActivityReport {
    logger.info("makeConfiguration called — processing DeviceActivityResults")

    var totalDuration: TimeInterval = 0
    var categoryDurations: [String: TimeInterval] = [:]
    var topApps: [(name: String, duration: TimeInterval)] = []
    var segmentCount = 0
    var appCount = 0

    for await activityData in data {
      logger.debug("Processing activityData entry")
      for await segment in activityData.activitySegments {
        segmentCount += 1
        totalDuration += segment.totalActivityDuration
        logger.debug("Segment \(segmentCount): duration=\(segment.totalActivityDuration, privacy: .public)s")

        for await category in segment.categories {
          let categoryName = category.category.localizedDisplayName ?? "Other"
          categoryDurations[categoryName, default: 0] += category.totalActivityDuration
          logger.debug("  Category: \(categoryName, privacy: .public) = \(category.totalActivityDuration, privacy: .public)s")

          for await app in category.applications {
            appCount += 1
            let appName = app.application.localizedDisplayName ?? "Unknown"
            let duration = app.totalActivityDuration
            if duration > 0 {
              topApps.append((name: appName, duration: duration))
            }
            // Cap at 10 apps to avoid memory pressure
            if appCount >= 10 {
              logger.debug("  Reached 10 app limit, stopping app enumeration for this category")
              break
            }
          }
        }
      }
    }

    // Sort and take top 10 apps
    topApps.sort { $0.duration > $1.duration }
    let limitedApps = Array(topApps.prefix(10))

    logger.info("Report complete: total=\(Int(totalDuration), privacy: .public)s, categories=\(categoryDurations.count, privacy: .public), apps=\(limitedApps.count, privacy: .public), segments=\(segmentCount, privacy: .public)")

    return ActivityReport(
      totalDuration: totalDuration,
      categories: categoryDurations,
      topApps: limitedApps.map { AppUsage(name: $0.name, duration: $0.duration) }
    )
  }
}

// MARK: - Data Models

struct ActivityReport {
  let totalDuration: TimeInterval
  let categories: [String: TimeInterval]
  let topApps: [AppUsage]
}

struct AppUsage {
  let name: String
  let duration: TimeInterval

  var formattedDuration: String {
    let hours = Int(duration) / 3600
    let minutes = (Int(duration) % 3600) / 60
    if hours > 0 {
      return "\(hours)h \(minutes)m"
    }
    return "\(minutes)m"
  }
}

// MARK: - SwiftUI Views

@available(iOS 16.0, *)
struct TotalActivityView: View {
  let totalActivity: ActivityReport

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Total
      HStack {
        Text("Total Screen Time")
          .font(.headline)
        Spacer()
        Text(formatDuration(totalActivity.totalDuration))
          .font(.title2)
          .fontWeight(.bold)
      }

      Divider()

      // Categories
      if !totalActivity.categories.isEmpty {
        Text("Categories")
          .font(.subheadline)
          .foregroundColor(.secondary)

        ForEach(
          totalActivity.categories.sorted(by: { $0.value > $1.value }),
          id: \.key
        ) { category, duration in
          HStack {
            Text(category)
            Spacer()
            Text(formatDuration(duration))
              .foregroundColor(.secondary)
          }
        }
      }

      // Top Apps
      if !totalActivity.topApps.isEmpty {
        Divider()
        Text("Top Apps")
          .font(.subheadline)
          .foregroundColor(.secondary)

        ForEach(totalActivity.topApps.prefix(5), id: \.name) { app in
          HStack {
            Text(app.name)
            Spacer()
            Text(app.formattedDuration)
              .foregroundColor(.secondary)
          }
        }
      }
    }
    .padding()
  }

  private func formatDuration(_ seconds: TimeInterval) -> String {
    let hours = Int(seconds) / 3600
    let minutes = (Int(seconds) % 3600) / 60
    if hours > 0 {
      return "\(hours)h \(minutes)m"
    }
    return "\(minutes)m"
  }
}
