# RorkUsbmux

RorkUsbmux is a Rork-maintained Swift Package that makes
[SideStore MiniMuxer](https://github.com/SideStore/minimuxer) usable from Swift
apps without requiring downstream projects to wire native libimobiledevice,
libplist, libusbmuxd, or OpenSSL build settings by hand.

The package exposes a Swift facade for MiniMuxer's public workflows:

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

## Native Dependencies

RorkUsbmux vendors the native sources MiniMuxer needs:

- libimobiledevice
- libimobiledevice-glue
- libplist
- libusbmuxd
- OpenSSL static libraries and headers for iPhoneOS and iPhone Simulator

The default path should work with a normal Swift Package install. Advanced users
can override the OpenSSL root with `RORK_USBMUX_OPENSSL_ROOT` or
`OPENSSL_ROOT_DIR`; the root must contain `include/` and `lib/` directories.

The C/C++ dependency sources are committed directly under
`Vendor/libimobiledevice` instead of git submodules so Xcode and SwiftPM
consumers can resolve the package without running extra submodule setup.

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
