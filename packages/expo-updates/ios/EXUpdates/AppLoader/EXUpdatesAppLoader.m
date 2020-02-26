//  Copyright © 2019 650 Industries. All rights reserved.

#import <EXUpdates/EXUpdatesAppController.h>
#import <EXUpdates/EXUpdatesAppLoader+Private.h>
#import <EXUpdates/EXUpdatesDatabase.h>
#import <EXUpdates/EXUpdatesFileDownloader.h>
#import <EXUpdates/EXUpdatesUtils.h>

NS_ASSUME_NONNULL_BEGIN

@interface EXUpdatesAppLoader ()

@property (nonatomic, strong) NSMutableArray<EXUpdatesAsset *> *assetQueue;
@property (nonatomic, strong) NSMutableArray<EXUpdatesAsset *> *erroredAssets;
@property (nonatomic, strong) NSMutableArray<EXUpdatesAsset *> *finishedAssets;
@property (nonatomic, strong) NSMutableArray<EXUpdatesAsset *> *existingAssets;

@property (nonatomic, strong) NSLock *arrayLock;

@property (nonatomic, strong) dispatch_queue_t databaseLockThread;

@end

static NSString * const kEXUpdatesAppLoaderErrorDomain = @"EXUpdatesAppLoader";

@implementation EXUpdatesAppLoader

