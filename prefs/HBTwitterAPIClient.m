#import "HBTwitterAPIClient.h"
#import "../NSDictionary+HBAdditions.h"
#import <HBLog.h>
#import <objc/runtime.h>

#if __has_include("TwitterAPI.private.h")
#import "TwitterAPI.private.h"
#endif

typedef NSDictionary <NSString *, NSString *> *HBTwitterAPIClientUserItem;

@implementation HBTwitterAPIClient {
	dispatch_queue_t _cacheQueue;
	NSMutableOrderedSet <NSString *> *_usernameQueue;
	NSMutableOrderedSet <NSString *> *_userIDQueue;
	NSURL *_cacheURL;
	NSMutableDictionary <NSString *, NSDictionary <NSString *, NSString *> *> *_cacheData;
	NSMutableDictionary <NSString *, NSMutableSet <id <HBTwitterAPIClientDelegate>> *> *_delegates;
}

+ (instancetype)sharedInstance {
	static HBTwitterAPIClient *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		_cacheQueue = dispatch_queue_create("ws.hbang.common.twitter-cache-queue", DISPATCH_QUEUE_SERIAL);
		_usernameQueue = [[NSMutableOrderedSet alloc] init];
		_userIDQueue = [[NSMutableOrderedSet alloc] init];
		_delegates = [NSMutableDictionary dictionary];
		[self _prepareCache];
	}
	return self;
}

- (void)_prepareCache {
	dispatch_async(_cacheQueue, ^{
		NSError *error = nil;
		NSURL *userCacheURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
		if (error != nil) {
			HBLogWarn(@"Cephei: Failed to get cache directory: %@", error);
			return;
		}
		_cacheURL = [userCacheURL URLByAppendingPathComponent:@"Cephei/Avatars"];
		[[NSFileManager defaultManager] createDirectoryAtURL:_cacheURL withIntermediateDirectories:YES attributes:@{} error:&error];
		if (error != nil) {
			HBLogWarn(@"Cephei: Failed to create cache directory: %@", error);
			return;
		}

		NSData *cacheFile = [NSData dataWithContentsOfURL:[_cacheURL URLByAppendingPathComponent:@"cache.plist"]];
		if (cacheFile != nil) {
			_cacheData = [NSKeyedUnarchiver unarchiveObjectWithData:cacheFile];
		}
		if (_cacheData == nil) {
			_cacheData = [NSMutableDictionary dictionary];
		}

		NSArray <NSURL *> *items = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:_cacheURL includingPropertiesForKeys:@[ NSURLAttributeModificationDateKey ] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles error:&error];
		if (error != nil) {
			HBLogWarn(@"Cephei: Failed to read cache contents: %@", error);
			return;
		}

		NSTimeInterval cutoff = 4 * 24 * 60 * 60;
		for (NSURL *url in items) {
			if ([url.lastPathComponent isEqualToString:@"cache.plist"]) {
				continue;
			}

			NSDate *modDate = nil;
			[url getResourceValue:&modDate forKey:NSURLAttributeModificationDateKey error:&error];
			if (error != nil) {
				HBLogWarn(@"Cephei: Failed to read file metadata: %@", error);
				continue;
			}
			if ([modDate compare:[NSDate dateWithTimeIntervalSinceNow:-cutoff]] == NSOrderedAscending) {
				// It’s stale. Delete it.
				NSString *key = [url.lastPathComponent stringByDeletingPathExtension];
				[_cacheData removeObjectForKey:key];
				[[NSFileManager defaultManager] removeItemAtURL:url error:&error];
				if (error != nil) {
				HBLogWarn(@"Cephei: Failed to delete stale cache: %@", error);
				}
			}
		}
	});
}

- (void)_saveCache {
	dispatch_async(_cacheQueue, ^{
		[[NSKeyedArchiver archivedDataWithRootObject:_cacheData] writeToURL:[_cacheURL URLByAppendingPathComponent:@"cache.plist"] atomically:YES];
	});
}

- (nullable NSString *)_userIDForUsername:(NSString *)username {
	HBTwitterAPIClientUserItem user = _cacheData[[@"name:" stringByAppendingString:username]];
	return user[@"id"];
}

