// Copyright 2015-present 650 Industries. All rights reserved.

#import "EXVersions.h"

@interface EXVersions ()

- (void)_loadVersions;

@end

@implementation NSString (EXVersions)

- (NSArray <NSNumber *>*)versionComponents
{
  NSArray *stringComponents = [self componentsSeparatedByString:@"."];
  NSMutableArray <NSNumber *>* components = [NSMutableArray arrayWithCapacity:stringComponents.count];
  for (NSString *component in stringComponents) {
    [components addObject:@([component integerValue])];
  }
  return components;
}

@end

@implementation EXVersions

+ (nonnull instancetype)sharedInstance
{
  static EXVersions *theVersions;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    if (!theVersions) {
      theVersions = [[EXVersions alloc] init];
    }
  });
  return theVersions;
}

- (instancetype)init
{
  if (self = [super init]) {
    [self _loadVersions];
  }
  return self;
}

+ (NSString *)versionedString:(NSString *)string withPrefix:(NSString *)versionPrefix
{
  if (!string ||!versionPrefix) {
    return nil;
  }
  return [NSString stringWithFormat:@"%@%@", versionPrefix, string];
}

- (NSString *)symbolPrefixForManifest:(NSDictionary * _Nullable)manifest
{
  return [self _versionForManifest:manifest computePrefix:YES];
}

- (NSString *)versionForManifest:(NSDictionary * _Nullable)manifest
{
  return [self _versionForManifest:manifest computePrefix:NO];
}

#pragma mark - Internal

- (NSString *)_versionForManifest:(NSDictionary * _Nullable)manifest computePrefix: (BOOL)computePrefix
{
  if (manifest && manifest[@"sdkVersion"]) {
    NSString *sdkVersion = manifest[@"sdkVersion"];
    NSArray *sdkVersions = _versions[@"sdkVersions"];
    if (sdkVersion && sdkVersions) {
      for (NSString *availableVersion in sdkVersions) {
        if ([sdkVersion isEqualToString:availableVersion]) {
  #ifdef TEMPORARY_SDK_VERSION
          NSArray <NSNumber *>* versionComponents = [availableVersion versionComponents];
          BOOL isTemporary = (versionComponents.count > 1 && versionComponents[1].integerValue != 0);
          if (isTemporary && [availableVersion isEqualToString:TEMPORARY_SDK_VERSION]) {
            // no prefix if we're just using the current version
            break;
          }
  #endif
          if (computePrefix) {
            return [[@"ABI" stringByAppendingString:availableVersion] stringByReplacingOccurrencesOfString:@"." withString:@"_"];
          } else {
            return availableVersion;
          }
        }
      }
    }
  }
  return @"";
}

- (void)_loadVersions
{
  NSString *versionsPath = [[NSBundle mainBundle] pathForResource:@"EXSDKVersions" ofType:@"plist"];
  NSMutableDictionary *mutableVersions = (versionsPath) ? [NSMutableDictionary dictionaryWithContentsOfFile:versionsPath] : [NSMutableDictionary dictionary];
#ifdef TEMPORARY_SDK_VERSION
  if (mutableVersions[@"sdkVersions"]) {
    NSArray *existingVersions = mutableVersions[@"sdkVersions"];
    if ([existingVersions indexOfObject:TEMPORARY_SDK_VERSION] == NSNotFound) {
      mutableVersions[@"sdkVersions"] = [[existingVersions mutableCopy] arrayByAddingObject:TEMPORARY_SDK_VERSION];
    }
  }
#endif
  _versions = mutableVersions;
}

@end
