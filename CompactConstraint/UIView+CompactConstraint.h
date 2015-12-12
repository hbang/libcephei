//
//  Created by Marco Arment on 2014-04-06.
//  Copyright (c) 2014 Marco Arment. See included LICENSE file.
//

#import "NSLayoutConstraint+CompactConstraint.h"

@interface UIView (CompactConstraint)

// Add a single constraint with the compact syntax
- (NSLayoutConstraint *)hb_addCompactConstraint:(NSString *)relationship metrics:(NSDictionary *)metrics views:(NSDictionary *)views;

// Add any number of constraints. Can also mix in Visual Format Language strings.
- (NSArray *)hb_addCompactConstraints:(NSArray *)relationshipStrings metrics:(NSDictionary *)metrics views:(NSDictionary *)views;

// And a convenient shortcut for what we always end up doing with the visualFormat call.
- (void)hb_addConstraintsWithVisualFormat:(NSString *)format options:(NSLayoutFormatOptions)opts metrics:(NSDictionary *)metrics views:(NSDictionary *)views;

@end
