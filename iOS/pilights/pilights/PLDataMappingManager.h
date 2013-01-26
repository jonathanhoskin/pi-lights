//
//  PLDataMappingManager.h
//  pilights
//
//  Created by Jonathan Hoskin on 26/01/13.
//  Copyright (c) 2013 Hosk.in. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLWebSocketManager.h"

@protocol PLDataMappingManagerDelegate <NSObject>

- (void)didMapIncomingSensorData:(id)data;
- (void)didMapIncomingSwitchData:(id)data;
- (void)didMapIncomingOutputData:(id)data;

@end

@interface PLDataMappingManager : NSObject <PLWebSocketManagerDelegate>

@property (nonatomic,assign) id <PLDataMappingManagerDelegate> delegate;
@property (nonatomic,strong) PLWebSocketManager *webSocketManager;

- (void)turnAllOutputsOn:(BOOL)outputOn;
- (void)turnOutputOn:(BOOL)outputOn output:(NSInteger)output;

@end
