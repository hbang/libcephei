#import "UIStatusBarCustomItem.h"
#import <UIKit/UIStatusBarItemView.h>
#import <UIKit/UIStatusBarForegroundView.h>
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>
#import <UIKit/UIStatusBarLayoutManager.h>

%hook UIStatusBarItem

- (instancetype)initWithType:(UIStatusBarItemType)type {
	self = %orig;

	if (!self) {
		self = [(UIStatusBarCustomItem *)[%c(UIStatusBarCustomItem) alloc] initWithType:type];
	}

	return self;
}

%end

%hook UIStatusBarLayoutManager

- (UIStatusBarItemView *)_viewForItem:(UIStatusBarItem *)item {
	if (![item isKindOfClass:%c(UIStatusBarCustomItem)]) {
		return %orig;
	}

	UIStatusBarForegroundView *foregroundView = [self valueForKey:@"_foregroundView"];
	UIStatusBarForegroundStyleAttributes *foregroundStyle = foregroundView.foregroundStyle;

	UIStatusBarItemView *view = [%c(UIStatusBarItemView) createViewForItem:item withData:nil actions:kNilOptions foregroundStyle:foregroundStyle];
	view.layoutManager = self;

	[item setView:view forManager:self];

	return view;
}

- (NSMutableArray *)_itemViews {
	NSMutableArray *itemViews = %orig;
	return itemViews;
}

%end

%hook UIStatusBarForegroundView

- (id)_computeVisibleItemsPreservingHistory:(BOOL)preserveHistory {
	%orig;
}

%end
