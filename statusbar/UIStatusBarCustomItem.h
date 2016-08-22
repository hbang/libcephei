#import <UIKit/UIStatusBarItem.h>

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

@interface UIStatusBarCustomItem : UIStatusBarItem

- (UIStatusBarItemView *)viewForManager:(UIStatusBarLayoutManager *)layoutManager;
- (void)setView:(UIStatusBarItemView *)view forManager:(UIStatusBarLayoutManager *)layoutManager;
- (void)removeAllViews;

@property (nonatomic, retain) NSString *indicatorName;
@property (nonatomic, retain) NSDictionary *properties;

@end
