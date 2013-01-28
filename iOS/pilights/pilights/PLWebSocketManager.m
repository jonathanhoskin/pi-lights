//
//  PLWebSocketManager.m
//  pilights
//
//  Created by Jonathan Hoskin on 26/01/13.
//  Copyright (c) 2013 Hosk.in. All rights reserved.
//

#import "PLWebSocketManager.h"

@implementation PLWebSocketManager

- (void)openWebSocket {
    NSString *server = [[NSUserDefaults standardUserDefaults] valueForKey:@"webSocketServer"];
    NSInteger port = [[NSUserDefaults standardUserDefaults] integerForKey:@"webSocketPort"];
    NSString *urlString = [NSString stringWithFormat:@"ws://%@:%d",server,port];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    _websocket = nil;
    _websocket = [[SRWebSocket alloc] initWithURLRequest:request];
    _websocket.delegate = self;
    [_websocket open];
}

- (void)closeWebSocket {
    [_websocket close];
}

- (void)reopenWebsocket {
    double delayInSeconds = 2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self openWebSocket];
    });
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    
#ifdef DEBUG
    NSLog(@"Websocket Connected");
#endif
    
//    [webSocket send:[NSString stringWithFormat:@"login=%@",_apiKey]];
    //    [webSocket send:[NSString stringWithFormat:@"login=%@",@"q6yVOLimw-OEMYCE5Qef"]];
    [webSocket send:@"{\"status\":\"all\"}"];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    
#ifdef DEBUG
    NSLog(@"Websocket failed with error: %@",error);
#endif
    
    [self reopenWebsocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
#ifdef DEBUG
    NSLog(@"Websocket closed with reason: %@",reason);
    NSLog(@"Websocket closed clean: %@",(wasClean) ? @"YES" : @"NO");
    NSLog(@"Websocket closed with code: %d",code);
#endif
    
    [self reopenWebsocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    
//#ifdef DEBUG
//    NSLog(@"Websocket recieved message: %@",message);
//#endif
    
    [_delegate websocketDidRecieveMessage:message];
}




@end
