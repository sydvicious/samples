//
//  Location.h
//  Grocery Dude
//
//  Created by Tim Roadley on 24/09/13.
//  Copyright (c) 2013 Tim Roadley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject

@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSDate * modified;

@end
