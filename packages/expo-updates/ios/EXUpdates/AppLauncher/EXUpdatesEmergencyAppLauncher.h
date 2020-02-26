//  Copyright © 2019 650 Industries. All rights reserved.

#import <EXUpdates/EXUpdatesAppLauncher.h>

NS_ASSUME_NONNULL_BEGIN

@interface EXUpdatesEmergencyAppLauncher : NSObject <EXUpdatesAppLauncher>

- (void)launchUpdateWithFatalError:(NSError *)error;
+ (NSString * _Nullable)consumeError;

@end

NS_ASSUME_NONNULL_END

