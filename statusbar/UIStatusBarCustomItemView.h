#import <UIKit/UIStatusBarItemView.h>

@interface UIStatusBarCustomItemView : UIStatusBarItemView

@property (nonatomic, retain) NSString *itemName;

- (UIImage *)contentsImageForStyle:(int)style;

@end
