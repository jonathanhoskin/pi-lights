//
//  PLDataMappingManager.m
//  pilights
//
//  Created by Jonathan Hoskin on 26/01/13.
//  Copyright (c) 2013 Hosk.in. All rights reserved.
//

#import "PLDataMappingManager.h"

@implementation PLDataMappingManager

static NSNumber* numFromInt (int theInt) {
    return [NSNumber numberWithInt:theInt];
}

static NSString* stringFromInt (int theInt) {
    return [NSString stringWithFormat:@"%d",theInt];
}


- (id)init {
    self = [super init];
    if (self) {
        _webSocketManager = [[PLWebSocketManager alloc] init];
        _webSocketManager.delegate = self;
        [_webSocketManager openWebSocket];
        
        _outputPinStates = [NSMutableDictionary dictionaryWithCapacity:20];
        _sensorPinStates = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    
    return self;
}

- (NSDictionary*)allOutputPins {
    return @{
    numFromInt(kOutputPinNW):@"NW",
    numFromInt(kOutputPinD):@"D",
    numFromInt(kOutputPinNE):@"NE",
    numFromInt(kOutputPinSE):@"SE",
    numFromInt(kOutputPinP):@"P",
    numFromInt(kOutputPinG):@"G"
    };
}

- (BOOL)outputIsOn:(NSNumber*)output {
    int state = [_outputPinStates[[output stringValue]] integerValue];
    return (state == 1);
}

- (void)turnAllOutputsOn:(BOOL)outputOn {
    NSString *stringArray = [[[self allOutputPins] allKeys] componentsJoinedByString:@","];
    NSString *json = [NSString stringWithFormat:(outputOn) ? @"{\"on\":[%@]}" : @"{\"off\":[%@]}",stringArray];
    [_webSocketManager.websocket send:json];
}

- (void)toggleOutput:(NSNumber*)output {
//    NSString *pinTitle = [self allOutputPins][numFromInt(output)];

//    NSLog(@"Pin states: %@",_pinStates);
    
//    NSLog(@"Toggle Pin: %@",pinTitle);
    
    NSString *json = [NSString stringWithFormat:[self outputIsOn:output] ? @"{\"off\":[%@]}" : @"{\"on\":[%@]}",output];
    [_webSocketManager.websocket send:json];
}

#pragma mark - PLWebSocketManagerDelegate

- (void)websocketDidRecieveMessage:(id)message {
#ifdef DEBUG
//    NSLog(@"Websocket recieved message: %@",message);
#endif
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//    NSLog(@"JSON: %@",json);
    
    [json[@"output"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        _outputPinStates[key] = obj;
    }];
    
    [json[@"sensor"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        _sensorPinStates[key] = obj;
    }];

    [_delegate didMapIncomingData];
    
//    NSLog(@"Pin states: %@",_outputPinStates);
}

@end
