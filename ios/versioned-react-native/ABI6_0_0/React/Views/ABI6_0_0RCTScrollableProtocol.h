/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

/**
 * Contains any methods related to scrolling. Any `ABI6_0_0RCTView` that has scrolling
 * features should implement these methods.
 */
@protocol ABI6_0_0RCTScrollableProtocol

/*
 * The nativeScrollDelegate property is now deprecated please use the scrollListener API instead
 */
@property (nonatomic, weak) NSObject<UIScrollViewDelegate> *nativeScrollDelegate DEPRECATED_ATTRIBUTE;
@property (nonatomic, readonly) CGSize contentSize;

- (void)scrollToOffset:(CGPoint)offset;
- (void)scrollToOffset:(CGPoint)offset animated:(BOOL)animated;
- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated;

- (void)addScrollListener:(NSObject<UIScrollViewDelegate> *)scrollListener;
- (void)removeScrollListener:(NSObject<UIScrollViewDelegate> *)scrollListener;

@end
