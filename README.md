# RorkUsbmux

> Deprecated: RorkUsbmux is no longer maintained. Use
> [rork-device](https://github.com/rorkai/rork-device) for new iOS device
> communication and app-install workflows.

RorkUsbmux is a Rork-maintained Swift Package that makes
[SideStore MiniMuxer](https://github.com/SideStore/minimuxer) usable from Swift
apps without requiring downstream projects to wire native libimobiledevice,
libplist, libusbmuxd, or OpenSSL build settings by hand.

The package exposes a Swift facade for MiniMuxer's public workflows and packages
the native dependencies needed by those workflows:

- start and monitor MiniMuxer
- bind tunnel configuration and retarget `USBMUXD_SOCKET_ADDRESS`
- fetch device identity and readiness state
- stage, install, and remove apps
- start JIT/debug flows
- mount developer disk images
- install, remove, and dump provisioning profiles
- read/write AFC files
- observe VPN/network endpoint changes

## Installation

RorkUsbmux is deprecated and is not expected to receive maintenance or feature
updates. The install steps below are kept for existing consumers that still need
to resolve the package.

Add this package in Xcode:

```text
https://github.com/rorkai/rork-usbmux.git
```

Then add the `RorkUsbmux` product to your app target and import it:

```swift
import RorkUsbmux
```

## Example

```swift
import Foundation
import RorkUsbmux

let pairingPlist = try String(contentsOfFile: pairingFilePath, encoding: .utf8)

try RorkUsbmux.startWithLogger(
    pairingFile: pairingPlist,
    logPath: logDirectoryPath,
    isConsoleLoggingEnabled: true
)

RorkUsbmuxNetworkObserver.start()
RorkUsbmuxNetworkObserver.refreshEndpoint()

let ipaBytes = try Data(contentsOf: ipaURL)
try RorkUsbmux.stageApp(bundleId: bundleIdentifier, ipaBytes: ipaBytes)
try RorkUsbmux.installApp(
    bundleId: bundleIdentifier,
    clientOptions: [
        .bundleIdentifier: bundleIdentifier,
        "CustomClientOption": "CustomValue"
    ]
)
```

## Migration to rork-device

`rork-device` is the modern Swift package for iOS device communication and
app-install workflows. Its API is centered on device clients, pairing records,
and authenticated sessions opened through local usbmux discovery or a known
Lockdown tunnel endpoint.

For a normal local usbmux flow:

```swift
import Foundation
import RorkDevice

let client = DeviceClient()
let pairing = try PairingRecord.load(from: pairingRecordURL)

guard let device = try await client.discoverDevices().first else {
    throw RorkDeviceError.invalidInput("No paired iOS device is visible.")
}

let session = try await client.connect(to: device, using: pairing)

try await session.installProvisioningProfile(contentsOf: provisioningProfileURL)
try await session.installApplication(
    at: ipaURL,
    bundleIdentifier: bundleIdentifier
) { progress in
    if let percent = progress.percentComplete {
        print("\(progress.status) \(percent)%")
    } else {
        print(progress.status)
    }
}
```

For tunnel-backed workflows where Lockdown is already reachable at a known host
and port, skip usbmux discovery and connect directly:

```swift
let session = try await client.connect(
    to: "10.7.0.1",
    port: 62078,
    using: pairing
)

try await session.installApplication(
    at: ipaURL,
    bundleIdentifier: bundleIdentifier
)
```

Common RorkUsbmux operations map to rork-device like this:

| RorkUsbmux | rork-device |
| --- | --- |
| `startWithLogger(...)` | No MiniMuxer startup; create `DeviceClient()` |
| pairing plist string | `PairingRecord.load(from:)` or `PairingRecord.parse(_:)` |
| network endpoint refresh | `discoverDevices()` or `connect(to:port:using:)` |
| `stageApp(...)` + `installApp(...)` | `installApplication(at:bundleIdentifier:progress:)` |
| provisioning profile install | `installProvisioningProfile(contentsOf:)` |
| app removal | `uninstallApplication(bundleIdentifier:progress:)` |

## Native Dependencies

RorkUsbmux vendors the native sources MiniMuxer needs:

- libimobiledevice
- libimobiledevice-glue
- libplist
- libusbmuxd
- OpenSSL XCFrameworks, static libraries, and headers for iPhoneOS and iPhone Simulator

The default path should work with a normal Swift Package install.

The C/C++ dependency sources are committed directly under
`Vendor/libimobiledevice` instead of git submodules so Xcode and SwiftPM
consumers can resolve the package without running extra submodule setup.

## Deprecation

RorkUsbmux is deprecated in favor of
[rork-device](https://github.com/rorkai/rork-device), a modern Swift toolkit
for iOS device communication. RorkUsbmux remains available for existing
consumers that need the MiniMuxer SwiftPM wrapper, but it is not expected to
receive new feature work.

## API Shape

Use `RorkUsbmux` for MiniMuxer's high-level operations. Focused namespaces expose
the same functionality by area:

- `RorkUsbmuxAFC`
- `RorkUsbmuxInstall`
- `RorkUsbmuxJIT`
- `RorkUsbmuxMounter`
- `RorkUsbmuxMuxer`
- `RorkUsbmuxNetworkObserver`
- `RorkUsbmuxProvisioning`

The package also re-exports MiniMuxer so callers can access upstream public
types when needed.

## Attribution

RorkUsbmux wraps and packages work from SideStore MiniMuxer and the
libimobiledevice project family. See vendored source directories for their
respective license files.

## License

RorkUsbmux is licensed under the GNU Affero General Public License v3; see
[LICENSE](LICENSE). This matches the package shape because RorkUsbmux links and
re-exports MiniMuxer, whose repository is also licensed under the GNU Affero
General Public License v3.

The package also vendors OpenSSL and libimobiledevice-family library sources;
those directories keep their own license files.

Earlier RorkUsbmux releases carried an Apache License 2.0 root license for the
Rork-authored wrapper code. That does not remove third-party license
obligations for the complete SwiftPM product, and this license update does not
retroactively change prior released tags.
