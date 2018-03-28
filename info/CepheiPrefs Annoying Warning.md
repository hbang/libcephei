# Using CepheiPrefs in apps other than Settings
The Preferences framework, and by extension, CepheiPrefs, can be used in apps other than Settings. (Apple themselves use it for the Watch app settings.) As a safeguard against some confusion on when CepheiPrefs.framework should be used (as opposed to Cephei.framework), CepheiPrefs will show an annoying warning message on app launch.

If you are legitimately using CepheiPrefs in an app other than Settings (Preferences) or Watch (Bridge), you can add a key to your Info.plist to allow it to be used.

```xml
<key>HBUsesCepheiPrefs</key>
<true/>
```

If CepheiPrefs is being used from a tweak, you can override like so:

```logos
%hook HBForceCepheiPrefs

+ (BOOL)forceCepheiPrefsWhichIReallyNeedToAccessAndIKnowWhatImDoingISwear {
    return YES;
}

%end
```

This may still log a warning, but will not display the annoying alert as long as the hook is in place before `UIApplicationDidFinishLaunchingNotification`.
