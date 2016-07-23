/*
 * Copyright (C) 2016 Muhammad Tayyab Akram
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

#pragma mark - Class - Method Swizzling

static void ClassSwizzleInstanceMethod(Class class, SEL name, IMP replacement, IMP *original) {
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

#pragma mark - UIView - Touch Highlighting

static const void *UIViewTouchHighlightingStyleKey = &UIViewTouchHighlightingStyleKey;
static const void *UIViewOriginalObjectKey = &UIViewOriginalObjectKey;
static const void *UIViewHighlightingObjectKey = &UIViewHighlightingObjectKey;

static MTHighlightingStyle UIViewGetTouchHighlightingStyle(UIView *view) {
    return (MTHighlightingStyle)[objc_getAssociatedObject(view, UIViewTouchHighlightingStyleKey) integerValue];
}

static void UIViewSetTouchHighlightingStyle(UIView *view, MTHighlightingStyle style) {
    objc_setAssociatedObject(view, UIViewTouchHighlightingStyleKey, @(style), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static id UIViewGetOriginalObject(UIView *view) {
    return objc_getAssociatedObject(view, UIViewOriginalObjectKey);
}

static void UIViewSetOriginalObject(UIView *view, id object) {
    objc_setAssociatedObject(view, UIViewOriginalObjectKey, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static id UIViewGetHighlightingObject(UIView *view) {
    return objc_getAssociatedObject(view, UIViewHighlightingObjectKey);
}

static void UIViewSetHighlightingObject(UIView *view, id object) {
    objc_setAssociatedObject(view, UIViewHighlightingObjectKey, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void UIViewClearStateObjects(UIView *view) {
    UIViewSetOriginalObject(view, nil);
    UIViewSetHighlightingObject(view, nil);
}

static CGRect UIViewGetZeroedFrame(UIView *view) {
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = view.frame.size;

    return frame;
}

static UIImage *UIViewTakeScreenshot(UIView *view) {
    UIImage *outputImage = nil;

    UIGraphicsBeginImageContextWithOptions(view.layer.frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    [view.layer renderInContext:context];
    outputImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return outputImage;
}

static void UIViewHighlight(UIView *view) {
    MTHighlightingStyle highlightingStyle = view.touchHighlightingStyle;

    switch (highlightingStyle) {
        case MTHighlightingStyleNone:
            break;

        case MTHighlightingStyleTransparentMask: {
            // Get or create the highlighting layer.
            CALayer *highlightingLayer = (CALayer *)UIViewGetHighlightingObject(view);
            if (!highlightingLayer) {
                highlightingLayer = [CALayer layer];
                highlightingLayer.backgroundColor = [UIColor blackColor].CGColor;
                highlightingLayer.opacity = 0.36;

                UIViewSetHighlightingObject(view, highlightingLayer);
            }
            // Update the frame of highlighting layer.
            highlightingLayer.frame = UIViewGetZeroedFrame(view);

            // Save the original mask layer.
            UIViewSetOriginalObject(view, view.layer.mask);
            // Replace the mask layer with highlighting one.
            view.layer.mask = highlightingLayer;
            break;
        }

        case MTHighlightingStyleLightBackground: {
            // Save the original background color.
            UIViewSetOriginalObject(view, view.backgroundColor);
            // Replace the background color with highlighting one.
            view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.18];
            break;
        }

        case MTHighlightingStyleSolidDarkOverlay: {
            // Get or create the overlay layer.
            CALayer *overlayLayer = (CALayer *)UIViewGetHighlightingObject(view);
            if (!overlayLayer) {
                overlayLayer = [CALayer layer];
                overlayLayer.backgroundColor = [UIColor blackColor].CGColor;
                overlayLayer.opacity = 0.48;

                UIViewSetHighlightingObject(view, overlayLayer);
            }
            // Update the frame of overlay layer.
            overlayLayer.frame = UIViewGetZeroedFrame(view);

            // Add the overlay layer in the view.
            [view.layer addSublayer:overlayLayer];
            break;
        }

        case MTHighlightingStyleHollowDarkOverlay: {
            // Create the mask layer with the contents of view.
            CALayer *maskLayer = [CALayer layer];
            maskLayer.contents = (id)UIViewTakeScreenshot(view).CGImage;
            maskLayer.frame = UIViewGetZeroedFrame(view);

            // Create the overlay layer.
            CALayer *overlayLayer = [CALayer layer];
            overlayLayer.mask = maskLayer;
            overlayLayer.backgroundColor = [UIColor blackColor].CGColor;
            overlayLayer.opacity = 0.48;
            overlayLayer.frame = UIViewGetZeroedFrame(view);

            // Save the overlay layer so that it can be removed upon unhighlighting.
            UIViewSetHighlightingObject(view, overlayLayer);
            // Add the overlay layer in the view.
            [view.layer addSublayer:overlayLayer];
            break;
        }
    }
}

static void UIViewUnhighlight(UIView *view) {
    MTHighlightingStyle highlightingStyle = view.touchHighlightingStyle;

    switch (highlightingStyle) {
        case MTHighlightingStyleNone:
            break;

        case MTHighlightingStyleTransparentMask: {
            // Restore the original mask layer.
            view.layer.mask = UIViewGetOriginalObject(view);
            UIViewSetOriginalObject(view, nil);
            break;
        }

        case MTHighlightingStyleLightBackground: {
            // Restore the original background color.
            view.backgroundColor = (UIColor *)UIViewGetOriginalObject(view);
            UIViewSetOriginalObject(view, nil);
            break;
        }

        case MTHighlightingStyleSolidDarkOverlay: {
            // Remove the overlay layer so that the view becomes unhighlighted.
            CALayer *overlayLayer = (CALayer *)UIViewGetHighlightingObject(view);
            [overlayLayer removeFromSuperlayer];
            break;
        }

        case MTHighlightingStyleHollowDarkOverlay: {
            // Remove the overlay layer so that the view becomes unhighlighted.
            CALayer *overlayLayer = (CALayer *)UIViewGetHighlightingObject(view);
            [overlayLayer removeFromSuperlayer];

            UIViewSetHighlightingObject(view, nil);
            break;
        }
    }
}

#pragma mark - UIResponder - Touch Handling

static void (*UIResponderOriginalTouchesBegan)(id self, SEL _cmd, NSSet *touches, UIEvent *event) = NULL;
static void (*UIResponderOriginalTouchesMoved)(id self, SEL _cmd, NSSet *touches, UIEvent *event) = NULL;
static void (*UIResponderOriginalTouchesEnded)(id self, SEL _cmd, NSSet *touches, UIEvent *event) = NULL;
static void (*UIResponderOriginalTouchesCancelled)(id self, SEL _cmd, NSSet *touches, UIEvent *event) = NULL;

static void UIResponderReplacementTouchesBegan(id self, SEL _cmd, NSSet *touches, UIEvent *event) {
    if ([self isKindOfClass:[UIView class]]) {
        UIViewHighlight((UIView *)self);
    }

    UIResponderOriginalTouchesBegan(self, _cmd, touches, event);
}

static void UIResponderReplacementTouchesMoved(id self, SEL _cmd, NSSet *touches, UIEvent *event) {
    UIResponderOriginalTouchesMoved(self, _cmd, touches, event);
}

static void UIResponderReplacementTouchesEnded(id self, SEL _cmd, NSSet *touches, UIEvent *event) {
    if ([self isKindOfClass:[UIView class]]) {
        UIViewUnhighlight((UIView *)self);
    }

    UIResponderOriginalTouchesEnded(self, _cmd, touches, event);
}

static void UIResponderReplacementTouchesCancelled(id self, SEL _cmd, NSSet *touches, UIEvent *event) {
    if ([self isKindOfClass:[UIView class]]) {
        UIViewUnhighlight((UIView *)self);
    }

    UIResponderOriginalTouchesCancelled(self, _cmd, touches, event);
}

#pragma mark - Categories Implementation

@implementation UIResponder (TouchHighlighting)

+ (void)load {
    ClassSwizzleInstanceMethod(self,
                               @selector(touchesBegan:withEvent:),
                               (IMP)UIResponderReplacementTouchesBegan,
                               (IMP *)&UIResponderOriginalTouchesBegan);
    ClassSwizzleInstanceMethod(self,
                               @selector(touchesEnded:withEvent:),
                               (IMP)UIResponderReplacementTouchesEnded,
                               (IMP *)&UIResponderOriginalTouchesEnded);
    ClassSwizzleInstanceMethod(self,
                               @selector(touchesMoved:withEvent:),
                               (IMP)UIResponderReplacementTouchesMoved,
                               (IMP *)&UIResponderOriginalTouchesMoved);
    ClassSwizzleInstanceMethod(self,
                               @selector(touchesCancelled:withEvent:),
                               (IMP)UIResponderReplacementTouchesCancelled,
                               (IMP *)&UIResponderOriginalTouchesCancelled);
}

@end

@implementation UIView (TouchHighlighting)

- (MTHighlightingStyle)touchHighlightingStyle {
    return UIViewGetTouchHighlightingStyle(self);
}

- (void)setTouchHighlightingStyle:(MTHighlightingStyle)touchHighlightingStyle {
    UIViewClearStateObjects(self);
    UIViewSetTouchHighlightingStyle(self, touchHighlightingStyle);
}

@end
