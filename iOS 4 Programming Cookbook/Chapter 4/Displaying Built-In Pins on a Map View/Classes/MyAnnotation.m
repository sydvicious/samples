//
//  MyAnnotation.m
//  Maps
//
//  Created by Vandad Nahavandipoor on 10-05-10.
//  Copyright 2010  All rights reserved.
//

#import "MyAnnotation.h"

/* --------------------------------------------- */

@implementation MyAnnotation

/* --------------------------------------------- */

@synthesize coordinate, title, subtitle;

/* --------------------------------------------- */

- (id) initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates
                     title:(NSString *)paramTitle 
                  subTitle:(NSString *)paramSubTitle{
  
  self = [super init];
  
  if (self != nil){
    coordinate = paramCoordinates;
    title = [paramTitle copy];
    subtitle = [paramSubTitle copy];
  }
  
  return(self);
  
}

/* --------------------------------------------- */

- (void) dealloc {
  [title release];
  [subtitle release];
  [super dealloc];
}

/* --------------------------------------------- */

@end
