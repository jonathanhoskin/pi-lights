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

#pragma mark - PLDataMappingManagerDelegate

- (void)didMapIncomingData {
    [self updateControls];
}

@end
