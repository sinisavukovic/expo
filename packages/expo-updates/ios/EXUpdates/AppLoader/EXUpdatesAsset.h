//  Copyright © 2019 650 Industries. All rights reserved.

@interface EXUpdatesAsset : NSObject

/**
 * properties determined by asset source
 */
@property (nonatomic, strong) NSURL * _Nonnull url;
@property (nonatomic, strong) NSString * _Nonnull type;
@property (nonatomic, strong) NSDictionary * _Nullable metadata;
@property (nonatomic, strong) NSString * _Nullable mainBundleFilename; // used for embedded assets
@property (nonatomic, assign) BOOL isLaunchAsset;

/**
 * properties determined at runtime by updates implementation
 */
@property (nonatomic, strong) NSDate * _Nullable downloadTime;
@property (nonatomic, strong) NSString * _Nullable filename;
@property (nonatomic, strong) NSString * _Nullable contentHash;
@property (nonatomic, strong) NSDictionary * _Nullable headers;

@property (nonatomic, strong) NSString * _Nullable localAssetsKey;

- (instancetype _Nonnull)initWithUrl:(NSURL * _Nonnull)url type:(NSString * _Nonnull)type;

@end
