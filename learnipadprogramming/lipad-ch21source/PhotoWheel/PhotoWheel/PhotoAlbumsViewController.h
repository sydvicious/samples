//
//  PhotoAlbumsViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 8/13/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WheelView.h"

@class PhotoAlbumViewController;

@interface PhotoAlbumsViewController : UIViewController 
<NSFetchedResultsControllerDelegate, WheelViewDataSource, WheelViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet WheelView *wheelView;
@property (nonatomic, strong) PhotoAlbumViewController *photoAlbumViewController;

- (IBAction)addPhotoAlbum:(id)sender;

@end
