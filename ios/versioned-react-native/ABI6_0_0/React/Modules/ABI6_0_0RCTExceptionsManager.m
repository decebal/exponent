/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI6_0_0RCTExceptionsManager.h"

#import "ABI6_0_0RCTConvert.h"
#import "ABI6_0_0RCTDefines.h"
#import "ABI6_0_0RCTLog.h"
#import "ABI6_0_0RCTRedBox.h"
#import "ABI6_0_0RCTRootView.h"

@implementation ABI6_0_0RCTExceptionsManager
{
  __weak id<ABI6_0_0RCTExceptionsManagerDelegate> _delegate;
  NSUInteger _reloadRetries;
}

@synthesize bridge = _bridge;

ABI6_0_0RCT_EXPORT_MODULE()

- (instancetype)initWithDelegate:(id<ABI6_0_0RCTExceptionsManagerDelegate>)delegate
{
  if ((self = [self init])) {
    _delegate = delegate;
  }
  return self;
}

ABI6_0_0RCT_EXPORT_METHOD(reportSoftException:(NSString *)message
                  stack:(NSArray<NSDictionary *> *)stack
                  exceptionId:(nonnull NSNumber *)exceptionId)
{
  [_bridge.redBox showErrorMessage:message withStack:stack];

  if (_delegate) {
    [_delegate handleSoftJSExceptionWithMessage:message stack:stack exceptionId:exceptionId];
  }
}

ABI6_0_0RCT_EXPORT_METHOD(reportFatalException:(NSString *)message
                  stack:(NSArray<NSDictionary *> *)stack
                  exceptionId:(nonnull NSNumber *)exceptionId)
{
  [_bridge.redBox showErrorMessage:message withStack:stack];

  if (_delegate) {
    [_delegate handleFatalJSExceptionWithMessage:message stack:stack exceptionId:exceptionId];
  }

  static NSUInteger reloadRetries = 0;
  if (!ABI6_0_0RCT_DEBUG && reloadRetries < _maxReloadAttempts) {
    reloadRetries++;
    [[NSNotificationCenter defaultCenter] postNotificationName:ABI6_0_0RCTReloadNotification object:_bridge.baseBridge];
  } else {
    NSString *description = [@"Unhandled JS Exception: " stringByAppendingString:message];
    NSDictionary *errorInfo = @{ NSLocalizedDescriptionKey: description, ABI6_0_0RCTJSStackTraceKey: stack };
    ABI6_0_0RCTFatal([NSError errorWithDomain:ABI6_0_0RCTErrorDomain code:0 userInfo:errorInfo]);
  }
}

ABI6_0_0RCT_EXPORT_METHOD(updateExceptionMessage:(NSString *)message
                  stack:(NSArray<NSDictionary *> *)stack
                  exceptionId:(nonnull NSNumber *)exceptionId)
{
  [_bridge.redBox updateErrorMessage:message withStack:stack];

  if (_delegate && [_delegate respondsToSelector:@selector(updateJSExceptionWithMessage:stack:exceptionId:)]) {
    [_delegate updateJSExceptionWithMessage:message stack:stack exceptionId:exceptionId];
  }
}

// Deprecated.  Use reportFatalException directly instead.
ABI6_0_0RCT_EXPORT_METHOD(reportUnhandledException:(NSString *)message
                  stack:(NSArray<NSDictionary *> *)stack)
{
  [self reportFatalException:message stack:stack exceptionId:@-1];
}

@end
