#import "HBStatusBarController.h"

@interface HBStatusBarController ()

@property (nonatomic, strong, readwrite) NSMutableSet <HBStatusBarItem *> *customStatusBarItems;

@end

@implementation HBStatusBarController

+ (instancetype)sharedInstance {
	static HBStatusBarController *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (instancetype)init {
	self = [super init];

	if (self) {
		_customStatusBarItems = [NSMutableSet set];
	}

	return self;
}

- (void)addItem:(HBStatusBarItem *)item {
	[_customStatusBarItems addObject:item];
}

- (void)removeItem:(HBStatusBarItem *)item {
	[_customStatusBarItems removeObject:item];
}

@end
