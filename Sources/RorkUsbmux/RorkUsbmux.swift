import Foundation
@_exported import Minimuxer

@_silgen_name("rork_usbmux_set_instproxy_install_client_options_xml")
private func _rork_usbmux_set_instproxy_install_client_options_xml(
    _ plistXml: UnsafePointer<CChar>?,
    _ length: UInt32
)

@_silgen_name("rork_usbmux_clear_instproxy_install_client_options")
private func _rork_usbmux_clear_instproxy_install_client_options()

@_silgen_name("rork_usbmux_copy_instproxy_last_error_message")
private func _rork_usbmux_copy_instproxy_last_error_message() -> UnsafeMutablePointer<CChar>?

@_silgen_name("rork_usbmux_free_instproxy_error_message")
private func _rork_usbmux_free_instproxy_error_message(_ message: UnsafeMutablePointer<CChar>?)

public typealias RorkUsbmuxError = MinimuxerError
public typealias RorkUsbmuxTunnelConfigBinding = TunnelConfigBinding
public typealias RorkUsbmuxDirectoryEntry = RustDirectoryEntry
public typealias RorkUsbmuxRawPacket = RawPacket
public typealias RorkUsbmuxDevice = Device
public typealias RorkUsbmuxNetInfo = NetInfo
public typealias RorkUsbmuxInstallProvider = InstallProvider
public typealias RorkUsbmuxProvisionProvider = ProvisionProvider
public typealias RorkUsbmuxMounterProvider = MounterProvider

public struct RorkUsbmuxValidationStatus: Equatable, Sendable, CustomStringConvertible {
    public let started: Bool
    public let usbmuxdReady: Bool
    public let isRemotePairing: Bool
    public let deviceAddress: String?
    public let deviceReachable: Bool
    public let udid: String?
    public let expectedUDID: String?
    public let heartbeatReady: Bool

    public var transportReady: Bool {
        isRemotePairing || usbmuxdReady
    }

    public var isReady: Bool {
        started && transportReady && deviceReachable && udidMatches && heartbeatReady
    }

    public var udidMatches: Bool {
        guard let expectedUDID else {
            return udid != nil
        }
        return udid == expectedUDID
    }

    public var description: String {
        [
            "started=\(started)",
            "usbmuxdReady=\(usbmuxdReady)",
            "transportReady=\(transportReady)",
            "remotePairing=\(isRemotePairing)",
            "address=\(deviceAddress ?? "nil")",
            "reachable=\(deviceReachable)",
            "udid=\(udid ?? "nil")",
            "expectedUDID=\(expectedUDID ?? "nil")",
            "heartbeat=\(heartbeatReady)",
        ].joined(separator: " ")
    }
}

public enum RorkUsbmuxValidationError: LocalizedError, CustomStringConvertible, Equatable, Sendable {
    case muxerNotStarted(RorkUsbmuxValidationStatus)
    case usbmuxdNotReady(RorkUsbmuxValidationStatus)
    case deviceAddressMissing(RorkUsbmuxValidationStatus)
    case deviceUnreachable(RorkUsbmuxValidationStatus)
    case deviceDiscoveryFailed(RorkUsbmuxValidationStatus)
    case unexpectedDevice(expectedUDID: String, actualUDID: String, status: RorkUsbmuxValidationStatus)
    case trustedLockdownSessionRejected(RorkUsbmuxValidationStatus)

    public var status: RorkUsbmuxValidationStatus {
        switch self {
        case let .muxerNotStarted(status),
             let .usbmuxdNotReady(status),
             let .deviceAddressMissing(status),
             let .deviceUnreachable(status),
             let .deviceDiscoveryFailed(status),
             let .trustedLockdownSessionRejected(status):
            return status
        case let .unexpectedDevice(_, _, status):
            return status
        }
    }

