//
//  PLWebSocketManager.h
//  pilights
//
//  Created by Jonathan Hoskin on 26/01/13.
//  Copyright (c) 2013 Hosk.in. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

@protocol PLWebSocketManagerDelegate <NSObject>
- (void)websocketDidRecieveMessage:(id)data;
@end

@interface PLWebSocketManager : NSObject <SRWebSocketDelegate>

@property (nonatomic,strong) id <PLWebSocketManagerDelegate> delegate;
@property (nonatomic,strong) SRWebSocket *websocket;

- (void)openWebSocket;
- (void)closeWebSocket;

@end
