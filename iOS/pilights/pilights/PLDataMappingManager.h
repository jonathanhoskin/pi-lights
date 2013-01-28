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

- (void)didMapIncomingData;

@end

@interface PLDataMappingManager : NSObject <PLWebSocketManagerDelegate>

@property (nonatomic,assign) id <PLDataMappingManagerDelegate> delegate;
@property (nonatomic,strong) PLWebSocketManager *webSocketManager;
@property (nonatomic,strong) NSMutableDictionary *outputPinStates;
@property (nonatomic,strong) NSMutableDictionary *sensorPinStates;

- (void)turnAllOutputsOn:(BOOL)outputOn;
- (void)toggleOutput:(NSNumber*)output;
- (BOOL)outputIsOn:(NSNumber*)output;

typedef enum {
    kOutputPinNW = 11,
    kOutputPinD = 24,
    kOutputPinNE = 18,
    kOutputPinSE = 8,
    kOutputPinP = 22,
    kOutputPinG = 23,
    kOutputPinCount = 6
} kOutputPinConstants;

@end
