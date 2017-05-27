# Cephei
Cephei is a framework for jailbroken iOS devices that includes various convenience features for developers. Primarily, it focuses on settings-related features, but it also contains other utilties. I hope you’ll appreciate what it has to offer.

All iOS versions since 5.0 are supported, on all devices.

Documentation is available at **[hbang.github.io/libcephei](https://hbang.github.io/libcephei/)**.

## Integrating Cephei into a Theos project
Cephei is a hidden package in Cydia, so if it’s not already installed, you’ll need to either install something that uses it – try TypeStatus – or use `apt-get install ws.hbang.common` at the command line.

Theos includes headers and linkable frameworks for Cephei, so you don’t need to worry about copying files over from your device.

For all projects that will be using Cephei, add it to the instance’s frameworks list:

```
MyAwesomeTweak_EXTRA_FRAMEWORKS += Cephei
```

For all projects that will be using preferences components of Cephei, make sure you also link against `CepheiPrefs`.

You can now use Cephei components in your project.

You must also add `ws.hbang.common` to the `Depends:` list in your control file. If Cephei isn’t present on the device, your binaries will fail to load. For example:

```
Depends: mobilesubstrate, something-else, some-other-package, ws.hbang.common (>= 1.11)
```

You should specify the current version of Cephei as the minimum requirement, so you can guarantee all features you use are available.

Please note that Cephei is now a framework (`/Library/Frameworks/Cephei.framework`), instead of a library (`/usr/lib/libcephei.dylib`). Frameworks are only properly supported with recent versions of [Theos](https://github.com/theos/theos). For backwards compatibility, libcephei.dylib and libcepheiprefs.dylib (and even libhbangcommon.dylib and libhbangprefs.dylib) are symlinks to the corresponding binaries. Do not use these in new code.

## Trying it out
You can take a look at a demo of the Preferences framework-specific features of Cephei simply by copying `/Library/PreferenceBundles/Cephei.bundle/entry.plist` to `/Library/PreferenceLoader/Preferences/Cephei.plist` – quit and relaunch Settings if it’s open. Alternatively, you can compile Cephei yourself – when compiling a debug build, it will also automatically kill and relaunch the Settings app.

## License
Licensed under the Apache License, version 2.0. Refer to [LICENSE.md](LICENSE.md).
