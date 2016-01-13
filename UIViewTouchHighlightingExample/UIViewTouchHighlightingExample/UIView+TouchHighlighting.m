/*
 * Copyright (C) 2015 Muhammad Tayyab Akram
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <objc/runtime.h>
#import "UIView+TouchHighlighting.h"

@implementation UIView (TouchHighlighting)

static const void *UIViewTouchHighlightingStyleKey = &UIViewTouchHighlightingStyleKey;
static const void *UIViewMaskLayerKey = &UIViewMaskLayerKey;
static const void *UIViewRealBackgroundKey = &UIViewRealBackgroundKey;
static const void *UIViewRealMaskKey = &UIViewRealMaskKey;

- (MTHighlightingStyle)touchHighlightingStyle {
    return [objc_getAssociatedObject(self, UIViewTouchHighlightingStyleKey) integerValue];
}

- (void)setTouchHighlightingStyle:(MTHighlightingStyle)touchHighlightingStyle {
    objc_setAssociatedObject(self, UIViewTouchHighlightingStyleKey, @(touchHighlightingStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CALayer *)mt_highlightingLayer {
    return objc_getAssociatedObject(self, UIViewMaskLayerKey);
}

- (void)mt_setHighlightingLayer:(CALayer *)layer {
    objc_setAssociatedObject(self, UIViewMaskLayerKey, layer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)mt_realBackground {
    return objc_getAssociatedObject(self, UIViewRealBackgroundKey);
}

- (void)mt_setRealBackground:(UIColor *)realBackground {
    objc_setAssociatedObject(self, UIViewRealBackgroundKey, realBackground, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CALayer *)mt_realMask {
    return objc_getAssociatedObject(self, UIViewRealMaskKey);
}

- (void)mt_setRealMask:(CALayer *)mask {
    objc_setAssociatedObject(self, UIViewRealMaskKey, mask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)mt_zeroedFrame {
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = self.frame.size;

    return frame;
}

- (UIImage *)mt_generateLayerImage {
    UIImage *outputImage = nil;

    UIGraphicsBeginImageContextWithOptions(self.layer.frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    [self.layer renderInContext:context];
    outputImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return outputImage;
}

- (void)mt_highlight {
    MTHighlightingStyle highlightingStyle = self.touchHighlightingStyle;

    switch (highlightingStyle) {
        case MTHighlightingStyleTransparentMask:
            {
                CALayer *maskLayer = [self mt_highlightingLayer];
                if (!maskLayer) {
                    maskLayer = [CALayer layer];
                    maskLayer.backgroundColor = [UIColor blackColor].CGColor;
                    maskLayer.opacity = 0.5;

                    [self mt_setHighlightingLayer:maskLayer];
                }

                maskLayer.frame = [self mt_zeroedFrame];
                [self mt_setRealMask:self.layer.mask];
                self.layer.mask = maskLayer;
            }
            break;

        case MTHighlightingStyleLightBackground:
            {
                [self mt_setRealBackground:self.backgroundColor];
                self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.075];
            }
            break;

        case MTHighlightingStyleSolidDarkOverlay:
            {
                CALayer *overlayLayer = [CALayer layer];
                overlayLayer.backgroundColor = [UIColor blackColor].CGColor;
                overlayLayer.opacity = 0.5;
                overlayLayer.frame = [self mt_zeroedFrame];

                [self mt_setHighlightingLayer:overlayLayer];
                [self.layer addSublayer:overlayLayer];
            }
            break;

        case MTHighlightingStyleHollowDarkOverlay:
            {
                CALayer *maskLayer = [CALayer layer];
                maskLayer.contents = (id)[self mt_generateLayerImage].CGImage;
                maskLayer.frame = [self mt_zeroedFrame];

                CALayer *overlayLayer = [CALayer layer];
                overlayLayer.mask = maskLayer;
                overlayLayer.backgroundColor = [UIColor blackColor].CGColor;
                overlayLayer.opacity = 0.5;
                overlayLayer.frame = [self mt_zeroedFrame];

                [self mt_setHighlightingLayer:overlayLayer];
                [self.layer addSublayer:overlayLayer];
            }
            break;

        default:
            break;
    }
}

- (void)mt_unhighlight {
    MTHighlightingStyle highlightingStyle = self.touchHighlightingStyle;

    switch (highlightingStyle) {
        case MTHighlightingStyleTransparentMask:
            {
                self.layer.mask = [self mt_realMask];
                [self mt_setRealMask:nil];
            }
            break;

        case MTHighlightingStyleLightBackground:
            {
                self.backgroundColor = [self mt_realBackground];
                [self mt_setRealBackground:nil];
            }
            break;

        case MTHighlightingStyleSolidDarkOverlay:
            {
                [[self mt_highlightingLayer] removeFromSuperlayer];
                [self mt_setHighlightingLayer:nil];
            }
            break;

        case MTHighlightingStyleHollowDarkOverlay:
            {
                [[self mt_highlightingLayer] removeFromSuperlayer];
                [self mt_setHighlightingLayer:nil];
            }
            break;

        default:
            break;
    }
}

@end

@implementation UIResponder (TouchHighlighting)

static void (*UIResponderTouchesBeganIMP)(id self, SEL _cmd, NSSet *touches, UIEvent *event) = NULL;
static void (*UIResponderTouchesMovedIMP)(id self, SEL _cmd, NSSet *touches, UIEvent *event) = NULL;
static void (*UIResponderTouchesEndedIMP)(id self, SEL _cmd, NSSet *touches, UIEvent *event) = NULL;
static void (*UIResponderTouchesCancelledIMP)(id self, SEL _cmd, NSSet *touches, UIEvent *event) = NULL;

static void mt_swizzleInstanceMethod(Class class, SEL name, IMP replacement, IMP *original) {
    Method method = class_getInstanceMethod(class, name);
    IMP imp = NULL;

    if (method) {
        imp = class_replaceMethod(class,
                                  name,
                                  replacement,
                                  method_getTypeEncoding(method));
        if (!imp) {
            imp = method_getImplementation(method);
        }
    }

    if (imp && original) {
        *original = imp;
    } else {
        *original = NULL;
    }
}

static void mt_touchesBegan(id self, SEL _cmd, NSSet *touches, UIEvent *event) {
    if ([self isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)self;
        [view mt_highlight];
    }

    UIResponderTouchesBeganIMP(self, _cmd, touches, event);
}

static void mt_touchesMoved(id self, SEL _cmd, NSSet *touches, UIEvent *event) {
    UIResponderTouchesMovedIMP(self, _cmd, touches, event);
}

static void mt_touchesEnded(id self, SEL _cmd, NSSet *touches, UIEvent *event) {
    if ([self isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)self;
        [view mt_unhighlight];
    }

    UIResponderTouchesEndedIMP(self, _cmd, touches, event);
}

static void mt_touchesCancelled(id self, SEL _cmd, NSSet *touches, UIEvent *event) {
    if ([self isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)self;
        [view mt_unhighlight];
    }

    UIResponderTouchesCancelledIMP(self, _cmd, touches, event);
}

+ (void)load {
    mt_swizzleInstanceMethod(self,
                             @selector(touchesBegan:withEvent:),
                             (IMP)mt_touchesBegan,
                             (IMP *)&UIResponderTouchesBeganIMP);
    mt_swizzleInstanceMethod(self,
                             @selector(touchesEnded:withEvent:),
                             (IMP)mt_touchesEnded,
                             (IMP *)&UIResponderTouchesEndedIMP);
    mt_swizzleInstanceMethod(self,
                             @selector(touchesMoved:withEvent:),
                             (IMP)mt_touchesMoved,
                             (IMP *)&UIResponderTouchesMovedIMP);
    mt_swizzleInstanceMethod(self,
                             @selector(touchesCancelled:withEvent:),
                             (IMP)mt_touchesCancelled,
                             (IMP *)&UIResponderTouchesCancelledIMP);
}

@end
