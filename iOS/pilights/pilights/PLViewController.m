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

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataMappingManager = [[PLDataMappingManager alloc] init];
}

- (IBAction)switchChanged:(id)sender {
    [_dataMappingManager turnAllOutputsOn:_onOffSwitch.on];
}

- (IBAction)nwChanged:(id)sender {
    [_dataMappingManager turnOutputOn:YES output:kOutputPinNW];
}

- (IBAction)dChanged:(id)sender {
    [_dataMappingManager turnOutputOn:YES output:kOutputPinD];
}

- (IBAction)neChanged:(id)sender {
    [_dataMappingManager turnOutputOn:YES output:kOutputPinNE];
}

- (IBAction)seChanged:(id)sender {
    [_dataMappingManager turnOutputOn:YES output:kOutputPinSE];
}

- (IBAction)pChanged:(id)sender {
    [_dataMappingManager turnOutputOn:YES output:kOutputPinP];
}

- (IBAction)gChanged:(id)sender {
    [_dataMappingManager turnOutputOn:YES output:kOutputPinG];
}

#pragma mark - PLDataMappingManagerDelegate

- (void)didMapIncomingOutputData:(id)data {
    
}

- (void)didMapIncomingSensorData:(id)data {
    
}

- (void)didMapIncomingSwitchData:(id)data {
    
}

@end