- (instancetype)init
{
  if (self = [super init]) {
    _assetQueue = [NSMutableArray new];
    _erroredAssets = [NSMutableArray new];
    _finishedAssets = [NSMutableArray new];
    _existingAssets = [NSMutableArray new];
    _arrayLock = [[NSLock alloc] init];
    _databaseLockThread = dispatch_queue_create("expo.database.LockQueue", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (void)_reset
{
  _assetQueue = [NSMutableArray new];
  _erroredAssets = [NSMutableArray new];
  _finishedAssets = [NSMutableArray new];
  _existingAssets = [NSMutableArray new];
  _updateManifest = nil;
}

# pragma mark - subclass methods

- (void)loadUpdateFromUrl:(NSURL *)url
{
  @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Should not call EXUpdatesAppLoader#loadUpdate -- use a subclass instead" userInfo:nil];
}

- (void)downloadAsset:(EXUpdatesAsset *)asset
{
  @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Should not call EXUpdatesAppLoader#loadUpdate -- use a subclass instead" userInfo:nil];
}

# pragma mark - loading and database logic

- (void)startLoadingFromManifest:(EXUpdatesUpdate *)updateManifest
{
  if (_delegate) {
    BOOL shouldContinue = [_delegate appLoader:self shouldStartLoadingUpdate:updateManifest];
    if (!shouldContinue) {
      [_delegate appLoader:self didFinishLoadingUpdate:nil];
      return;
    }
  }

  [self _lockDatabase];

  EXUpdatesDatabase *database = [EXUpdatesAppController sharedInstance].database;
  NSError *existingUpdateError;
  EXUpdatesUpdate *existingUpdate = [database updateWithId:updateManifest.updateId error:&existingUpdateError];
  if (existingUpdate && existingUpdate.status == EXUpdatesUpdateStatusReady) {
    [self _unlockDatabase];
    [_delegate appLoader:self didFinishLoadingUpdate:updateManifest];
  } else {
    if (existingUpdate) {
      // we've already partially downloaded the update.
      // however, it's not ready, so we should try to download all the assets again.
      _updateManifest = updateManifest;
    } else {
      if (existingUpdateError) {
        NSLog(@"Failed to select old update from DB: %@", existingUpdateError.localizedDescription);
      }
      // no update already exists with this ID, so we need to insert it and download everything.
      _updateManifest = updateManifest;
      NSError *updateError;
      [database addUpdate:_updateManifest error:&updateError];
      
      if (updateError) {
        [self _finishWithError:updateError];
        return;
      }
    }

    _assetQueue = [_updateManifest.assets mutableCopy];

    for (EXUpdatesAsset *asset in _updateManifest.assets) {
      [self downloadAsset:asset];
    }
  }
}

- (void)handleAssetDownloadAlreadyExists:(EXUpdatesAsset *)asset
{
  [_arrayLock lock];
  [self->_assetQueue removeObject:asset];
  [self->_existingAssets addObject:asset];
  if (![self->_assetQueue count]) {
    [self _finish];
  }
  [_arrayLock unlock];
}

- (void)handleAssetDownloadWithError:(NSError *)error asset:(EXUpdatesAsset *)asset
{
  // TODO: retry. for now log an error
  NSLog(@"error loading file: %@: %@", asset.url.absoluteString, error.localizedDescription);
  [_arrayLock lock];
  [self->_assetQueue removeObject:asset];
  [self->_erroredAssets addObject:asset];
  if (![self->_assetQueue count]) {
    [self _finish];
  }
  [_arrayLock unlock];
}

- (void)handleAssetDownloadWithData:(NSData *)data response:(nullable NSURLResponse *)response asset:(EXUpdatesAsset *)asset
{
  [_arrayLock lock];
  [self->_assetQueue removeObject:asset];

  if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
    asset.headers = ((NSHTTPURLResponse *)response).allHeaderFields;
  }
  asset.contentHash = [EXUpdatesUtils sha256WithData:data];
  asset.downloadTime = [NSDate date];
  [self->_finishedAssets addObject:asset];

  if (![self->_assetQueue count]) {
    [self _finish];
  }
  [_arrayLock unlock];
}

# pragma mark - internal

- (void)_finishWithError:(NSError *)error
{
  [self _unlockDatabase];
  if (_delegate) {
    [_delegate appLoader:self didFailWithError:error];
  }
  [self _reset];
}

- (void)_finish
{
  EXUpdatesDatabase *database = [EXUpdatesAppController sharedInstance].database;
  for (EXUpdatesAsset *existingAsset in _existingAssets) {
    NSError *error;
    BOOL existingAssetFound = [database addExistingAsset:existingAsset toUpdateWithId:_updateManifest.updateId error:&error];
    if (!existingAssetFound) {
      // the database and filesystem have gotten out of sync
      // do our best to create a new entry for this file even though it already existed on disk
      NSData *contents = [NSData dataWithContentsOfURL:[[EXUpdatesAppController sharedInstance].updatesDirectory URLByAppendingPathComponent:existingAsset.filename]];
      existingAsset.contentHash = [EXUpdatesUtils sha256WithData:contents];
      existingAsset.downloadTime = [NSDate date];
      [_finishedAssets addObject:existingAsset];
    }
    if (error) {
      NSLog(@"Error searching for existing asset in DB: %@", error.localizedDescription);
    }
  }
  NSError *assetError;
  [database addNewAssets:_finishedAssets toUpdateWithId:_updateManifest.updateId error:&assetError];
  if (assetError) {
    [self _finishWithError:assetError];
    return;
  }

  if (![_erroredAssets count]) {
    NSError *updateReadyError;
    [database markUpdateReadyWithId:_updateManifest.updateId error:&updateReadyError];
    if (updateReadyError) {
      [self _finishWithError:updateReadyError];
      return;
    }
  }
  [self _unlockDatabase];

  if (_delegate) {
    if ([_erroredAssets count]) {
      [_delegate appLoader:self didFailWithError:[NSError errorWithDomain:kEXUpdatesAppLoaderErrorDomain
                                                                     code:1012
                                                                 userInfo:@{NSLocalizedDescriptionKey: @"Failed to load all assets"}]];
    } else {
      [_delegate appLoader:self didFinishLoadingUpdate:_updateManifest];
    }
  }

  [self _reset];
}

# pragma mark - helpers

- (void)_lockDatabase
{
  dispatch_sync(_databaseLockThread, ^{
    [[EXUpdatesAppController sharedInstance].database.lock lock];
  });
}

- (void)_unlockDatabase
{
  dispatch_sync(_databaseLockThread, ^{
    [[EXUpdatesAppController sharedInstance].database.lock unlock];
  });
}

@end

NS_ASSUME_NONNULL_END
