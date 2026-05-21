# RorkUsbmux

RorkUsbmux is the Rork-owned Swift package for the iOS usbmux install path.
It wraps SideStore MiniMuxer and the native libimobiledevice/libplist/libusbmuxd
sources needed by MiniMuxer's Rust bridge.

The package expects iPhoneOS OpenSSL headers and libraries. By default it looks
for the OpenSSL checkout used by `rork-max-ios`; set `RORK_OPENSSL_ROOT` to an
`iphoneos` OpenSSL root when building it from another checkout.