- (nullable HBTwitterAPIClientUserItem)_cacheItemForUserID:(NSString *)userID {
	return _cacheData[[@"id:" stringByAppendingString:userID]];
}

- (void)queueLookupsForUsernames:(NSArray <NSString *> *)usernames userIDs:(NSArray <NSString *> *)userIDs {
	dispatch_async(_cacheQueue, ^{
		NSMutableArray <NSString *> *fetchUsernames = [NSMutableArray array];
		NSMutableArray <NSString *> *fetchUserIDs = [NSMutableArray array];

		for (NSString *username in usernames) {
			NSString *userID = [self _userIDForUsername:username];
			if (userID == nil) {
				[fetchUsernames addObject:username];
			} else {
				[self _handleCallbackForUserID:userID result:[self _cacheItemForUserID:userID]];
			}
		}
		for (NSString *userID in userIDs) {
			HBTwitterAPIClientUserItem item = [self _cacheItemForUserID:userID];
			if (item == nil) {
				[fetchUserIDs addObject:userID];
			} else {
				[self _handleCallbackForUserID:userID result:item];
			}
		}

		[_usernameQueue addObjectsFromArray:fetchUsernames];
		[_userIDQueue addObjectsFromArray:fetchUserIDs];
		[self _processQueue];
	});
}

- (void)_processQueue {
	dispatch_async(_cacheQueue, ^{
		NSMutableArray <NSString *> *usernames = [NSMutableArray array];
		NSMutableArray <NSString *> *userIDs = [NSMutableArray array];

		for (NSString *item in _usernameQueue) {
			[usernames addObject:item];
			if (usernames.count == 100) {
				break;
			}
		}
		for (NSString *item in _userIDQueue) {
			[userIDs addObject:item];
			if (userIDs.count == 100) {
				break;
			}
		}

		[_usernameQueue removeObjectsInArray:usernames];
		[_userIDQueue removeObjectsInArray:userIDs];

		if (usernames.count > 0) {
			NSURL *url = [NSURL URLWithString:[@"https://api.twitter.com/2/users/by?" stringByAppendingString:@{
				@"usernames": [usernames componentsJoinedByString:@","],
				@"user.fields": @"profile_image_url"
			}.hb_queryString]];
			[self _lookUpUsersWithURL:url];
		}
		if (userIDs.count > 0) {
			NSURL *url = [NSURL URLWithString:[@"https://api.twitter.com/2/users?" stringByAppendingString:@{
				@"ids": [userIDs componentsJoinedByString:@","],
				@"user.fields": @"profile_image_url"
			}.hb_queryString]];
			[self _lookUpUsersWithURL:url];
		}

		// If there are still queries left over to be made, process the queue again
		if (_usernameQueue.count > 0 || _userIDQueue.count > 0) {
			[self _processQueue];
		}
	});
}

- (void)_lookUpUsersWithURL:(NSURL *)url {
#ifdef CEPHEI_TWITTER_BEARER_TOKEN
	dispatch_async(_cacheQueue, ^{
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
		[request setValue:kHBCepheiUserAgent forHTTPHeaderField:@"User-Agent"];
		[request setValue:CEPHEI_TWITTER_BEARER_TOKEN forHTTPHeaderField:@"Authorization"];

		Class $NSURLSession = objc_getClass("NSURLSession");
		[[[$NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			if (error != nil) {
				HBLogWarn(@"Cephei: Error querying Twitter API: %@", error);
				return;
			}
			NSDictionary <NSString *, id> *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
			if (error != nil) {
				HBLogWarn(@"Cephei: Error parsing Twitter API response: %@", error);
				return;
			}
			NSArray <NSDictionary <NSString *, id> *> *stuff = json[@"data"];
			for (NSDictionary <NSString *, id> *item in stuff) {
				if (![item[@"id"] isKindOfClass:NSString.class] || ![item[@"profile_image_url"] isKindOfClass:NSString.class] || ![item[@"username"] isKindOfClass:NSString.class]) {
					continue;
				}
				_cacheData[[@"id:" stringByAppendingString:item[@"id"]]] = @{
					@"username": item[@"username"],
					@"profile_image": [self _avatarKeyForUserID:item[@"id"] url:item[@"profile_image_url"]]
				};
				_cacheData[[@"name:" stringByAppendingString:item[@"username"]]] = @{
					@"id": item[@"id"]
				};
				[self _loadAvatarForUserID:item[@"id"] url:item[@"profile_image_url"]];
			}
			[self _saveCache];
		}] resume];
	});
#endif
}

