// swift-tools-version: 5.9

import PackageDescription

let libimobiledeviceSources = [
    "libimobiledevice/common/debug.c",
    "libimobiledevice/common/userpref.c",
    "libimobiledevice/src/afc.c",
    "libimobiledevice/src/bt_packet_logger.c",
    "libimobiledevice/src/companion_proxy.c",
    "libimobiledevice/src/debugserver.c",
    "libimobiledevice/src/device_link_service.c",
    "libimobiledevice/src/diagnostics_relay.c",
    "libimobiledevice/src/file_relay.c",
    "libimobiledevice/src/heartbeat.c",
    "libimobiledevice/src/house_arrest.c",
    "libimobiledevice/src/idevice.c",
    "libimobiledevice/src/installation_proxy.c",
    "libimobiledevice/src/lockdown-cu.c",
    "libimobiledevice/src/lockdown.c",
    "libimobiledevice/src/misagent.c",
    "libimobiledevice/src/mobile_image_mounter.c",
    "libimobiledevice/src/mobileactivation.c",
    "libimobiledevice/src/mobilebackup.c",
    "libimobiledevice/src/mobilebackup2.c",
    "libimobiledevice/src/mobilesync.c",
    "libimobiledevice/src/notification_proxy.c",
    "libimobiledevice/src/preboard.c",
    "libimobiledevice/src/property_list_service.c",
    "libimobiledevice/src/restore.c",
    "libimobiledevice/src/reverse_proxy.c",
    "libimobiledevice/src/sbservices.c",
    "libimobiledevice/src/screenshotr.c",
    "libimobiledevice/src/service.c",
    "libimobiledevice/src/syslog_relay.c",
    "libimobiledevice/src/webinspector.c",
    "libimobiledevice-glue/src/cbuf.c",
    "libimobiledevice-glue/src/collection.c",
    "libimobiledevice-glue/src/glue.c",
    "libimobiledevice-glue/src/opack.c",
    "libimobiledevice-glue/src/socket.c",
    "libimobiledevice-glue/src/termcolors.c",
    "libimobiledevice-glue/src/thread.c",
    "libimobiledevice-glue/src/tlv.c",
    "libimobiledevice-glue/src/utils.c",
    "libplist/libcnary/cnary.c",
    "libplist/libcnary/node.c",
    "libplist/libcnary/node_list.c",
    "libplist/src/Array.cpp",
    "libplist/src/Boolean.cpp",
    "libplist/src/Data.cpp",
    "libplist/src/Date.cpp",
    "libplist/src/Dictionary.cpp",
    "libplist/src/Integer.cpp",
    "libplist/src/Key.cpp",
    "libplist/src/Node.cpp",
    "libplist/src/Real.cpp",
    "libplist/src/String.cpp",
    "libplist/src/Structure.cpp",
    "libplist/src/Uid.cpp",
    "libplist/src/base64.c",
    "libplist/src/bplist.c",
    "libplist/src/bytearray.c",
    "libplist/src/hashtable.c",
    "libplist/src/jplist.c",
    "libplist/src/jsmn.c",
    "libplist/src/oplist.c",
    "libplist/src/out-default.c",
    "libplist/src/out-limd.c",
    "libplist/src/out-plutil.c",
    "libplist/src/plist.c",
    "libplist/src/ptrarray.c",
    "libplist/src/time64.c",
    "libplist/src/xplist.c",
    "libusbmuxd/src/libusbmuxd.c",
]

let libimobiledeviceCSettings: [CSetting] = [
    .define("HAVE_OPENSSL"),
    .define("HAVE_STPNCPY"),
    .define("HAVE_STPCPY"),
    .define("HAVE_VASPRINTF"),
    .define("HAVE_ASPRINTF"),
    .define("PACKAGE_STRING", to: "\"RorkUsbmux\""),
    .define("PACKAGE_VERSION", to: "\"RorkUsbmux\""),
    .define("HAVE_GETIFADDRS"),
    .define("HAVE_STRNDUP"),
    .headerSearchPath("libimobiledevice"),
    .headerSearchPath("libimobiledevice/common"),
    .headerSearchPath("libimobiledevice/include"),
    .headerSearchPath("libimobiledevice/src"),
    .headerSearchPath("libimobiledevice-glue/include"),
    .headerSearchPath("libimobiledevice-glue/src"),
    .headerSearchPath("libplist/include"),
    .headerSearchPath("libplist/libcnary/include"),
    .headerSearchPath("libplist/src"),
    .headerSearchPath("libusbmuxd/include"),
    .headerSearchPath("libusbmuxd/src"),
    .headerSearchPath("../OpenSSL/iphoneos/include"),
    .headerSearchPath("../OpenSSL/iphonesimulator/include"),
]

let package = Package(
    name: "RorkUsbmux",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "RorkUsbmux",
            targets: ["RorkUsbmux"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/rorkai/minimuxer.git", from: "0.1.0"),
    ],
    targets: [
        .binaryTarget(
            name: "OpenSSL",
            path: "Vendor/OpenSSL/libssl.xcframework"
        ),
        .binaryTarget(
            name: "OpenSSLCrypto",
            path: "Vendor/OpenSSL/libcrypto.xcframework"
        ),
        .target(
            name: "libimobiledevice",
            dependencies: [
                "OpenSSL",
                "OpenSSLCrypto",
            ],
            path: "Vendor/libimobiledevice",
            sources: libimobiledeviceSources,
            publicHeadersPath: "libimobiledevice/include",
            cSettings: libimobiledeviceCSettings,
            cxxSettings: [
                .headerSearchPath("../OpenSSL/iphoneos/include"),
                .headerSearchPath("../OpenSSL/iphonesimulator/include"),
            ]
        ),
        .target(
            name: "RorkUsbmux",
            dependencies: [
                "libimobiledevice",
                .product(name: "Minimuxer", package: "minimuxer"),
            ]
        ),
    ],
    cLanguageStandard: .gnu11,
    cxxLanguageStandard: .gnucxx17
)
