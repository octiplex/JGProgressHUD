//
//  JGViewController.m
//  JGProgressHUD Tests
//
//  Created by Jonas Gessner on 20.07.14.
//  Copyright (c) 2014 Jonas Gessner. All rights reserved.
//

#import "JGViewController.h"
#import "JGProgressHUD.h"
#import "JGProgressHUDPieIndicatorView.h"
#import "JGProgressHUDRingIndicatorView.h"
#import "JGProgressHUDFadeZoomAnimation.h"
#import "JGProgressHUDSuccessIndicatorView.h"
#import "JGProgressHUDErrorIndicatorView.h"
#import "JGProgressHUDIndeterminateIndicatorView.h"

#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 838.00
#endif

#define iOS7 (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0)

@interface JGViewController () <JGProgressHUDDelegate> {
    JGProgressHUDStyle _style;
    JGProgressHUDInteractionType _interaction;
    BOOL _zoom;
    BOOL _dim;
    BOOL _shadow;
}

@end

@implementation JGViewController

#pragma mark - JGProgressHUDDelegate

- (void)progressHUD:(JGProgressHUD *)progressHUD willPresentInView:(UIView *)view {
    NSLog(@"HUD %p will present in view: %p", progressHUD, view);
}

- (void)progressHUD:(JGProgressHUD *)progressHUD didPresentInView:(UIView *)view {
    NSLog(@"HUD %p did present in view: %p", progressHUD, view);
}

- (void)progressHUD:(JGProgressHUD *)progressHUD willDismissFromView:(UIView *)view {
    NSLog(@"HUD %p will dismiss from view: %p", progressHUD, view);
}

- (void)progressHUD:(JGProgressHUD *)progressHUD didDismissFromView:(UIView *)view {
    NSLog(@"HUD %p did dismiss from view: %p", progressHUD, view);
}


#pragma mark -

- (JGProgressHUD *)prototypeHUD {
    JGProgressHUD *HUD = [[JGProgressHUD alloc] initWithStyle:_style];
    HUD.interactionType = _interaction;
    
    if (_zoom) {
        JGProgressHUDFadeZoomAnimation *an = [JGProgressHUDFadeZoomAnimation animation];
        HUD.animation = an;
    }
    
    if (_dim) {
        HUD.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    }
    
    if (_shadow) {
        __unused UIView *h = HUD.HUDView; //Forces the _HUDView to become available
        
        UIView *HUDView = HUD->_HUDView;
        
        HUDView.layer.shadowColor = [UIColor blackColor].CGColor;
        HUDView.layer.shadowOffset = CGSizeZero;
        HUDView.layer.shadowOpacity = 0.4f;
        HUDView.layer.shadowRadius = 8.0f;
        HUDView.layer.masksToBounds = NO;
    }
    
    HUD.delegate = self;
    
    return HUD;
}

- (void)success {
    JGProgressHUD *HUD = self.prototypeHUD;
    
    HUD.textLabel.text = @"Success!";
    HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
    
    HUD.square = YES;
    
    [HUD showInView:self.navigationController.view];
    
    [HUD dismissAfterDelay:3.0];
}

- (void)error {
    JGProgressHUD *HUD = self.prototypeHUD;
    
    HUD.textLabel.text = @"Error!";
    HUD.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
    
    HUD.square = YES;
    
    [HUD showInView:self.navigationController.view];
    
    [HUD dismissAfterDelay:3.0];
}

- (void)simple {
    JGProgressHUD *HUD = self.prototypeHUD;
    
    [HUD showInView:self.navigationController.view];
    
    [HUD dismissAfterDelay:3.0];
}

