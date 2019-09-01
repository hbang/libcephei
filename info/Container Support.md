# Container Support
> **Cephei Container Support was removed in version 1.14** in order to cut down on the dependencies of Cephei.

Cephei Container Support allows jailbreak apps to be installed to /Applications but use a container like an App Store app. This enables apps to live in a more secure and sandboxed environment – all software should follow the [principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege).

The advantage of using a container is that all of the data it will ever create will be within a data directory. To remove the data and start over, you could simply delete this directory. It also allows you to tell exactly what files it writes to.
