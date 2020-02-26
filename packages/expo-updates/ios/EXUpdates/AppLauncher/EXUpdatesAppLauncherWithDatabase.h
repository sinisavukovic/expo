//  Copyright © 2019 650 Industries. All rights reserved.

#import <EXUpdates/EXUpdatesAppLauncher.h>
#import <EXUpdates/EXUpdatesSelectionPolicy.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^EXUpdatesAppLauncherCompletionBlock)(NSError * _Nullable error, BOOL success);

@interface EXUpdatesAppLauncherWithDatabase : NSObject <EXUpdatesAppLauncher>

- (void)launchUpdateWithSelectionPolicy:(id<EXUpdatesSelectionPolicy>)selectionPolicy
                             completion:(EXUpdatesAppLauncherCompletionBlock)completion;

+ (nullable EXUpdatesUpdate *)launchableUpdateWithSelectionPolicy:(id<EXUpdatesSelectionPolicy>)selectionPolicy;

@end

NS_ASSUME_NONNULL_END
