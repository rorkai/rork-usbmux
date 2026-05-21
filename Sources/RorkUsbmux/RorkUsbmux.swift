import Foundation
@_exported import Minimuxer

public typealias RorkUsbmuxError = MinimuxerError
public typealias RorkUsbmuxTunnelConfigBinding = TunnelConfigBinding

public enum RorkUsbmux {
    public static func bindTunnelConfig(_ binding: RorkUsbmuxTunnelConfigBinding) {
        Minimuxer.bindTunnelConfig(binding)
    }

    public static func retargetUsbmuxdAddr() {
        Minimuxer.retargetUsbmuxdAddr()
    }

    public static func startWithLogger(
        pairingFile: String,
        logPath: String,
        isConsoleLoggingEnabled: Bool
    ) throws {
        try Minimuxer.startWithLogger(
            pairingFile: pairingFile,
            logPath: logPath,
            isConsoleLoggingEnabled: isConsoleLoggingEnabled
        )
    }

    public static func ready() -> Bool {
        Minimuxer.ready()
    }

    public static func stageApp(bundleId: String, ipaBytes: Data) throws {
        try Minimuxer.yeetAppAfc(bundleId: bundleId, ipaBytes: ipaBytes)
    }

    public static func installApp(bundleId: String) throws {
        try Minimuxer.installIpa(bundleId: bundleId)
    }

    public static func describeError(_ error: RorkUsbmuxError) -> String {
        Minimuxer.describeError(error)
    }
}

public enum RorkUsbmuxNetworkObserver {
    @discardableResult
    public static func start() -> Bool {
        NetworkObserver.shared.start()
    }

    public static func refreshEndpoint() {
        NetworkObserver.shared.refreshEndpoint()
    }
}
