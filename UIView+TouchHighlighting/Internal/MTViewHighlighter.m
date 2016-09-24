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

#import "MTViewHighlighter.h"

@implementation MTViewHighlighter {
    __weak UIView *_view;
    id _primaryObject;
    id _highlightingObject;
}

- (instancetype)initWithView:(__weak UIView *)view {
    self = [super init];
    if (self) {
        _view = view;
    }

    return self;
}

- (CGRect)zeroedFrame {
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = _view.frame.size;

    return frame;
}

- (UIImage *)takeSnapshot {
    UIImage *outputImage = nil;

    UIGraphicsBeginImageContextWithOptions(_view.layer.frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    [_view layoutIfNeeded];
    [_view.layer renderInContext:context];

    outputImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return outputImage;
}

- (void)highlightView {
    switch (_highlightingStyle) {
        case MTHighlightingStyleNone:
            break;

        case MTHighlightingStyleTransparentMask: {
            // Get or create the highlighting layer.
            CALayer *highlightingLayer = _highlightingObject;
            if (!highlightingLayer) {
                highlightingLayer = [CALayer layer];
                highlightingLayer.backgroundColor = [UIColor blackColor].CGColor;
                highlightingLayer.opacity = 0.36;

                _highlightingObject = highlightingLayer;
            }
            // Update the frame of highlighting layer.
            highlightingLayer.frame = [self zeroedFrame];

            // Save the original mask layer.
            _primaryObject = _view.layer.mask;
            // Replace the mask layer with highlighting one.
            _view.layer.mask = highlightingLayer;
            break;
        }

        case MTHighlightingStyleLightBackground: {
            // Save the original background color.
            _primaryObject = [UIColor colorWithCGColor:_view.layer.backgroundColor];
            // Replace the background color with highlighting one.
            _view.layer.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.18].CGColor;
            break;
        }

        case MTHighlightingStyleSolidDarkOverlay: {
            // Get or create the overlay layer.
            CALayer *overlayLayer = _highlightingObject;
            if (!overlayLayer) {
                overlayLayer = [CALayer layer];
                overlayLayer.backgroundColor = [UIColor blackColor].CGColor;
                overlayLayer.opacity = 0.48;

                _highlightingObject = overlayLayer;
            }
            // Update the frame of overlay layer.
            overlayLayer.frame = [self zeroedFrame];

            // Add the overlay layer in the view.
            [_view.layer addSublayer:overlayLayer];
            break;
        }

        case MTHighlightingStyleHollowDarkOverlay: {
            // Create the mask layer with the contents of view.
            CALayer *maskLayer = [CALayer layer];
            maskLayer.contents = (id)[self takeSnapshot].CGImage;
            maskLayer.frame = [self zeroedFrame];

            // Create the overlay layer.
            CALayer *overlayLayer = [CALayer layer];
            overlayLayer.mask = maskLayer;
            overlayLayer.backgroundColor = [UIColor blackColor].CGColor;
            overlayLayer.opacity = 0.48;
            overlayLayer.frame = [self zeroedFrame];

            // Save the overlay layer so that it can be removed upon unhighlighting.
            _highlightingObject = overlayLayer;
            // Add the overlay layer in the view.
            [_view.layer addSublayer:overlayLayer];
            break;
        }
    }
}

- (void)unhighlightView {
    switch (_highlightingStyle) {
        case MTHighlightingStyleNone:
            break;

        case MTHighlightingStyleTransparentMask: {
            // Restore the original mask layer.
            _view.layer.mask = _primaryObject;
            _primaryObject = nil;
            break;
        }

        case MTHighlightingStyleLightBackground: {
            // Restore the original background color.
            _view.layer.backgroundColor = [_primaryObject CGColor];
            _primaryObject = nil;
            break;
        }

        case MTHighlightingStyleSolidDarkOverlay: {
            // Remove the overlay layer.
            CALayer *overlayLayer = _highlightingObject;
            [overlayLayer removeFromSuperlayer];
            break;
        }

        case MTHighlightingStyleHollowDarkOverlay: {
            // Remove the overlay layer.
            CALayer *overlayLayer = _highlightingObject;
            [overlayLayer removeFromSuperlayer];
            // The overlay layer is not reusable, so discard it.
            _highlightingObject = nil;
            break;
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted != _highlighted) {
        if (highlighted) {
            [self highlightView];
        } else {
            [self unhighlightView];
        }

        _highlighted = highlighted;
    }
}

- (void)setHighlightingStyle:(MTHighlightingStyle)highlightingStyle {
    [self setHighlighted:NO];

    _primaryObject = nil;
    _highlightingObject = nil;
    _highlightingStyle = highlightingStyle;
}

@end
