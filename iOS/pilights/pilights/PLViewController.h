//
//  PLViewController.h
//  pilights
//
//  Created by Jonathan Hoskin on 26/01/13.
//  Copyright (c) 2013 Hosk.in. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLDataMappingManager.h"

@interface PLViewController : UIViewController <PLDataMappingManagerDelegate>

@property (nonatomic,strong) PLDataMappingManager *dataMappingManager;
@property (strong, nonatomic) IBOutlet UISwitch *onOffSwitch;
@property (strong, nonatomic) IBOutlet UIButton *nwButton;
@property (strong, nonatomic) IBOutlet UIButton *dBUtton;
@property (strong, nonatomic) IBOutlet UIButton *neButton;
@property (strong, nonatomic) IBOutlet UIButton *seButton;
@property (strong, nonatomic) IBOutlet UIButton *pButton;
@property (strong, nonatomic) IBOutlet UIButton *gButton;

- (IBAction)switchChanged:(id)sender;
- (IBAction)nwChanged:(id)sender;
- (IBAction)dChanged:(id)sender;
- (IBAction)neChanged:(id)sender;
- (IBAction)seChanged:(id)sender;
- (IBAction)pChanged:(id)sender;
- (IBAction)gChanged:(id)sender;

@end
