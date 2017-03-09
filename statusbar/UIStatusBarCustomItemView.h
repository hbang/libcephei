#import <UIKit/UIStatusBarItemView.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The `UIStatusBarCustomItemView` class in `CepheiStatusBar` is a compatibility layer for
 * tweaks using the libstatusbar API. If libstatusbar or a fork is installed, its own implementation
 * is used; otherwise, Cephei’s implementation is used.
 *
 * This class is intentionally significantly simpler than the same class in libstatusbar – it only
 * aims to support the displaying of icons named:
 *
 * * Black_[ItemName].png (automatically tinted template based on status bar color)
 * * Black_[ItemName]_Color.png (not tinted – colors are preserved)
 * * LockScreen_[ItemName].png (larger for lock screen status bar)
 * * LockScreen_[ItemName]_Color.png (same as above)
 *
 * Older icon type names are not supported. The icon is expected to be named `Type_ItemName.png` and
 * placed at /System/Library/Frameworks/UIKit.framework.
 *
 * If this breaks your tweak, the best course of action would be to adopt Cephei Status Bar APIs, or
 * override contentsImageForStyle: with a custom implementation. If this is not viable,
 * [file an issue](https://github.com/hbang/libcephei/issues) and we can investigate a solution.
 */

@interface UIStatusBarCustomItemView : UIStatusBarItemView

/**
 * The name of the item image.
 *
 * This is used to look up the file name. See the discussion above.
 */
@property (nonatomic, retain, nonnull) NSString *itemName;

/**
 * The image to be displayed in the status bar.
 *
 * The default implementation will return an image based on the value of itemName. If more
 * flexibility is required, subclass and implement this method. The image will be tinted with the
 * color of the status bar.
 *
 * @param style Not used. Always 0.
 * @returns An image to be displayed in the status bar.
 */
- (UIImage *)contentsImageForStyle:(int)style;

@end

NS_ASSUME_NONNULL_END
