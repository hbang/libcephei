#import "HBTwitterCell.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIColor+Private.h>
#import <UIKit/UIImage+Private.h>
#import <version.h>

@interface HBTwitterCell () {
	NSString *_user;
	UIImage *_defaultImage;
	UIImage *_highlightedImage;
}

@end

@implementation HBTwitterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:specifier.properties[@"big"] && ((NSNumber *)specifier.properties[@"big"]).boolValue ? UITableViewCellStyleSubtitle : UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		_user = [specifier.properties[@"user"] copy];

		_defaultImage = [[UIImage imageNamed:@"twitter" inBundle:globalBundle] retain];
		_highlightedImage = IS_IOS_OR_NEWER(iOS_7_0) ? _defaultImage : [[UIImage imageNamed:@"twitter_selected" inBundle:globalBundle] retain];

		self.detailTextLabel.text = [@"@" stringByAppendingString:specifier.properties[@"user"]];
		self.detailTextLabel.textColor = IS_IOS_OR_NEWER(iOS_7_0) ? [UIColor colorWithWhite:0.5568627451f alpha:1] : [UIColor tableCellValue1BlueColor];
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		self.accessoryView = [[UIImageView alloc] initWithImage:_defaultImage];
	}

	return self;
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)style {
	[super setSelectionStyle:UITableViewCellSelectionStyleBlue];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	((UIImageView *)self.accessoryView).image = highlighted ? _highlightedImage : _defaultImage;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	if (!selected) {
		[super setSelected:selected animated:animated];
		return;
	}

	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"aphelion:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"aphelion://profile/" stringByAppendingString:_user]]];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:_user]]];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:_user]]];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:_user]]];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:_user]]];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:_user]]];
	}
}

- (void)dealloc {
	[_user release];
	[_defaultImage release];
	[_highlightedImage release];

	[super dealloc];
}

@end
