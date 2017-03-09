#import "UIStatusBarCustomItem.h"
#import "_HBStatusBarClient.h"

@interface UIStatusBarCustomItem ()

@property (nonatomic) UIStatusBarCustomItemAlignment _hb_alignment;
@property (nonatomic) NSInteger _hb_leftOrder;
@property (nonatomic) NSInteger _hb_rightOrder;
@property (nonatomic, retain) NSString *_hb_customViewClass;
@property (nonatomic, retain) NSString *_hb_indicatorName;
@property (nonatomic, retain) NSMutableDictionary <UIStatusBarLayoutManager *, UIStatusBarItemView *> *_hb_views;

@end

%subclass UIStatusBarCustomItem : UIStatusBarItem

%property (nonatomic, retain) NSInteger _hb_alignment;
%property (nonatomic, retain) NSInteger _hb_leftOrder;
%property (nonatomic, retain) NSInteger _hb_rightOrder;
%property (nonatomic, retain) NSString *_hb_customViewClass;
%property (nonatomic, retain) NSString *_hb_indicatorName;
%property (nonatomic, retain) NSMutableDictionary *_hb_views;

- (instancetype)init {
	self = %orig;

	if (self) {
		self._hb_views = [[NSMutableDictionary alloc] init];
	}

	return self;
}

- (UIStatusBarItemType)type {
	return 0;
}

- (NSInteger)priority {
	return 0;
}

- (NSInteger)leftOrder {
	return self._hb_alignment & UIStatusBarCustomItemAlignmentLeft ? 15 : 0;
}

- (NSInteger)rightOrder {
	return self._hb_alignment & UIStatusBarCustomItemAlignmentRight ? 15 : 0;
}

- (Class)viewClass {
	return NSClassFromString(self._hb_customViewClass) ?: %c(UIStatusBarCustomItemView);
}

- (NSString *)indicatorName {
	return self._hb_indicatorName ?: %orig;
}

%new - (UIStatusBarItemView *)viewForManager:(UIStatusBarLayoutManager *)layoutManager {
	return self._hb_views[layoutManager];
}

%new - (void)setView:(UIStatusBarItemView *)view forManager:(UIStatusBarLayoutManager *)layoutManager {
	self._hb_views[(id <NSCopying>)layoutManager] = view;
}

%new - (void)removeAllViews {
	for (UIView *view in self._hb_views) {
		[view removeFromSuperview];
	}
}

%end

%ctor {
	if (![_HBStatusBarClient hasLibstatusbar]) {
		%init;
	}
}
