//
// Created by wish8 on 11/26/15.
// Copyright (c) 2015 oSolve. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView;


@interface WESnowfallAnimation : NSObject
- (instancetype)initWithTarget:(UIView *) target duration:(NSTimeInterval) duration images:(NSArray *) images;

- (void)start;
@end