    public var errorDescription: String? {
        switch self {
        case let .muxerNotStarted(status):
            return "usbmux validation failed: minimuxer is not started. \(status)"
        case let .usbmuxdNotReady(status):
            return "usbmux validation failed: local usbmuxd listener is not ready. \(status)"
        case let .deviceAddressMissing(status):
            return "usbmux validation failed: device tunnel address is missing. \(status)"
        case let .deviceUnreachable(status):
            return "usbmux validation failed: device tunnel is not reachable. \(status)"
        case let .deviceDiscoveryFailed(status):
            return "usbmux validation failed: device discovery through usbmuxd failed. \(status)"
        case let .unexpectedDevice(expectedUDID, actualUDID, status):
            return "usbmux validation failed: expected device \(expectedUDID), but usbmuxd returned \(actualUDID). \(status)"
        case let .trustedLockdownSessionRejected(status):
            return "usbmux validation failed: lockdownd did not accept the trusted pairing profile. \(status)"
        }
    }

    public var description: String {
        errorDescription ?? "usbmux validation failed"
    }
}

public struct RorkUsbmuxInstallClientOptionKey: RawRepresentable, Hashable, ExpressibleByStringLiteral, Sendable {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public static let bundleIdentifier = Self("CFBundleIdentifier")
    public static let applicationSINF = Self("ApplicationSINF")
    public static let applicationType = Self("ApplicationType")
    public static let bundleIDs = Self("BundleIDs")
    public static let iTunesMetadata = Self("iTunesMetadata")
    public static let packageType = Self("PackageType")
    public static let returnAttributes = Self("ReturnAttributes")
    public static let skipUninstall = Self("SkipUninstall")
}

public struct RorkUsbmuxInstallClientOptions: Equatable, ExpressibleByDictionaryLiteral, Sendable {
    public typealias Key = RorkUsbmuxInstallClientOptionKey
    public typealias Value = String

    public static let empty = RorkUsbmuxInstallClientOptions()

    public var stringValues: [String: String]

    public init(_ stringValues: [String: String] = [:]) {
        self.stringValues = stringValues
    }

    public init(_ values: [Key: String]) {
        self.stringValues = Dictionary(
            uniqueKeysWithValues: values.map { ($0.key.rawValue, $0.value) }
        )
    }

    public init(dictionaryLiteral elements: (Key, String)...) {
        self.stringValues = elements.reduce(into: [:]) { options, element in
            options[element.0.rawValue] = element.1
        }
    }

    public subscript(key: Key) -> String? {
        get {
            stringValues[key.rawValue]
        }
        set {
            stringValues[key.rawValue] = newValue
        }
    }

    var isEmpty: Bool {
        stringValues.isEmpty
    }

    func xmlData() throws -> Data {
        try PropertyListSerialization.data(
            fromPropertyList: stringValues,
            format: .xml,
            options: 0
        )
    }
}

private enum RorkUsbmuxInstallClientOptionsScope {
    static func withOptions<T>(
        _ clientOptions: RorkUsbmuxInstallClientOptions,
        _ body: () throws -> T
    ) throws -> T {
        guard !clientOptions.isEmpty else {
            return try body()
        }

        let data = try clientOptions.xmlData()
        data.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress?.assumingMemoryBound(to: CChar.self) else {
                return
            }

            _rork_usbmux_set_instproxy_install_client_options_xml(
                baseAddress,
                UInt32(data.count)
            )
        }

        defer {
            _rork_usbmux_clear_instproxy_install_client_options()
        }

        return try body()
    }
}

public enum RorkUsbmux {
    public static func describeError(_ error: RorkUsbmuxError) -> String {
        Minimuxer.describeError(error)
    }

    public static func setDebug(_ enabled: Bool) {
        Minimuxer.setDebug(enabled)
    }

    public static func bindTunnelConfig(_ binding: RorkUsbmuxTunnelConfigBinding) {
        Minimuxer.bindTunnelConfig(binding)
    }

    public static func ready() -> Bool {
        Minimuxer.ready()
    }

