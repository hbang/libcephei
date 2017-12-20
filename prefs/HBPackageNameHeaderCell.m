#import "HBPackageNameHeaderCell.h"
#import <Cephei/UIColor+HBAdditions.h>
#import <Preferences/PSSpecifier.h>
#import <TechSupport/TSPackage.h>
#import <UIKit/UITableViewCell+Private.h>
#import <version.h>
#include <dlfcn.h>

static CGFloat const kHBPackageNameTableCellCondensedFontSize = 25.f;
static CGFloat const kHBPackageNameTableCellHeaderFontSize = 42.f;
static CGFloat const kHBPackageNameTableCellSubtitleFontSize = 18.f;

@implementation HBPackageNameHeaderCell {
	BOOL _condensed;
	BOOL _showAuthor;
	BOOL _showVersion;
	BOOL _hasGradient;

	UIColor *_titleColor;
	UIColor *_subtitleColor;

	TSPackage *_package;
	NSString *_nameOverride;
	UIImage *_icon;
	UILabel *_label;
}

+ (Class)layerClass {
	return CAGradientLayer.class;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		NSParameterAssert(specifier.properties[@"packageIdentifier"]);

		self.backgroundColor = [UIColor clearColor];
		self.backgroundView = IS_IOS_OR_NEWER(iOS_7_0) ? nil : [[UIView alloc] init];

		NSArray <id> *serializedColors = specifier.properties[@"backgroundGradientColors"];

		if (serializedColors) {
			NSAssert(serializedColors.count > 0, @"backgroundGradientColors should be an array with more than one value.");

			_hasGradient = YES;

			NSMutableArray <UIColor *> *colors = [NSMutableArray array];

			for (id propertyListValue in serializedColors) {
				UIColor *color = [UIColor hb_colorWithPropertyListValue:propertyListValue];
				NSAssert(color, @"Color value %@ is invalid.", propertyListValue);
				[colors addObject:(id)color.CGColor];
			}

			CAGradientLayer *layer = (CAGradientLayer *)self.layer;
			layer.colors = [colors copy];
		}

		// hack to resolve odd margins being set on ipad
		CGFloat marginWidth = [self respondsToSelector:@selector(_marginWidth)] ? self._marginWidth : 0;

		CGRect labelFrame = self.contentView.bounds;
		labelFrame.origin.x -= IS_IPAD ? marginWidth : 0;
		labelFrame.origin.y += _hasGradient ? 0.f : 30.f;
		labelFrame.size.width -= IS_IPAD ? marginWidth * 2 : 0;
		labelFrame.size.height -= _hasGradient ? 0.f : 30.f;

		_label = [[UILabel alloc] initWithFrame:labelFrame];
		_label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_label.textAlignment = NSTextAlignmentCenter;
		_label.adjustsFontSizeToFitWidth = NO;

		if ([_label respondsToSelector:@selector(setAdjustsLetterSpacingToFitWidth:)]) {
			_label.adjustsLetterSpacingToFitWidth = NO;
		}
		
		[self.contentView addSubview:_label];

		_condensed = specifier.properties[@"condensed"] ? ((NSNumber *)specifier.properties[@"condensed"]).boolValue : NO;
		_showAuthor = specifier.properties[@"showAuthor"] ? ((NSNumber *)specifier.properties[@"showAuthor"]).boolValue : YES;
		_showVersion = specifier.properties[@"showVersion"] ? ((NSNumber *)specifier.properties[@"showVersion"]).boolValue : YES;
		_icon = specifier.properties[@"iconImage"];
		_nameOverride = [specifier.properties[@"packageNameOverride"] copy];

		_titleColor = [[UIColor alloc] hb_initWithPropertyListValue:specifier.properties[@"titleColor"]];
		_subtitleColor = [[UIColor alloc] hb_initWithPropertyListValue:specifier.properties[@"subtitleColor"]];

		if (!_titleColor) {
			_titleColor = _hasGradient ? [[UIColor alloc] initWithWhite:1.f alpha:0.95f] : [[UIColor alloc] initWithWhite:17.f / 255.f alpha:1];
		}

		if (!_subtitleColor) {
			_subtitleColor = _hasGradient ? [[UIColor alloc] initWithWhite:235.f / 255.f alpha:0.7f] : [[UIColor alloc] initWithWhite:68.f / 255.f alpha:1];
		}

#if !CEPHEI_EMBEDDED
		_package = [[TSPackage alloc] initWithIdentifier:specifier.properties[@"packageIdentifier"]];
#endif

		[self updateData];
	}

	return self;
}

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
	self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil specifier:specifier];
	return self;
}

#pragma mark - PSHeaderFooterView

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	CGFloat height = _condensed ? 74.f : 94.f;

	if (_showAuthor) {
		height += 26.f;
	}

	if (_hasGradient) {
		height += 41.f;
	}

	if (_showVersion && !_condensed) {
		height += 26.f;
	}

	return height;
}

#pragma mark - Updating