- (void)tapToCancel {
    JGProgressHUD *HUD = self.prototypeHUD;
    
    HUD.textLabel.text = @"Loading very long...";
    
    __block BOOL confirmationAsked = NO;
    
    HUD.tapOnHUDViewBlock = ^(JGProgressHUD *h) {
        if (confirmationAsked) {
            [h dismiss];
        }
        else {
            h.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
            h.textLabel.text = @"Cancel ?";
            confirmationAsked = YES;
            
            CABasicAnimation *an = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
            an.fromValue = @(0.0f);
            an.toValue = @(0.5f);
            
            an.repeatCount = HUGE_VALF;
            an.autoreverses = YES;
            
            an.duration = 0.75f;
            
            UIView *HUDView = h->_HUDView;
            
            HUDView.layer.shadowColor = [UIColor redColor].CGColor;
            HUDView.layer.shadowOffset = CGSizeZero;
            HUDView.layer.shadowOpacity = 0.0f;
            HUDView.layer.shadowRadius = 8.0f;
            HUDView.layer.masksToBounds = NO;
            
            [HUDView.layer addAnimation:an forKey:@"glow"];
            
            __weak __typeof(h) wH = h;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (wH && confirmationAsked) {
                    confirmationAsked = NO;
                    __strong __typeof(wH) sH = wH;
                    
                    sH.indicatorView = [[JGProgressHUDIndeterminateIndicatorView alloc] initWithHUDStyle:sH.style];
                    sH.textLabel.text = @"Loading very long...";
                    [sH->_HUDView.layer removeAnimationForKey:@"glow"];
                }
            });
        }
    };
    
    HUD.tapOutsideBlock = ^(JGProgressHUD *h) {
        if (confirmationAsked) {
            confirmationAsked = NO;
            h.indicatorView = [[JGProgressHUDIndeterminateIndicatorView alloc] initWithHUDStyle:h.style];
            h.textLabel.text = @"Loading very long...";
            [h->_HUDView.layer removeAnimationForKey:@"glow"];
        }
    };
    
    [HUD showInView:self.navigationController.view];
    
    [HUD dismissAfterDelay:120.0];
}

- (void)withText {
    JGProgressHUD *HUD = self.prototypeHUD;
    
    HUD.textLabel.text = @"Loading...";
    
    [HUD showInView:self.navigationController.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        HUD.indicatorView = nil;
        
        HUD.textLabel.font = [UIFont systemFontOfSize:30.0f];
        
        HUD.textLabel.text = @"Done";
        
        HUD.position = JGProgressHUDPositionBottomCenter;
    });
    
    HUD.marginInsets = UIEdgeInsetsMake(0.0f, 0.0f, 10.0f, 0.0f);
    
    [HUD dismissAfterDelay:3];
}

- (void)progress {
    JGProgressHUD *HUD = self.prototypeHUD;
    
    HUD.indicatorView = [[JGProgressHUDPieIndicatorView alloc] initWithHUDStyle:HUD.style];
    
    HUD.textLabel.text = @"Uploading...";
    [HUD showInView:self.navigationController.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HUD setProgress:0.25 animated:YES];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HUD setProgress:0.5 animated:YES];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HUD setProgress:0.75 animated:YES];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HUD setProgress:1.0 animated:YES];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HUD dismiss];
    });
}

- (void)zoomAnimationWithRing {
    JGProgressHUD *HUD = self.prototypeHUD;
    
    HUD.indicatorView = [[JGProgressHUDRingIndicatorView alloc] initWithHUDStyle:HUD.style];
    
    HUD.textLabel.text = @"Downloading...";
    [HUD showInView:self.navigationController.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HUD setProgress:0.25 animated:YES];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HUD setProgress:0.5 animated:YES];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HUD setProgress:0.75 animated:YES];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HUD setProgress:1.0 animated:YES];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HUD dismiss];
    });
}

- (void)textOnly {
    JGProgressHUD *HUD = self.prototypeHUD;
    
    HUD.indicatorView = nil;
    
    HUD.textLabel.text = @"Hello, World!";
    HUD.position = JGProgressHUDPositionBottomCenter;
    HUD.marginInsets = (UIEdgeInsets) {
        .top = 0.0f,
        .bottom = 20.0f,
        .left = 0.0f,
        .right = 0.0f,
    };
    
    [HUD showInView:self.navigationController.view];
    
    [HUD dismissAfterDelay:2.0f];
}

- (void)setHUDStyle:(UISegmentedControl *)c {
    _style = c.selectedSegmentIndex;
}