    public static func start(pairingFile: String, logPath: String) throws {
        try Minimuxer.start(pairingFile: pairingFile, logPath: logPath)
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

    public static func retargetUsbmuxdAddr() {
        Minimuxer.retargetUsbmuxdAddr()
    }

    public static func retargetUsbmuxdAddress() {
        Minimuxer.retargetUsbmuxdAddr()
    }

    public static func fetchUDID() -> String? {
        Minimuxer.fetchUDID()
    }

    public static func testDeviceConnection(ifaddr: String?) -> Bool {
        Minimuxer.testDeviceConnection(ifaddr: ifaddr)
    }

    public static func testDeviceConnection(address: String?) -> Bool {
        Minimuxer.testDeviceConnection(ifaddr: address)
    }

    public static func validationStatus(
        deviceAddress: String?,
        expectedUDID: String? = nil
    ) -> RorkUsbmuxValidationStatus {
        retargetUsbmuxdAddr()
        let started = RorkUsbmuxMuxer.started
        let usbmuxdReady = RorkUsbmuxMuxer.usbmuxdReady
        let isRemotePairing = RorkUsbmuxMuxer.isRemotePairing
        let effectiveAddress = deviceAddress ?? (isRemotePairing ? "10.7.0.1" : nil)
        let deviceReachable = testDeviceConnection(address: effectiveAddress)
        let transportReady = isRemotePairing || usbmuxdReady
        let udid = started && transportReady && deviceReachable ? fetchUDID() : nil
        let heartbeatReady = isRemotePairing || RorkUsbmuxHeartbeat.lastBeatSuccessful

        return RorkUsbmuxValidationStatus(
            started: started,
            usbmuxdReady: usbmuxdReady,
            isRemotePairing: isRemotePairing,
            deviceAddress: effectiveAddress,
            deviceReachable: deviceReachable,
            udid: udid,
            expectedUDID: expectedUDID,
            heartbeatReady: heartbeatReady
        )
    }

    @discardableResult
    public static func validateConnection(
        deviceAddress: String?,
        expectedUDID: String? = nil
    ) throws -> RorkUsbmuxValidationStatus {
        let status = validationStatus(deviceAddress: deviceAddress, expectedUDID: expectedUDID)

        guard status.started else {
            throw RorkUsbmuxValidationError.muxerNotStarted(status)
        }

        guard status.transportReady else {
            throw RorkUsbmuxValidationError.usbmuxdNotReady(status)
        }

        guard status.deviceAddress != nil else {
            throw RorkUsbmuxValidationError.deviceAddressMissing(status)
        }

        guard status.deviceReachable else {
            throw RorkUsbmuxValidationError.deviceUnreachable(status)
        }

        guard let udid = status.udid else {
            throw RorkUsbmuxValidationError.deviceDiscoveryFailed(status)
        }

        if let expectedUDID, udid != expectedUDID {
            throw RorkUsbmuxValidationError.unexpectedDevice(
                expectedUDID: expectedUDID,
                actualUDID: udid,
                status: status
            )
        }

        guard status.heartbeatReady else {
            throw RorkUsbmuxValidationError.trustedLockdownSessionRejected(status)
        }

        return status
    }

    public static func stageApp(bundleId: String, ipaBytes: Data) throws {
        try Minimuxer.yeetAppAfc(bundleId: bundleId, ipaBytes: ipaBytes)
    }

    public static func installApp(bundleId: String) throws {
        try Minimuxer.installIpa(bundleId: bundleId)
    }

    public static func installApp(
        bundleId: String,
        clientOptions: RorkUsbmuxInstallClientOptions
    ) throws {
        try RorkUsbmuxInstallClientOptionsScope.withOptions(clientOptions) {
            try Minimuxer.installIpa(bundleId: bundleId)
        }
    }

    public static func lastInstallProxyErrorMessage() -> String? {
        guard let pointer = _rork_usbmux_copy_instproxy_last_error_message() else {
            return nil
        }
        defer {
            _rork_usbmux_free_instproxy_error_message(pointer)
        }

        let message = String(cString: pointer).trimmingCharacters(in: .whitespacesAndNewlines)
        return message.isEmpty ? nil : message
    }

    public static func removeApp(bundleId: String) throws {
        try Minimuxer.removeApp(bundleId: bundleId)
    }

    public static func debugApp(appId: String) throws {
        try Minimuxer.debugApp(appId: appId)
    }

    public static func attachDebugger(pid: UInt32) throws {
        try Minimuxer.attachDebugger(pid: pid)
    }

    public static func startAutoMounter(docsPath: String) {
        Minimuxer.startAutoMounter(docsPath: docsPath)
    }

    public static func installProvisioningProfile(profile: Data) throws {
        try Minimuxer.installProvisioningProfile(profile: profile)
    }

    public static func removeProvisioningProfile(id: String) throws {
        try Minimuxer.removeProvisioningProfile(id: id)
    }

    public static func dumpProfiles(docsPath: String) throws -> String {
        try Minimuxer.dumpProfiles(docsPath: docsPath)
    }
}

public enum RorkUsbmuxAFC {
    public static func remove(path: String) throws {
        try AfcFileManager.remove(path: path)
    }

