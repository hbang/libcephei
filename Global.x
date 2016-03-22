NSBundle *globalBundle;

%ctor {
	globalBundle = RETAIN([NSBundle bundleWithPath:@"/Library/PreferenceBundles/Cephei.bundle"]);
}
