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
#import "MTViewHighlighter.h"
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

static const void *UIViewHighlighterKey = &UIViewHighlighterKey;

static MTViewHighlighter *UIViewGetHighlighter(UIView *view) {
    return (MTViewHighlighter *)objc_getAssociatedObject(view, UIViewHighlighterKey);
}

static void UIViewSetHighlighter(UIView *view, MTViewHighlighter *highlighter) {
    objc_setAssociatedObject(view, UIViewHighlighterKey, highlighter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - UIResponder - Touch Handling

static void (*UIResponderOriginalTouchesBegan)(id self, SEL _cmd, NSSet *touches, UIEvent *event) = NULL;
static void (*UIResponderOriginalTouchesMoved)(id self, SEL _cmd, NSSet *touches, UIEvent *event) = NULL;
static void (*UIResponderOriginalTouchesEnded)(id self, SEL _cmd, NSSet *touches, UIEvent *event) = NULL;
static void (*UIResponderOriginalTouchesCancelled)(id self, SEL _cmd, NSSet *touches, UIEvent *event) = NULL;

static void UIResponderReplacementTouchesBegan(id self, SEL _cmd, NSSet *touches, UIEvent *event) {
    if ([self isKindOfClass:[UIView class]]) {
        [UIViewGetHighlighter(self) setHighlighted:YES];
    }

    UIResponderOriginalTouchesBegan(self, _cmd, touches, event);
}

static void UIResponderReplacementTouchesMoved(id self, SEL _cmd, NSSet *touches, UIEvent *event) {
    UIResponderOriginalTouchesMoved(self, _cmd, touches, event);
}

static void UIResponderReplacementTouchesEnded(id self, SEL _cmd, NSSet *touches, UIEvent *event) {
    if ([self isKindOfClass:[UIView class]]) {
        [UIViewGetHighlighter(self) setHighlighted:NO];
    }

    UIResponderOriginalTouchesEnded(self, _cmd, touches, event);
}

static void UIResponderReplacementTouchesCancelled(id self, SEL _cmd, NSSet *touches, UIEvent *event) {
    if ([self isKindOfClass:[UIView class]]) {
        [UIViewGetHighlighter(self) setHighlighted:NO];
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
    return UIViewGetHighlighter(self).highlightingStyle;
}

- (void)setTouchHighlightingStyle:(MTHighlightingStyle)touchHighlightingStyle {
    MTViewHighlighter *highlighter = UIViewGetHighlighter(self);
    if (!highlighter) {
        highlighter = [[MTViewHighlighter alloc] initWithView:self];
        UIViewSetHighlighter(self, highlighter);
    }

    highlighter.highlightingStyle = touchHighlightingStyle;
}

@end
