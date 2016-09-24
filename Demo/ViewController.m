//
//  ViewController.m
//  Demo
//
//  Created by Muhammad Tayyab Akram on 23/07/2016.
//  Copyright © 2016 Muhammad Tayyab Akram. All rights reserved.
//

#import "MTCompoundButton.h"
#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet MTCompoundButton *transparentMaskButton;
@property (weak, nonatomic) IBOutlet MTCompoundButton *lightBackgroundButton;
@property (weak, nonatomic) IBOutlet MTCompoundButton *solidOverlayButton;
@property (weak, nonatomic) IBOutlet MTCompoundButton *hollowOverlayButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.transparentMaskButton.touchHighlightingStyle = MTHighlightingStyleTransparentMask;
    self.lightBackgroundButton.touchHighlightingStyle = MTHighlightingStyleLightBackground;
    self.solidOverlayButton.touchHighlightingStyle = MTHighlightingStyleSolidDarkOverlay;
    self.hollowOverlayButton.touchHighlightingStyle = MTHighlightingStyleHollowDarkOverlay;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
