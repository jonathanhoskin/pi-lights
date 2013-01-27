//
//  PLDataMappingManager.m
//  pilights
//
//  Created by Jonathan Hoskin on 26/01/13.
//  Copyright (c) 2013 Hosk.in. All rights reserved.
//

#import "PLDataMappingManager.h"

@implementation PLDataMappingManager

- (id)init {
    self = [super init];
    if (self) {
        _webSocketManager = [[PLWebSocketManager alloc] init];
        _webSocketManager.delegate = self;
        [_webSocketManager openWebSocket];
    }
    return self;
}

- (NSString*)allOutputPins {
    return [NSString stringWithFormat:@"[%d,%d,%d,%d,%d,%d]",kOutputPinNW,kOutputPinD,kOutputPinNE,kOutputPinSE,kOutputPinP,kOutputPinG];
}

- (void)turnAllOutputsOn:(BOOL)outputOn {
    NSString *json = [NSString stringWithFormat:(outputOn) ? @"{\"on\":%@}" : @"{\"off\":%@}",[self allOutputPins]];
    [_webSocketManager.websocket send:json];
}

- (void)turnOutputOn:(BOOL)outputOn output:(NSInteger)output {
    NSString *json = [NSString stringWithFormat:(outputOn) ? @"{\"on\":[%d]}" : @"{\"off\":[%d]}",output];
    [_webSocketManager.websocket send:json];
}

#pragma mark - PLWebSocketManagerDelegate

- (void)websocketDidRecieveMessage:(id)data {
    
}

@end
