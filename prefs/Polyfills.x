@import UIKit;
#import <version.h>

%group CopyColor
%hook UIColor

%new - (UIColor *)copyWithZone:(NSZone *)zone {
	// Copying wasn’t implemented on UIColor till iOS 6, so iOS 5 crashes if we call copy. Use a
	// silly workaround to manually copy colors.
	CGFloat red, green, blue, alpha;
	[self getRed:&red green:&green blue:&blue alpha:&alpha];
	return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

%end
%end

%ctor {
	if (!IS_IOS_OR_NEWER(iOS_6_0)) {
		%init(CopyColor);
	}
}
