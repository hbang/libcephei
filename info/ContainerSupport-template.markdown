# Container Support
Cephei 1.8 includes Container Support, a tweak that allows jailbreak apps to be installed to /Applications but use a container like an App Store app. This enables apps to live in a more secure and sandboxed environment – all software should follow the [principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege).

The advantage of using a container is that all of the data it will ever create will be within a data directory. To remove the data and start over, you could simply delete this directory. It also allows you to tell exactly what files it writes to.

Enabling a container for your app is highly recommended if the app may be submitted to the App Store. Even if it won’t be, and you aren’t doing anything that would require a jailbreak or unrestricted access to the system, enabling a container is beneficial to ensuring your app can’t do anything unexpected to system files and user data.

To have your app use a container, simply add a key to the app’s Info.plist.

    <key>HBAppRequiresContainer</key>
    <true/>

After reloading the Launch Services application cache (by running `uicache`), the app will be in a container.

The only possible value for this key is `true`. Since an App Store app could easily add the same key set to `false` to gain unrestricted access to the device, disabling containers is not supported.
