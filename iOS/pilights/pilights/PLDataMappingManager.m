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
        
        _pinStates = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    return self;
}

- (NSDictionary*)allOutputPins {
    return @{
    [NSNumber numberWithInt:kOutputPinNW]:@"NW",
    [NSNumber numberWithInt:kOutputPinD]:@"D",
    [NSNumber numberWithInt:kOutputPinNE]:@"NE",
    [NSNumber numberWithInt:kOutputPinSE]:@"SE",
    [NSNumber numberWithInt:kOutputPinP]:@"P",
    [NSNumber numberWithInt:kOutputPinG]:@"G"
    };
}

- (void)turnAllOutputsOn:(BOOL)outputOn {
    NSString *stringArray = [[[self allOutputPins] allKeys] componentsJoinedByString:@","];
    NSString *json = [NSString stringWithFormat:(outputOn) ? @"{\"on\":[%@]}" : @"{\"off\":[%@]}",stringArray];
    [_webSocketManager.websocket send:json];
}

- (void)toggleOutput:(int)output {
//    NSString *pinTitle = [self allOutputPins][numFromInt(output)];

//    NSLog(@"Pin states: %@",_pinStates);
    
//    NSLog(@"Toggle Pin: %@",pinTitle);
    
    NSNumber *state = numFromInt([_pinStates[@"output"][stringFromInt(output)] integerValue]);
    
    NSString *json = [NSString stringWithFormat:([state isEqualToNumber:@0]) ? @"{\"on\":[%d]}" : @"{\"off\":[%d]}",output];
    [_webSocketManager.websocket send:json];
}

#pragma mark - PLWebSocketManagerDelegate

- (void)websocketDidRecieveMessage:(id)message {
#ifdef DEBUG
    NSLog(@"Websocket recieved message: %@",message);
#endif
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"JSON: %@",json);

    [_pinStates addEntriesFromDictionary:json];
}

@end
