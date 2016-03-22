#import "HBPackageNameHeaderCell.h"
#import <Cephei/UIColor+HBAdditions.h>
#import <Preferences/PSSpecifier.h>
#import <TechSupport/TSPackage.h>
#import <UIKit/UITableViewCell+Private.h>
#import <version.h>

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
		self.backgroundView = IS_MODERN ? nil : [[UIView alloc] init];

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
		CGRect labelFrame = self.contentView.bounds;
		labelFrame.origin.x -= IS_IPAD ? self._marginWidth : 0;
		labelFrame.origin.y += _hasGradient ? 0.f : 30.f;
		labelFrame.size.width -= IS_IPAD ? self._marginWidth * 2 : 0;
		labelFrame.size.height -= _hasGradient ? 0.f : 30.f;

		_label = [[UILabel alloc] initWithFrame:labelFrame];
		_label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_label.textAlignment = NSTextAlignmentCenter;
		_label.adjustsFontSizeToFitWidth = NO;
		_label.adjustsLetterSpacingToFitWidth = NO;
		[self.contentView addSubview:_label];

		_condensed = specifier.properties[@"condensed"] && ((NSNumber *)specifier.properties[@"condensed"]).boolValue;
		_showAuthor = !specifier.properties[@"showAuthor"] || ((NSNumber *)specifier.properties[@"showAuthor"]).boolValue;
		_showVersion = !specifier.properties[@"showVersion"] || ((NSNumber *)specifier.properties[@"showVersion"]).boolValue;
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

		NSAssert(!_condensed || _icon, @"An icon is required when using the condensed style.");

		_package = [[TSPackage alloc] initWithIdentifier:specifier.properties[@"packageIdentifier"]];

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

	NSUInteger cleanedAuthorLocation = [(NSString *)_package.author rangeOfString:@" <"].location;
	NSString *cleanedAuthor = cleanedAuthorLocation == NSNotFound ? _package.author : [_package.author substringWithRange:NSMakeRange(0, cleanedAuthorLocation)];

	NSString *icon = _icon && _condensed ? @"ICON " : @""; // note: there's a zero width space here
	NSString *version = _showVersion ? [NSString stringWithFormat:_condensed ? @" %@" : [@"\n" stringByAppendingString:LOCALIZE(@"HEADER_VERSION", @"PackageNameHeaderCell", @"The subheading containing the package version.")], _package.version] : @"";
	NSString *author = _showAuthor ? [NSString stringWithFormat:[@"\n" stringByAppendingString:LOCALIZE(@"HEADER_AUTHOR", @"PackageNameHeaderCell", @"The subheading containing the package author.")], cleanedAuthor] : @"";

	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@%@", icon, name, version, author] attributes:@{
		NSKernAttributeName: [NSNull null], // this *enables* kerning, interestingly
	}];

	NSUInteger location = 0, length = 0;

	if (_icon && _condensed) {
		NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
		textAttachment.image = _icon;
		[attributedString replaceCharactersInRange:NSMakeRange(0, 4) withAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
	}

	length = name.length;

	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.lineSpacing = _condensed ? 10.f : 4.f;
	paragraphStyle.alignment = NSTextAlignmentCenter;

	if (_condensed) {
		location++;
		length++;

		[attributedString addAttributes:@{
			NSFontAttributeName: [UIFont systemFontOfSize:kHBPackageNameTableCellCondensedFontSize],
			NSBaselineOffsetAttributeName: @(6.f),
			NSParagraphStyleAttributeName: paragraphStyle,
			NSForegroundColorAttributeName: _titleColor
		} range:NSMakeRange(location, length + version.length + 1)];
	} else {
		[attributedString addAttributes:@{
			NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:kHBPackageNameTableCellHeaderFontSize],
			NSParagraphStyleAttributeName: paragraphStyle,
			NSForegroundColorAttributeName: _titleColor
		} range:NSMakeRange(location, length)];
	}

	if (_showVersion) {
		location += length;
		length = version.length;

		[attributedString addAttributes:@{
			NSFontAttributeName: _condensed ? [UIFont fontWithName:@"HelveticaNeue-Light" size:kHBPackageNameTableCellCondensedFontSize] : [UIFont systemFontOfSize:kHBPackageNameTableCellSubtitleFontSize],
			NSForegroundColorAttributeName: _subtitleColor
		} range:NSMakeRange(location, length)];
	}

	if (_showAuthor) {
		location += length;
		length = author.length;

		[attributedString addAttributes:@{
			NSFontAttributeName: [UIFont systemFontOfSize:kHBPackageNameTableCellSubtitleFontSize],
			NSForegroundColorAttributeName: _subtitleColor
		} range:NSMakeRange(location, length)];
	}

	_label.numberOfLines = 0;
	_label.attributedText = attributedString;
}

@end
