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
#import "MTCompoundButton.h"

@implementation MTCompoundButton {
    MTViewHighlighter *_highlighter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _commonInit];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonInit];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
    }

    return self;
}

- (void)_commonInit {
    _highlighter = [[MTViewHighlighter alloc] initWithView:self];
    _highlighter.highlightingStyle = MTHighlightingStyleTransparentMask;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [_highlighter setHighlighted:highlighted];
}

- (MTHighlightingStyle)touchHighlightingStyle {
    return _highlighter.highlightingStyle;
}

- (void)setTouchHighlightingStyle:(MTHighlightingStyle)touchHighlightingStyle {
    _highlighter.highlightingStyle = touchHighlightingStyle;
}

@end
