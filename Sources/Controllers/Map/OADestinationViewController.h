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

@protocol OADestinationViewControllerProtocol
@optional

- (void)destinationViewLayoutDidChange:(BOOL)animated;
- (void)destinationViewMoveTo:(OADestination *)destination;
- (void)destinationsAdded;
- (void)openHideDestinationCardsView;

@end

@interface OADestinationViewController : UIViewController<OADestinatioCellProtocol>

@property (nonatomic, assign) BOOL singleLineOnly;
@property (nonatomic, assign) CGFloat top;
@property (weak, nonatomic) id<OADestinationViewControllerProtocol> delegate;

- (void)startLocationUpdate;
- (void)stopLocationUpdate;

- (void)updateFrame:(BOOL)animated;

- (UIColor *) addDestination:(OADestination *)destination;
- (void) updateDestinations;
- (void) doLocationUpdate;

- (void)updateDestinationsUsingMapCenter;
- (void)updateCloseButton;

@end