- (void)setInteraction:(UISegmentedControl *)c {
    _interaction = c.selectedSegmentIndex;
}

- (void)setZoom:(UISegmentedControl *)c {
    _zoom = c.selectedSegmentIndex;
}

- (void)setDim:(UISwitch *)s {
    _dim = s.on;
}

- (void)setShadow:(UISwitch *)s {
    _shadow = s.on;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Configure";
    }
    else {
        return @"Show a HUD";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 6;
    }
    else {
        return 8;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    }
    
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Style";
            
            UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"Extra Light", @"Light", @"Drak"]];
            segment.selectedSegmentIndex = _style;
            [segment addTarget:self action:@selector(setHUDStyle:) forControlEvents:UIControlEventValueChanged];
            
            cell.accessoryView = segment;
            [segment sizeToFit];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"Block Touches";
            
            UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"All", @"On HUD", @"None"]];
            segment.selectedSegmentIndex = _interaction;
            [segment addTarget:self action:@selector(setInteraction:) forControlEvents:UIControlEventValueChanged];
            [segment sizeToFit];
            
            CGRect f = segment.frame;
            f.size.width -= 30.0f;
            segment.frame = f;
            
            cell.accessoryView = segment;
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = @"Animation";
            
            UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"Fade", @"Zoom"]];
            segment.selectedSegmentIndex = _zoom;
            [segment addTarget:self action:@selector(setZoom:) forControlEvents:UIControlEventValueChanged];
            [segment sizeToFit];
            
            cell.accessoryView = segment;
        }
        else if (indexPath.row == 3) {
            UITextField *t = [[UITextField alloc] init];
            t.returnKeyType = UIReturnKeyDone;
            [t addTarget:self action:@selector(dismissKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
            t.borderStyle = UITextBorderStyleRoundedRect;
            [t sizeToFit];
            CGRect f = t.frame;
            f.size.width = 100.0f;
            t.frame = f;
            cell.accessoryView = t;
            cell.textLabel.text = @"Show a keyboard";
        }
        else if (indexPath.row == 4) {
            cell.textLabel.text = @"Dim Background";
            UISwitch *s = [[UISwitch alloc] init];
            
            if (iOS7) {
                s.backgroundColor = [UIColor whiteColor];
                s.layer.cornerRadius = 16.0f;
            }
            
            s.on = _dim;
            [s addTarget:self action:@selector(setDim:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = s;
        }
        else if (indexPath.row == 5) {
            cell.textLabel.text = @"Apply Shadow";
            UISwitch *s = [[UISwitch alloc] init];
            
            if (iOS7) {
                s.backgroundColor = [UIColor whiteColor];
                s.layer.cornerRadius = 16.0f;
            }
            
            s.backgroundColor = [UIColor whiteColor];
            s.on = _shadow;
            [s addTarget:self action:@selector(setShadow:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = s;
        }
    }
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryView = nil;
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Activity Indicator";
                break;
            case 1:
                cell.textLabel.text = @"Activity Indicator & Text, Transform";
                break;
            case 2:
                cell.textLabel.text = @"Pie Progress";
                break;
            case 3:
                cell.textLabel.text = @"Ring Progress";
                break;
            case 4:
                cell.textLabel.text = @"Text Only, Bottom Position";
                break;
            case 5:
                cell.textLabel.text = @"Success, Square Shape";
                break;
            case 6:
                cell.textLabel.text = @"Error, Square Shape";
                break;
            case 7:
                cell.textLabel.text = @"Tap To Cancel";
                break;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        return;
    }
    
    switch (indexPath.row) {
        case 0:
            [self simple];
            break;
        case 1:
            [self withText];
            break;
        case 2:
            [self progress];
            break;
        case 3:
            [self zoomAnimationWithRing];
            break;
        case 4:
            [self textOnly];
            break;
        case 5:
            [self success];
            break;
        case 6:
            [self error];
            break;
        case 7:
            [self tapToCancel];
            break;
    }
}

- (void)dismissKeyboard:(UITextField *)t {
    [t resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"JGProgressHUD";
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
}


@end
