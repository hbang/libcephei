#import <UIKit/UIStatusBarItem.h>

NS_ASSUME_NONNULL_BEGIN

/// Mappings to libstatusbar’s constants for item alignment.
typedef NS_ENUM(NSInteger, UIStatusBarCustomItemAlignment) {
	UIStatusBarCustomItemAlignmentLeft = 1,
	UIStatusBarCustomItemAlignmentRight = 2,
	UIStatusBarCustomItemAlignmentCenter = 4
};

#define StatusBarAlignment UIStatusBarCustomItemAlignment
#define StatusBarAlignmentLeft UIStatusBarCustomItemAlignmentLeft
#define StatusBarAlignmentRight UIStatusBarCustomItemAlignmentRight
#define StatusBarAlignmentCenter UIStatusBarCustomItemAlignmentCenter

@class UIStatusBarItemView;

/// `UIStatusBarCustomItem` from Cephei Status Bar is provided as a compatibility layer for
/// libstatusbar. Items displayed using this API **will not** display on iPhone X.
@interface UIStatusBarCustomItem : UIStatusBarItem

- (UIStatusBarItemView *)viewForManager:(UIStatusBarLayoutManager *)layoutManager;
- (void)setView:(UIStatusBarItemView *)view forManager:(UIStatusBarLayoutManager *)layoutManager;
- (void)removeAllViews;

@property (nonatomic, retain) NSString *indicatorName;
@property (nonatomic, assign, getter=isVisible) BOOL visible;

@end

NS_ASSUME_NONNULL_END
