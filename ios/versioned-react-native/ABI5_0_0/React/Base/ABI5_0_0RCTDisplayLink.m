/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI5_0_0RCTDisplayLink.h"

#import <Foundation/Foundation.h>
#import <QuartzCore/CADisplayLink.h>

#import "ABI5_0_0RCTAssert.h"
#import "ABI5_0_0RCTBridgeModule.h"
#import "ABI5_0_0RCTFrameUpdate.h"
#import "ABI5_0_0RCTModuleData.h"
#import "ABI5_0_0RCTProfile.h"

@implementation ABI5_0_0RCTDisplayLink
{
  CADisplayLink *_jsDisplayLink;
  NSMutableSet<ABI5_0_0RCTModuleData *> *_frameUpdateObservers;
  NSRunLoop *_runLoop;
}

- (instancetype)init
{
  if ((self = [super init])) {
    _frameUpdateObservers = [NSMutableSet new];
    _jsDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_jsThreadUpdate:)];
  }

  return self;
}

- (void)registerModuleForFrameUpdates:(id<ABI5_0_0RCTBridgeModule>)module
                       withModuleData:(ABI5_0_0RCTModuleData *)moduleData
{
  if ([_frameUpdateObservers containsObject:moduleData] ||
      ![moduleData.moduleClass conformsToProtocol:@protocol(ABI5_0_0RCTFrameUpdateObserver)]) {
    return;
  }

  [_frameUpdateObservers addObject:moduleData];
  // Don't access the module instance via moduleData, as this will cause deadlock
  id<ABI5_0_0RCTFrameUpdateObserver> observer = (id<ABI5_0_0RCTFrameUpdateObserver>)module;
  __weak typeof(self) weakSelf = self;
  observer.pauseCallback = ^{
    typeof(self) strongSelf = weakSelf;
    if (!strongSelf) {
      return;
    }

    CFRunLoopRef cfRunLoop = [strongSelf->_runLoop getCFRunLoop];

    if (!_runLoop) {
      return;
    }

    CFRunLoopPerformBlock(cfRunLoop, kCFRunLoopDefaultMode, ^{
                            [weakSelf updateJSDisplayLinkState];
                          });
    CFRunLoopWakeUp(cfRunLoop);
  };
}

- (void)addToRunLoop:(NSRunLoop *)runLoop
{
  _runLoop = runLoop;
  [_jsDisplayLink addToRunLoop:runLoop forMode:NSRunLoopCommonModes];
}

- (void)invalidate
{
  [_jsDisplayLink invalidate];
}

- (void)assertOnRunLoop
{
  ABI5_0_0RCTAssert(_runLoop == [NSRunLoop currentRunLoop],
            @"This method must be called on the CADisplayLink run loop");
}

- (void)dispatchBlock:(dispatch_block_t)block
                queue:(dispatch_queue_t)queue
{
  if (queue == ABI5_0_0RCTJSThread) {
    block();
  } else if (queue) {
    dispatch_async(queue, block);
  }
}

- (void)_jsThreadUpdate:(CADisplayLink *)displayLink
{
  [self assertOnRunLoop];

  ABI5_0_0RCT_PROFILE_BEGIN_EVENT(0, @"-[ABI5_0_0RCTDisplayLink _jsThreadUpdate:]", nil);

  ABI5_0_0RCTFrameUpdate *frameUpdate = [[ABI5_0_0RCTFrameUpdate alloc] initWithDisplayLink:displayLink];
  for (ABI5_0_0RCTModuleData *moduleData in _frameUpdateObservers) {
    id<ABI5_0_0RCTFrameUpdateObserver> observer = (id<ABI5_0_0RCTFrameUpdateObserver>)moduleData.instance;
    if (!observer.paused) {
      ABI5_0_0RCTProfileBeginFlowEvent();

      [self dispatchBlock:^{
        ABI5_0_0RCTProfileEndFlowEvent();
        [observer didUpdateFrame:frameUpdate];
      } queue:moduleData.methodQueue];
    }
  }

  [self updateJSDisplayLinkState];

  ABI5_0_0RCTProfileImmediateEvent(0, @"JS Thread Tick", displayLink.timestamp, 'g');

  ABI5_0_0RCT_PROFILE_END_EVENT(0, @"objc_call", nil);
}

- (void)updateJSDisplayLinkState
{
  [self assertOnRunLoop];

  BOOL pauseDisplayLink = YES;
  for (ABI5_0_0RCTModuleData *moduleData in _frameUpdateObservers) {
    id<ABI5_0_0RCTFrameUpdateObserver> observer = (id<ABI5_0_0RCTFrameUpdateObserver>)moduleData.instance;
    if (!observer.paused) {
      pauseDisplayLink = NO;
      break;
    }
  }
  _jsDisplayLink.paused = pauseDisplayLink;
}

@end