- (void)updateData {
	if (!_package) {
		// i hate pirate repos
		return;
	}

	NSString *name = _nameOverride ?: _package.name;

	if (![_label respondsToSelector:@selector(setAttributedText:)]) {
		// starting to realise the features we take for granted these days...
		_label.text = [NSString stringWithFormat:@"%@%@%@", name, _showVersion ? @" " : @"", _showVersion ? _package.version : @""];
		return;
	}

	NSUInteger cleanedAuthorLocation = [_package.author rangeOfString:@" <"].location;
	NSString *cleanedAuthor = cleanedAuthorLocation == NSNotFound ? _package.author : [_package.author substringWithRange:NSMakeRange(0, cleanedAuthorLocation)];

	NSString *icon = _icon ? @"ICON " : @"";
	NSString *version = _showVersion ? [NSString stringWithFormat:_condensed ? @" %@" : [@"\n" stringByAppendingString:LOCALIZE(@"HEADER_VERSION", @"PackageNameHeaderCell", @"The subheading containing the package version.")], _package.version] : @"";
	NSString *author = _showAuthor ? [NSString stringWithFormat:[@"\n" stringByAppendingString:LOCALIZE(@"HEADER_AUTHOR", @"PackageNameHeaderCell", @"The subheading containing the package author.")], cleanedAuthor] : @"";

	UIFont *headerFont, *subtitleFont, *condensedFont, *condensedLightFont;

	// the Title1 and Title2 styles were added in iOS 9. get their symbols dynamically so we can fall
	// back to older styles on older iOS
	NSString * __strong *myUIFontTextStyleTitle1 = (NSString * __strong *)dlsym(RTLD_DEFAULT, "UIFontTextStyleTitle1");
	NSString * __strong *myUIFontTextStyleTitle2 = (NSString * __strong *)dlsym(RTLD_DEFAULT, "UIFontTextStyleTitle2");

	if (myUIFontTextStyleTitle1 && myUIFontTextStyleTitle2) {
		UIFont *systemTitleFont = [UIFont preferredFontForTextStyle:*myUIFontTextStyleTitle1];
		UIFont *systemTitle2Font = [UIFont preferredFontForTextStyle:*myUIFontTextStyleTitle2];
		UIFont *systemSubtitleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];

		// use the specified font names, with either the font sizes we want, or the sizes the user
		// wants, whichever is larger
		headerFont = [UIFont fontWithName:systemTitleFont.fontName size:MAX(systemTitleFont.pointSize * 1.7f, kHBPackageNameTableCellHeaderFontSize)];
		subtitleFont = [UIFont systemFontOfSize:MAX(systemSubtitleFont.pointSize * 1.1f, kHBPackageNameTableCellSubtitleFontSize)];
		condensedFont = [UIFont systemFontOfSize:MAX(systemTitle2Font.pointSize * 1.1f, kHBPackageNameTableCellCondensedFontSize)];
		condensedLightFont = [UIFont fontWithName:systemTitleFont.fontName size:condensedFont.pointSize];
	} else {
		headerFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:kHBPackageNameTableCellHeaderFontSize];
		subtitleFont = [UIFont systemFontOfSize:kHBPackageNameTableCellSubtitleFontSize];
		condensedFont = [UIFont systemFontOfSize:kHBPackageNameTableCellCondensedFontSize];
		condensedLightFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:kHBPackageNameTableCellCondensedFontSize];
	}

	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@%@", icon, name, version, author] attributes:@{
		NSKernAttributeName: [NSNull null], // this *enables* kerning, interestingly
	}];

	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.lineSpacing = _condensed ? 4.f : 2.f;
	paragraphStyle.alignment = NSTextAlignmentCenter;

	NSUInteger location = 0, length = 0;
	CGFloat offset = 0;

	if (_icon) {
		NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
		textAttachment.image = _icon;
		[attributedString replaceCharactersInRange:NSMakeRange(0, 4) withAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];

		location += 1;
		length += 1;
		offset = 6.f;

		if (_condensed) {
			paragraphStyle.lineSpacing += offset;
		}
	}

	length += name.length;

	if (_condensed) {
		[attributedString addAttributes:@{
			NSFontAttributeName: condensedFont,
			NSBaselineOffsetAttributeName: @(offset),
			NSParagraphStyleAttributeName: paragraphStyle,
			NSForegroundColorAttributeName: _titleColor
		} range:NSMakeRange(location, length + version.length + 1)];
	} else {
		[attributedString addAttributes:@{
			NSFontAttributeName: headerFont,
			NSParagraphStyleAttributeName: paragraphStyle,
			NSForegroundColorAttributeName: _titleColor
		} range:NSMakeRange(location, length)];
	}

	if (_showVersion) {
		location += length;
		length = version.length;

		[attributedString addAttributes:@{
			NSFontAttributeName: _condensed ? condensedLightFont : subtitleFont,
			NSForegroundColorAttributeName: _subtitleColor
		} range:NSMakeRange(location, length)];
	}

	if (_showAuthor) {
		location += length;
		length = author.length;

		[attributedString addAttributes:@{
			NSFontAttributeName: subtitleFont,
			NSForegroundColorAttributeName: _subtitleColor
		} range:NSMakeRange(location, length)];
	}

	_label.numberOfLines = 0;
	_label.attributedText = attributedString;
}

@end
