//
//  DetailViewController.h
//  Lost Characters
//
//  Created by Mobile Making on 11/11/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface DetailViewController : UIViewController

@property NSManagedObjectContext *moc;
@property NSManagedObject *character;

@end
