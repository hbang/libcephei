# Cephei
libcephei, formerly HASHBANG Productions Common, is a package that we at [HASHBANG Productions](https://www.hbang.ws/) initially wrote for ourselves so we didn’t have to paste the same code into our Cydia packages over and over - after all, [Don’t Repeat Yourself](https://en.wikipedia.org/wiki/Don't_repeat_yourself) is quite an important principle.

Little by little, we added more useful classes to Common that we realised we need to make it clear that *anyone* is allowed to use this code. So now, we renamed HASHSBANG Productions Common to Cephei, [wrote up documentation](https://hbang.github.io/libcephei), and hope you’ll appreciate what it has to offer.

Don’t forget to submit pull requests if you think there’s something useful every tweak developer could benefit from!

**Note: Documentation is currently a work in progress.**

## Integrating libcephei into your Theos projects
It’s really easy to integrate libcephei into a Theos project. First, install libcephei on your device. It’s a hidden package in Cydia, so you’ll need to either install something that uses it - try TypeStatus - or just install it with `apt-get install ws.hbang.common` at the command line. 

Now, copy the dynamic libraries and headers into the location you cloned Theos to. If you’re using [our headers](https://github.com/hbang/headers), you already have the headers needed and can skip the second command. (We assume you have `$THEOS`, `$THEOS_DEVICE_IP`, and `$THEOS_DEVICE_PORT` set and exported in your shell.)

    scp -P $THEOS_DEVICE_PORT root@$THEOS_DEVICE_IP:/usr/lib/libcephei\* $THEOS/lib
    scp -r -P $THEOS_DEVICE_PORT root@$THEOS_DEVICE_IP:/usr/include/\{Cephei,CepheiPrefs\} $THEOS/include

Next, for all targets that will be using libcephei, add it to the target’s libraries:

    TargetName_LIBRARIES += cephei

For all targets that will be using preferences components of Cephei, make sure you also link against `cepheiprefs`.

You can now use libcephei components in your project.

## License
Licensed under [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0.html).
