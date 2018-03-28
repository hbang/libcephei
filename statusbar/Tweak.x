#import "UIStatusBarCustomItem.h"
#import "UIStatusBarCustomItemView.h"
#import "HBStatusBarController.h"
#import <UIKit/UIStatusBar.h>
#import <UIKit/UIStatusBarForegroundView.h>
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>
#import <UIKit/UIStatusBarLayoutManager.h>

@interface UIStatusBarLayoutManager ()

@property (nonatomic, strong) NSMutableDictionary <NSString *, UIStatusBarItemView *> *_hb_statusBarItemViews;

- (UIStatusBarItemView *)_hb_viewForItem:(UIStatusBarItem *)item;


- (UIStatusBarForegroundView *)foregroundView;


@end

@interface HBStatusBarItem ()

- (UIStatusBarCustomItem *)statusBarItem;

@end

%hook UIStatusBarLayoutManager

%property (nonatomic, retain) NSMutableDictionary *_hb_statusBarItemViews;

%new - (UIStatusBarItemView *)_hb_viewForItem:(UIStatusBarCustomItem *)item {
	NSMutableDictionary <NSString *, UIStatusBarItemView *> *cachedItemViews = self._hb_statusBarItemViews;

	if (!cachedItemViews) {
		cachedItemViews = [NSMutableDictionary dictionary];
		self._hb_statusBarItemViews = cachedItemViews;
	}

	if (cachedItemViews[item.indicatorName]) {
		return cachedItemViews[item.indicatorName];
	}

	UIStatusBarForegroundView *foregroundView = [self valueForKey:@"_foregroundView"];
	UIStatusBarForegroundStyleAttributes *foregroundStyle = foregroundView.foregroundStyle;

	UIStatusBarCustomItemView *view = (UIStatusBarCustomItemView *)[%c(UIStatusBarItemView) createViewForItem:item withData:nil actions:kNilOptions foregroundStyle:foregroundStyle];
	view.itemName = item.indicatorName;
	view.layoutManager = self;
	view.alpha = 1;

	cachedItemViews[item.indicatorName] = view;
	[item setView:view forManager:self];

	return view;
}

- (UIStatusBarItemView *)_viewForItem:(UIStatusBarItem *)item {
	if (![item isKindOfClass:%c(UIStatusBarCustomItem)]) {
		return %orig;
	}

	return [self _hb_viewForItem:(UIStatusBarCustomItem *)item];
}

- (NSMutableArray <UIStatusBarItemView *> *)_itemViews {
	NSMutableArray <UIStatusBarItemView *> *itemViews = %orig;

	for (HBStatusBarItem *item in [HBStatusBarController sharedInstance].customStatusBarItems) {
		[itemViews addObject:[self _hb_viewForItem:item.statusBarItem]];
	}

	return itemViews;
}

- (BOOL)prepareEnabledItems:(BOOL *)items withData:(id)data actions:(NSInteger)actions {
	BOOL result = %orig;

	// refresh the item view dictionary
	[self _itemViews];

	NSMutableDictionary <NSString *, UIStatusBarItemView *> *cachedItemViews = self._hb_statusBarItemViews;

	for (NSString *identifier in cachedItemViews.allKeys) {
		UIStatusBarItemView *view = cachedItemViews[identifier];

		if (!view.superview) {
			[self.foregroundView addSubview:view];
		}
	}

	return result;
}

- (void)_positionNewItemViewsWithEnabledItems:(BOOL *)items {
	%orig;

	NSMutableDictionary <NSString *, UIStatusBarItemView *> *cachedItemViews = self._hb_statusBarItemViews;

	for (HBStatusBarItem *item in [HBStatusBarController sharedInstance].customStatusBarItems) {
	HBLogDebug(@"do we have %@ --> %@", item.identifier, cachedItemViews[item.identifier]);
		UIStatusBarItemView *view = cachedItemViews[item.identifier];

		if (view) {
			view.visible = item.isVisible;
			// view.frame = CGRectMake(0, 0, 20, 20);
		}
	}
}

%end

%hook UIStatusBarForegroundView

- (NSMutableDictionary <NSNumber *, NSMutableArray <UIStatusBarItem *> *> *)_computeVisibleItemsPreservingHistory:(BOOL)preserveHistory {
	NSMutableDictionary <NSNumber *, NSMutableArray <UIStatusBarItem *> *> *items = %orig;

	for (HBStatusBarItem *item in [HBStatusBarController sharedInstance].customStatusBarItems) {
		NSNumber *key = nil;

		switch (item.statusBarLocation) {
			case HBStatusBarLocationLeft:
				key = @0;
				break;
			
			case HBStatusBarLocationRight:
				key = @1;
				break;
			
			case HBStatusBarLocationCenter:
				key = @2;
				break;
		}

		[items[key] addObject:item.statusBarItem];
	}

	return items;
}

%end
