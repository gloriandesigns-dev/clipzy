//
//  SparkleUpdater.swift
//  Clipzy
//
//  Thin wrapper around Sparkle's SPUStandardUpdaterController so the rest
//  of the app (header banner, settings) doesn't need to import Sparkle
//  directly. Sparkle handles the actual download, signature check, and
//  install — this just exposes "is an update available" and "go check/
//  install now" to SwiftUI.
//

import Combine
import Sparkle

final class SparkleUpdater: NSObject, ObservableObject, SPUUpdaterDelegate {
    static let shared = SparkleUpdater()

    @Published private(set) var updateAvailable: Bool = false
    @Published private(set) var latestVersion: String?

    private lazy var controller = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: self,
        userDriverDelegate: nil
    )

    override private init() {
        super.init()
    }

    /// Call once at launch to start Sparkle's background schedule
    /// (interval + automatic-check behavior come from Info.plist).
    func start() {
        _ = controller
    }

    /// User-initiated check, e.g. a "Check for Updates" button in Settings.
    /// Shows Sparkle's own UI for progress / download / install.
    func checkForUpdates() {
        controller.checkForUpdates(nil)
    }

    // SPUUpdaterDelegate: fired when a background check finds a newer version,
    // before Sparkle's own UI appears — lets us light up the header banner too.
    func updater(_: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        DispatchQueue.main.async {
            self.latestVersion = item.displayVersionString
            self.updateAvailable = true
        }
    }

    func updaterDidNotFindUpdate(_: SPUUpdater) {
        DispatchQueue.main.async {
            self.updateAvailable = false
        }
    }
}
