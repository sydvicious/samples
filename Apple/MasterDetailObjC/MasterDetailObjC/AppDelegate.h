//
//  AppDelegate.h
//  MasterDetailObjC
//
//  Created by Syd Polk on 6/17/18.
//  Copyright © 2018 Bone Jarring Games and Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

