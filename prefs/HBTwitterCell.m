#import "HBTwitterCell.h"
#import <Preferences/PSSpecifier.h>

@implementation HBTwitterCell

+ (NSURL *)_urlForUsername:(NSString *)username userID:(NSString *)userID {
	NSParameterAssert(username != nil || userID != nil);
	if (username == nil) {
		NSURLComponents *url = [NSURLComponents componentsWithString:@"https://twitter.com/intent/user"];
		url.queryItems = @[[NSURLQueryItem queryItemWithName:@"user_id" value:userID]];
		return url.URL;
	} else {
		NSString *encodedUsername = [username stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
		return [NSURL URLWithString:[@"https://twitter.com/" stringByAppendingString:encodedUsername]];
	}
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	NSString *userName = specifier.properties[@"user"];
	NSString *userID = specifier.properties[@"userID"];

	if (specifier.properties[@"iconCircular"] == nil) {
		specifier.properties[@"iconCircular"] = @YES;
	}
	specifier.properties[@"url"] = [self.class _urlForUsername:userName userID:userID];

	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		self.detailTextLabel.text = [@"@" stringByAppendingString:userName];
	}

	return self;
}

@end