- (void)_loadAvatarForUserID:(NSString *)userID url:(NSString *)url {
	NSURL *realURL = [NSURL URLWithString:[url stringByReplacingOccurrencesOfString:@"_normal" withString:@""]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:realURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
	[request setValue:kHBCepheiUserAgent forHTTPHeaderField:@"User-Agent"];

	Class $NSURLSession = objc_getClass("NSURLSession");
	[[[$NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (error != nil) {
			HBLogWarn(@"Cephei: Error loading avatar for user %@: %@", userID, error);
		}

		NSString *key = [self _avatarKeyForUserID:userID url:url];
		[data writeToURL:[_cacheURL URLByAppendingPathComponent:key] atomically:NO];
		[self _handleCallbackForUserID:userID result:[self _cacheItemForUserID:userID]];
	}] resume];
}

- (NSString *)_avatarKeyForUserID:(NSString *)userID url:(NSString *)url {
	return [NSString stringWithFormat:@"%@_%@", userID, [url.lastPathComponent.stringByDeletingPathExtension stringByReplacingOccurrencesOfString:@"_normal" withString:@""]];
}

- (void)_handleCallbackForUserID:(NSString *)userID result:(HBTwitterAPIClientUserItem)item {
	dispatch_async(_cacheQueue, ^{
		NSString *username = item[@"username"];
		NSData *data = [NSData dataWithContentsOfURL:[_cacheURL URLByAppendingPathComponent:item[@"profile_image"]]];
		UIImage *image = [UIImage imageWithData:data];
		if (image == nil) {
			return;
		}
		for (id <HBTwitterAPIClientDelegate> delegate in _delegates[userID]) {
			[delegate twitterAPIClientDidLoadUsername:item[@"username"] profileImage:image];
		}
		for (id <HBTwitterAPIClientDelegate> delegate in _delegates[username]) {
			[delegate twitterAPIClientDidLoadUsername:item[@"username"] profileImage:image];
		}
		[_delegates removeObjectForKey:userID];
		[_delegates removeObjectForKey:username];
	});
}

- (void)addDelegate:(id <HBTwitterAPIClientDelegate>)delegate forUsername:(nullable NSString *)username userID:(nullable NSString *)userID {
	NSParameterAssert(username != nil || userID != nil);
	if (username != nil) {
		NSMutableSet <id <HBTwitterAPIClientDelegate>> *delegates = _delegates[username];
		if (delegates == nil) {
			delegates = [NSMutableSet set];
			_delegates[username] = delegates;
		}
		[delegates addObject:delegate];
		if (![_usernameQueue containsObject:username]) {
			[self queueLookupsForUsernames:@[ username ] userIDs:@[]];
		}
	}
	if (userID != nil) {
		NSMutableSet <id <HBTwitterAPIClientDelegate>> *delegates = _delegates[userID];
		if (delegates == nil) {
			delegates = [NSMutableSet set];
			_delegates[userID] = delegates;
		}
		[delegates addObject:delegate];
		if (![_userIDQueue containsObject:userID]) {
			[self queueLookupsForUsernames:@[] userIDs:@[ userID ]];
		}
	}
}

- (void)removeDelegate:(id <HBTwitterAPIClientDelegate>)delegate forUsername:(nullable NSString *)username userID:(nullable NSString *)userID {
	if (username == nil && userID == nil) {
		for (NSString *key in _delegates.allKeys) {
			[_delegates[key] removeObject:delegate];
		}
	} else {
		if (username != nil) {
			[_delegates[username] removeObject:delegate];
		}
		if (userID != nil && ![_userIDQueue containsObject:userID]) {
			[_delegates[userID] removeObject:delegate];
		}
	}
}

@end
