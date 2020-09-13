#import "HBListController.h"

@interface HBContactViewController : HBListController

@property (nonatomic, copy) NSString *to;
@property (nonatomic, copy) NSData *preferencesPlist;
@property (nonatomic, copy) NSString *preferencesIdentifier;

// Dummy properties just in case somebody is using these from TSContactViewController.
@property (nonatomic, copy) NSString *detailEntryPlaceholderText;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *messageBody;
@property (nonatomic, copy) NSString *detailFormat;
@property (nonatomic, copy) NSString *byline;
@property (nonatomic) BOOL requiresDetailsFromUser;

@end
