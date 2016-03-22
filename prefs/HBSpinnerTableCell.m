#import "HBSpinnerTableCell.h"

@implementation HBSpinnerTableCell {
	UIActivityIndicatorView *_activityIndicator;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(id)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		self.accessoryView = _activityIndicator;
	}

	return self;
}

- (void)setCellEnabled:(BOOL)cellEnabled {
	[super setCellEnabled:cellEnabled];

	if (cellEnabled) {
		[_activityIndicator stopAnimating];
	} else {
		[_activityIndicator startAnimating];
	}
}

@end
