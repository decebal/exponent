/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIScrollView.h>

#import "ABI6_0_0RCTAutoInsetsProtocol.h"
#import "ABI6_0_0RCTEventDispatcher.h"
#import "ABI6_0_0RCTScrollableProtocol.h"
#import "ABI6_0_0RCTView.h"

@protocol UIScrollViewDelegate;

@interface ABI6_0_0RCTScrollView : ABI6_0_0RCTView <UIScrollViewDelegate, ABI6_0_0RCTScrollableProtocol, ABI6_0_0RCTAutoInsetsProtocol>

- (instancetype)initWithEventDispatcher:(ABI6_0_0RCTEventDispatcher *)eventDispatcher NS_DESIGNATED_INITIALIZER;

/**
 * The `ABI6_0_0RCTScrollView` may have at most one single subview. This will ensure
 * that the scroll view's `contentSize` will be efficiently set to the size of
 * the single subview's frame. That frame size will be determined somewhat
 * efficiently since it will have already been computed by the off-main-thread
 * layout system.
 */
@property (nonatomic, readonly) UIView *contentView;

/**
 * If the `contentSize` is not specified (or is specified as {0, 0}, then the
 * `contentSize` will automatically be determined by the size of the subview.
 */
@property (nonatomic, assign) CGSize contentSize;

/**
 * The underlying scrollView (TODO: can we remove this?)
 */
@property (nonatomic, readonly) UIScrollView *scrollView;

@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) BOOL automaticallyAdjustContentInsets;
@property (nonatomic, assign) NSTimeInterval scrollEventThrottle;
@property (nonatomic, assign) BOOL centerContent;
@property (nonatomic, assign) int snapToInterval;
@property (nonatomic, copy) NSString *snapToAlignment;
@property (nonatomic, copy) NSIndexSet *stickyHeaderIndices;

// NOTE: currently these event props are only declared so we can export the
// event names to JS - we don't call the blocks directly because scroll events
// need to be coalesced before sending, for performance reasons.
@property (nonatomic, copy) ABI6_0_0RCTDirectEventBlock onScrollBeginDrag;
@property (nonatomic, copy) ABI6_0_0RCTDirectEventBlock onScroll;
@property (nonatomic, copy) ABI6_0_0RCTDirectEventBlock onScrollEndDrag;
@property (nonatomic, copy) ABI6_0_0RCTDirectEventBlock onMomentumScrollBegin;
@property (nonatomic, copy) ABI6_0_0RCTDirectEventBlock onMomentumScrollEnd;
@property (nonatomic, copy) ABI6_0_0RCTDirectEventBlock onScrollAnimationEnd;

// Pull-to-refresh support (deprecated - use ABI6_0_0RCTPullToRefreshControl instead)
@property (nonatomic, copy) ABI6_0_0RCTDirectEventBlock onRefreshStart;
- (void)endRefreshing;

@end

@interface ABI6_0_0RCTEventDispatcher (ABI6_0_0RCTScrollView)

/**
 * Send a fake scroll event.
 */
- (void)sendFakeScrollEvent:(NSNumber *)ReactABI6_0_0Tag;

@end
