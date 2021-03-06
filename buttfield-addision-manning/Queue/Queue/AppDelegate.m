//
//  AppDelegate.m
//  Queue
//
//  Created by Syd Polk on 6/26/13.
//  Copyright (c) 2013 Bone Jarring Games and Software. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

-(void)loadURL: (UIApplication *)application {
    UIBackgroundTaskIdentifier backgroundTask = [application beginBackgroundTaskWithExpirationHandler:nil];
    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];
    [backgroundQueue addOperationWithBlock:^{
        NSURL *notificationURL = [NSURL URLWithString:@"http://www.oreilly.com/"];
        NSURLRequest *notificationURLRequest = [NSURLRequest requestWithURL:notificationURL];
        NSData *loadedData = [NSURLConnection sendSynchronousRequest:notificationURLRequest returningResponse:nil error:nil];
        NSString *loadedString = [[NSString alloc] initWithData:loadedData encoding: NSUTF8StringEncoding];
        NSLog(@"Loaded: %@", loadedString);
        [application endBackgroundTask:backgroundTask];
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self loadURL:application];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
