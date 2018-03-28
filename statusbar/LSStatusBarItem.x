#import "LSStatusBarItem.h"
#import "HBStatusBarItem.h"

@interface LSStatusBarItem ()

@property (nonatomic, retain) NSString *_hb_identifier;

@property (nonatomic, assign) UIStatusBarCustomItemAlignment _hb_alignment;

@property (nonatomic, assign) BOOL _hb_visible;
@property (nonatomic, retain) NSString *_hb_imageName;

@property (nonatomic, assign) BOOL _hb_manualUpdate;

@end

%subclass LSStatusBarItem : HBStatusBarItem

#pragma mark - NSObject

%new - (instancetype)initWithIdentifier:(NSString *)identifier alignment:(UIStatusBarCustomItemAlignment)alignment {
	NSParameterAssert(alignment);

	self = [self initWithIdentifier:identifier imageNamed:identifier inBundle:nil];

	if (self) {
		// TODO: _alignment = alignment;
	}

	return self;
}

#pragma mark - Properties

%new - (BOOL)manualUpdate {
	return !self.updateAutomatically;
}

%new - (void)setManualUpdate:(BOOL)manualUpdate {
	self.updateAutomatically = !manualUpdate;
}

%end