    public static func createDirectory(path: String) throws {
        try AfcFileManager.createDirectory(path: path)
    }

    public static func writeFile(to path: String, bytes: Data) throws {
        try AfcFileManager.writeFile(to: path, bytes: bytes)
    }

    public static func copyFileOutsideAfc(from sourcePath: String, to destinationPath: String) throws {
        try AfcFileManager.copyFileOutsideAfc(from: sourcePath, to: destinationPath)
    }

    public static func contents() -> [RorkUsbmuxDirectoryEntry] {
        AfcFileManager.contents()
    }
}

public enum RorkUsbmuxInstall {
    public static var provider: RorkUsbmuxInstallProvider? {
        get { Install.provider }
        set { Install.provider = newValue }
    }

    public static func stageApp(bundleId: String, ipaBytes: Data) throws {
        try Install.yeetAppAfc(bundleId: bundleId, ipaBytes: ipaBytes)
    }

    public static func installApp(bundleId: String) throws {
        try Install.installIpa(bundleId: bundleId)
    }

    public static func installApp(
        bundleId: String,
        clientOptions: RorkUsbmuxInstallClientOptions
    ) throws {
        try RorkUsbmuxInstallClientOptionsScope.withOptions(clientOptions) {
            try Install.installIpa(bundleId: bundleId)
        }
    }

    public static func removeApp(bundleId: String) throws {
        try Install.removeApp(bundleId: bundleId)
    }
}

public enum RorkUsbmuxMounter {
    public static var provider: RorkUsbmuxMounterProvider? {
        get { Mounter.provider }
        set { Mounter.provider = newValue }
    }

    public static var dmgMounted: Bool {
        Mounter.dmgMounted
    }

    public static func startAutoMounter(docsPath: String) {
        Mounter.startAutoMounter(docsPath: docsPath)
    }
}

public enum RorkUsbmuxProvisioning {
    public static var provider: RorkUsbmuxProvisionProvider? {
        get { Provision.provider }
        set { Provision.provider = newValue }
    }

    public static func installProfile(_ profile: Data) throws {
        try Provision.installProvisioningProfile(profile: profile)
    }

    public static func removeProfile(id: String) throws {
        try Provision.removeProvisioningProfile(id: id)
    }

    public static func dumpProfiles(docsPath: String) throws -> String {
        try Provision.dumpProfiles(docsPath: docsPath)
    }
}

public enum RorkUsbmuxJIT {
    public static func debugApp(appId: String) throws {
        try JIT.debugApp(appId: appId)
    }

    public static func attachDebugger(pid: UInt32) throws {
        try JIT.attachDebugger(pid: pid)
    }
}

public enum RorkUsbmuxMuxer {
    public static var started: Bool {
        get { Muxer.started }
        set { Muxer.started = newValue }
    }

    public static var usbmuxdReady: Bool {
        get { Muxer.usbmuxdReady }
        set { Muxer.usbmuxdReady = newValue }
    }

    public static var isRemotePairing: Bool {
        get { Muxer.isrppairing }
        set { Muxer.isrppairing = newValue }
    }

    public static func retargetUsbmuxdAddr() {
        Muxer.retargetUsbmuxdAddr()
    }

    public static func start(pairingFile: String, logPath: String) throws {
        try Muxer.start(pairingFile: pairingFile, logPath: logPath)
    }

    public static func notifyDeviceAttached(deviceIP: String) {
        Muxer.notifyDeviceAttached(deviceIP: deviceIP)
    }

    public static func notifyDeviceDetached() {
        Muxer.notifyDeviceDetached()
    }
}

public enum RorkUsbmuxHeartbeat {
    public static var lastBeatSuccessful: Bool {
        get { Heartbeat.lastBeatSuccessful }
        set { Heartbeat.lastBeatSuccessful = newValue }
    }

    public static func startBeat() {
        Heartbeat.startBeat()
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

    @discardableResult
    public static func stop() -> Bool {
        NetworkObserver.shared.stop()
    }
}
