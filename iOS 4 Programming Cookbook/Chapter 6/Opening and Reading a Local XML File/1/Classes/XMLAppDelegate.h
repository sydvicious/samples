//
//  XMLAppDelegate.h
//  XML
//
//  Created by Vandad Nahavandipoor on 10-06-14.
//  Copyright  2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMLAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow *window;
  
  UINavigationController  *navigationController;
  
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

