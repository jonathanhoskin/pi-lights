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

- (void)turnAllOutputsOn:(BOOL)outputOn {
    [_webSocketManager.websocket send: (outputOn) ? @"{\"on\":\"all\"}" : @"{\"off\":\"all\"}"];
}

- (void)turnOutputOn:(BOOL)outputOn output:(NSInteger)output {
    NSString *json = [NSString stringWithFormat:(outputOn) ? @"{\"on\":[%d]}" : @"{\"off\":[%d]}",output];
    [_webSocketManager.websocket send:json];
}

#pragma mark - PLWebSocketManagerDelegate

- (void)websocketDidRecieveMessage:(id)data {
    
}

@end
