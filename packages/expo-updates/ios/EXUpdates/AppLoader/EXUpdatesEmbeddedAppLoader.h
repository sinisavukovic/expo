//  Copyright © 2019 650 Industries. All rights reserved.

#import <EXUpdates/EXUpdatesAppLoader+Private.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kEXUpdatesEmbeddedManifestName;
extern NSString * const kEXUpdatesEmbeddedManifestType;
extern NSString * const kEXUpdatesEmbeddedBundleFilename;
extern NSString * const kEXUpdatesEmbeddedBundleFileType;

@interface EXUpdatesEmbeddedAppLoader : EXUpdatesAppLoader

+ (EXUpdatesUpdate * _Nullable)embeddedManifest;
- (void)loadUpdateFromEmbeddedManifest;

@end

NS_ASSUME_NONNULL_END
