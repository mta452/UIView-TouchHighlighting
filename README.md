# UIView+TouchHighlighting & MTCompoundButton

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Build Status](https://travis-ci.org/mta452/UIView-TouchHighlighting.svg)](https://travis-ci.org/mta452/UIView-TouchHighlighting)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/UIView+TouchHighlighting.svg)](http://cocoadocs.org/docsets/UIView+TouchHighlighting)

UIView+TouchHighlighting is a UIView category that provides a generic touch highlighting solution.
![Screenshot](https://github.com/mta452/UIView-TouchHighlighting/blob/master/SCREENSHOT.png)

## Usage
The category provides the following enum for highlighting a view.
```
NS_ENUM(NSInteger, MTHighlightingStyle) {
    MTHighlightingStyleNone,
    MTHighlightingStyleTransparentMask,
    MTHighlightingStyleLightBackground,
    MTHighlightingStyleSolidDarkOverlay,
    MTHighlightingStyleHollowDarkOverlay,
}
```

* `MTHighlightingStyleTransparentMask` introduces a transparent mask layer on touch.

* `MTHighlightingStyleLightBackground` introduces a light transparent background on touch.

* `MTHighlightingStyleSolidDarkOverlay` introduces a rectangular dark overlay layer on touch.

* `MTHighlightingStyleHollowDarkOverlay` introduces a dark overlay layer masked with view contents on touch.


Touch highlighting can be enabled on any view by setting `touchHighlightingStyle` property to desired value as follows.
```
  buttonView.touchHighlightingStyle = MTHighlightingStyleTransparentMask;
```


To disable touch highlighting, set the property to `MTHighlightingStyleNone` as follows.
```
  buttonView.touchHighlightingStyle = MTHighlightingStyleNone;
```

## MTCompoundButton
MTCompoundButton can be used to convert a collection of multiple views into a button. Just make the superview inherit from MTCompoundButton and set the `touchHighlightingStyle` property as explained above. With this, normal views can be made to look and behave like a native UIButton.

## License
```
Copyright (C) 2016 Muhammad Tayyab Akram

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
