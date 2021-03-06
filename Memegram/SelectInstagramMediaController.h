//
//  MGMasterViewController.h
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKGridView.h"

@class InstagramMediaDataSource;

@interface SelectInstagramMediaController : UIViewController

@property (readonly, nonatomic) InstagramMediaDataSource *dataSource;

- (void) datasourceDidFinishLoad;
- (void) datasourceDidFailLoad;

@end
