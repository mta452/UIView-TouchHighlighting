//
//  ViewController.m
//  UIViewTouchHighlightingExample
//
//  Created by Muhammad Tayyab Akram on 08/12/2015.
//  Copyright © 2015 Muhammad Tayyab Akram. All rights reserved.
//

#import "UIView+TouchHighlighting.h"
#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *transparentMaskView;
@property (weak, nonatomic) IBOutlet UIView *lightBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *solidOverlayView;
@property (weak, nonatomic) IBOutlet UIView *hollowOverlayView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.transparentMaskView.touchHighlightingStyle = MTHighlightingStyleTransparentMask;
    self.lightBackgroundView.touchHighlightingStyle = MTHighlightingStyleLightBackground;
    self.solidOverlayView.touchHighlightingStyle = MTHighlightingStyleSolidDarkOverlay;
    self.hollowOverlayView.touchHighlightingStyle = MTHighlightingStyleHollowDarkOverlay;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
