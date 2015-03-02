//
//  OADestinationViewController.h
//  OsmAnd
//
//  Created by Alexey Kulish on 01/03/15.
//  Copyright (c) 2015 OsmAnd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OADestinationCell.h"

@class OADestination;

@interface OADestinationViewController : UIViewController<OADestinatioCellProtocol>

- (void)startLocationUpdate;
- (void)stopLocationUpdate;

- (void)updateFrame;

- (BOOL) addDestination:(OADestination *)destination;
- (void) doLocationUpdate;

@end