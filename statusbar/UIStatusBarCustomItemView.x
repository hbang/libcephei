#import "UIStatusBarCustomItemView.h"
#import <UIKit/_UILegibilityImageSet.h>
#import <UIKit/UIImage+Private.h>
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>

%subclass UIStatusBarCustomItemView : UIStatusBarItemView

%property (nonatomic, retain) NSString *itemName;

- (_UILegibilityImageSet *)contentsImage {
	static NSBundle *UIKitBundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIKitBundle = [NSBundle bundleForClass:UIView.class];
	});

	if (!self.itemName) {
		return nil;
	}

	UIImage *image = [UIImage imageNamed:[self.foregroundStyle expandedNameForImageName:self.itemName] inBundle:UIKitBundle];
	UIImage *tintedImage = [image _flatImageWithColor:self.foregroundStyle.tintColor];
	return [%c(_UILegibilityImageSet) imageFromImage:tintedImage withShadowImage:nil];
}

- (CGSize)intrinsicContentSize {
	return self.contentsImage.image.size;
}

- (void)updateContentsAndWidth {
	%orig;
	[self invalidateIntrinsicContentSize];
}

%end
