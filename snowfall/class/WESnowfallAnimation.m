//
// Created by wish8 on 11/26/15.
// Copyright (c) 2015 oSolve. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WESnowfallAnimation.h"


static NSString *const AnimationGroupKey = @"animationGroup";
static NSString *const LayerKey = @"layer";

@interface WESnowfallAnimation()<CAAnimationDelegate>
@property (nonatomic, strong) UIView *target;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, strong) NSDate *beginTime;
@property (nonatomic, strong) CALayer *animationBackgroundLayer;
@property (nonatomic, strong) NSArray *images;
@end

@implementation WESnowfallAnimation
- (instancetype)initWithTarget:(UIView *) target duration:(NSTimeInterval) duration images:(NSArray *) images {
    self = [super init];
    if (self) {
        self.target = target;
        self.duration = duration;
        self.images = images;
        self.animationBackgroundLayer = [CALayer layer];
    }
    return self;
}

- (void)start {
    self.beginTime = [NSDate date];
    [self.target.layer addSublayer:self.animationBackgroundLayer];
    [self startSnowflakeAnimation];
}

#pragma mark Private

- (void)startSnowflakeAnimation {
    UIImage *image = self.images[arc4random_uniform(self.images.count)];
    CALayer *imageLayer = [CALayer layer];
    imageLayer.contents = (id) image.CGImage;
    [imageLayer setFrame:CGRectMake(-image.size.width, -image.size.height, image.size.width, image.size.height)];

    NSUInteger width = (NSUInteger) CGRectGetWidth(self.target.frame);

    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    CGPoint startPoint = CGPointMake(arc4random_uniform(width), -image.size.height);
    [bezierPath moveToPoint:startPoint];
    NSUInteger numberOfPoints = arc4random_uniform(2) + 1;
    CGFloat y = CGRectGetHeight(self.target.frame);
    CGPoint endPoint = CGPointMake(((CGFloat) arc4random_uniform(width * 3) - (CGFloat) width), y);
    if (numberOfPoints == 1) {
        [bezierPath addQuadCurveToPoint:endPoint
                           controlPoint:CGPointMake(100, y / 2)];
    } else {
        [bezierPath addCurveToPoint:endPoint controlPoint1:CGPointMake(100, y / 3)
                      controlPoint2:CGPointMake(300, y / 3 * 2)];
    }

    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.beginTime = CACurrentMediaTime() + arc4random_uniform(3) + 1;
    animationGroup.duration = arc4random_uniform(5) + 8 * numberOfPoints;
    animationGroup.repeatCount = 1;
    animationGroup.delegate = self;

    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.path = bezierPath.CGPath;

    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = @0.f;
    rotateAnimation.toValue = @(2 * M_PI * arc4random_uniform(5));

    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.values = @[@1, @1, @.7, @.6];
    opacityAnimation.keyTimes = @[@0, @.6, @.8, @1];
    opacityAnimation.calculationMode = kCAAnimationPaced;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = NO;

    animationGroup.animations = @[positionAnimation, rotateAnimation, opacityAnimation];
    [animationGroup setValue:imageLayer forKey:LayerKey];
    [imageLayer addAnimation:animationGroup forKey:AnimationGroupKey];
    [self.animationBackgroundLayer addSublayer:imageLayer];
}

#pragma mark CAAnimation

- (void)animationDidStart:(CAAnimation *) anim {
    if ([[NSDate date] timeIntervalSinceDate:self.beginTime] <= self.duration) {
        [self startSnowflakeAnimation];
    }
}

- (void)animationDidStop:(CAAnimation *) anim finished:(BOOL) flag {
    CALayer *layer = [((CAAnimationGroup *) anim) valueForKey:LayerKey];
    [layer removeFromSuperlayer];
    if (!self.animationBackgroundLayer.sublayers) {
        [self.animationBackgroundLayer removeFromSuperlayer];
    }
}

@end