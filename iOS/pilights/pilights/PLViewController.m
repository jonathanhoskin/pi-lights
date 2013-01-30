//
//  PLViewController.m
//  pilights
//
//  Created by Jonathan Hoskin on 26/01/13.
//  Copyright (c) 2013 Hosk.in. All rights reserved.
//

#import "PLViewController.h"

@interface PLViewController ()

@end

@implementation PLViewController

static NSNumber* numFromInt (int theInt) {
    return [NSNumber numberWithInt:theInt];
}

static UIColor* onColor () {
    return [UIColor greenColor];
}

static UIColor* offColor () {
    return [UIColor redColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataMappingManager = [[PLDataMappingManager alloc] init];
    _dataMappingManager.delegate = self;
}

- (IBAction)switchChanged:(id)sender {
    [_dataMappingManager turnAllOutputsOn:_onOffSwitch.on];
}

- (IBAction)nwChanged:(id)sender {
    [_dataMappingManager toggleOutput:numFromInt(kOutputPinNW)];
}

- (IBAction)dChanged:(id)sender {
    [_dataMappingManager toggleOutput:numFromInt(kOutputPinD)];
}

- (IBAction)neChanged:(id)sender {
    [_dataMappingManager toggleOutput:numFromInt(kOutputPinNE)];
}

- (IBAction)seChanged:(id)sender {
    [_dataMappingManager toggleOutput:numFromInt(kOutputPinSE)];
}

- (IBAction)pChanged:(id)sender {
    [_dataMappingManager toggleOutput:numFromInt(kOutputPinP)];
}

- (IBAction)gChanged:(id)sender {
    [_dataMappingManager toggleOutput:numFromInt(kOutputPinG)];
}

- (void)updateButton:(UIButton*)button outputState:(NSString*)outputState sensorState:(NSString*)sensorState {
    
}


- (NSDictionary*)buttonMappings {
    return @{
    numFromInt(kOutputPinNW):_nwButton,
    numFromInt(kOutputPinD):_dBUtton,
    numFromInt(kOutputPinNE):_neButton,
    numFromInt(kOutputPinSE):_seButton,
    numFromInt(kOutputPinP):_pButton,
    numFromInt(kOutputPinG):_gButton
    };
}

- (void)updateControls {
    [[self buttonMappings] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        BOOL stateIsOn = [_dataMappingManager outputIsOn:key];
        UIButton *button = obj;
        [button setBackgroundColor:stateIsOn ? onColor() : offColor()];
    }];
}

- (void)showDebugMessageFieldWithText:(NSString*)string {
    int height = 100;
    int startY = self.view.bounds.size.height - height;  // 44 is toolbar height
    
    if (_debugView == nil) {
        _debugView = [[UITextView alloc] initWithFrame:CGRectMake(0, startY, self.view.bounds.size.width, height)];
        _debugView.editable = NO;
        _debugView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
        _debugView.textColor = [UIColor colorWithWhite:1 alpha:1];
        _debugView.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    }
    
    _debugView.alpha = 1.0;
    _debugView.text = string;

    if (![self.view.subviews containsObject:_debugView]) {
        [self.view addSubview:_debugView];
    }
    
    double delayInSeconds = 5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:1
                         animations:^{
                             [_debugView setAlpha:0.0];
                         }
                         completion:^(BOOL finished) {
                             [_debugView removeFromSuperview];
                         }];
    });
}

#pragma mark - PLDataMappingManagerDelegate

- (void)didMapIncomingData:(id)data {
    [self updateControls];
    
#ifdef DEBUG
    [self showDebugMessageFieldWithText:[[NSString stringWithFormat:@"%@",data] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
#endif
    
}

@end
