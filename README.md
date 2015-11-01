# Cephei
Cephei is a framework for jailbroken iOS devices that includes various convenience features for developers. Primarily, it focuses on settings-related features, but it also contains other utilties. I hope you’ll appreciate what it has to offer.

All iOS versions since 5.0 are supported, on all devices.

## Integrating Cephei into your Theos projects
It’s really easy to integrate Cephei into a Theos project. First, install Cephei on your device. It’s a hidden package in Cydia, so you’ll need to either install something that uses it – try TypeStatus – or just install it with `apt-get install ws.hbang.common` at the command line. 

Now, copy the dynamic libraries and headers into the location you cloned Theos to. (Hopefully you have `$THEOS`, `$THEOS_DEVICE_IP`, and `$THEOS_DEVICE_PORT` set and exported in your shell.)

```
scp -rP $THEOS_DEVICE_PORT root@$THEOS_DEVICE_IP:/Library/Frameworks/Cephei\*.framework $THEOS/lib
```

Next, for all projects that will be using Cephei, add it to the instance’s libraries:

```
MyAwesomeTweak_EXTRA_FRAMEWORKS += Cephei
```

For all projects that will be using preferences components of Cephei, make sure you also link against `CepheiPrefs`.

You can now use Cephei components in your project.

Please note that Cephei is now a framework, instead of a library. Frameworks are only properly supported with [kirb/theos](https://github.com/kirb/theos); other variants of Theos may or may not support it.

## Trying it out
You can take a look at a demo of the Preferences framework-specific features of Cephei simply by copying `/Library/PreferenceBundles/Cephei.bundle/entry.plist` to `/Library/PreferenceLoader/Preferences/Cephei.plist` – quit and relaunch Settings if it's open. Alternatively, you can compile Cephei yourself – when compiling a debug build, it will also automatically kill and relaunch the Settings app as long as you have [sbutils](http://moreinfo.thebigboss.org/moreinfo/depiction.php?file=sbutilsDp) installed.

## License
Licensed under [Apache License, version 2.0](https://github.com/hbang/libcephei/blob/master/LICENSE.md).
