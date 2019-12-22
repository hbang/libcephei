#import "HBPreferencesXPCService.h"
#import "HBPreferences.h"

@implementation HBPreferencesXPCService

- (void)synchronizeForIdentifier:(NSString *)identifier {
	[[HBPreferences preferencesForIdentifier:identifier] synchronize];
}

- (void)dictionaryRepresentationForIdentifier:(NSString *)identifier withReply:(void (^)(NSDictionary *))reply {
	reply([HBPreferences preferencesForIdentifier:identifier].dictionaryRepresentation);
}

- (void)objectForKey:(NSString *)key forIdentifier:(NSString *)identifier withReply:(void (^)(id <NSSecureCoding>))reply {
	reply([[HBPreferences preferencesForIdentifier:identifier] objectForKey:key]);
}

- (void)setObject:(id <NSSecureCoding>)value forKey:(NSString *)key forIdentifier:(NSString *)identifier {
	[[HBPreferences preferencesForIdentifier:identifier] setObject:value forKey:key];
}

@end
