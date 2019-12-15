#import "HBListItemsController.h"
#import "HBListController.h"
#import <version.h>
#import <HBLog.h>

@implementation HBListItemsController

- (instancetype)init {
	HBLogWarn(@"HBListItemsController is deprecated and no longer needed. Use PSListItemsController instead.");
	return [super init];
}

@end
