//
//  MasterViewController.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 9/24/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "GlobalPhotoKeys.h"

@interface MasterViewController ()
@property (readwrite, assign) NSUInteger currentAlbumIndex;
- (void)readSavedPhotoAlbums;
- (NSMutableDictionary *)newPhotoAlbumWithName:(NSString *)albumName;
- (void)savePhotoAlbum;
@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize data = _data;
@synthesize currentAlbumIndex = _currentAlbumIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
      self.clearsSelectionOnViewWillAppear = NO;
      self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
   }
   return self;
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
   [super viewDidLoad];
   // Do any additional setup after loading the view, typically from a nib.
   
   self.title = NSLocalizedString(@"Photo Albums", @"Photo albums title");
   
   UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                 target:self 
                                 action:@selector(add:)];   
   [[self navigationItem] setRightBarButtonItem:addButton];
   [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
   
   [self readSavedPhotoAlbums];
   
   [[self detailViewController] setPhotoAlbum:[[self data] objectAtIndex:0]];
   
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(photoAlbumSaveNeeded:)
                                                name:kPhotoAlbumSaveNotification
                                              object:[self detailViewController]];
}

- (void)add:(id)sender
{
   NameEditorViewController *newController = 
   [[NameEditorViewController alloc] initWithDefaultNib];
   [newController setDelegate:self];
   [newController setModalPresentationStyle:UIModalPresentationFormSheet];
   [self presentModalViewController:newController animated:YES];
}

- (void)viewDidUnload
{
   [super viewDidUnload];
   // Release any retained subviews of the main view.
   // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   // Return YES for supported orientations
   return YES;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
   NSInteger count =[[self data] count];
   return count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *CellIdentifier = @"Cell";
   
   UITableViewCell *cell = 
      [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                    reuseIdentifier:CellIdentifier];
      // Display the detail disclosure button when the table is 
      // in edit mode. This is the line you must add:
      [cell setEditingAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
      
      [cell setShowsReorderControl:YES];
   }
   
   // Configure the cell.
   NSDictionary *album = [[self data] objectAtIndex:[indexPath row]];
   [[cell textLabel] setText:[album objectForKey:kPhotoAlbumNameKey]];
   
   if ([indexPath row] == [self currentAlbumIndex]) {
      [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
   } else {
      [cell setAccessoryType:UITableViewCellAccessoryNone];
   }
   
   return cell;
}

- (void)tableView:(UITableView *)tableView 
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
      toIndexPath:(NSIndexPath *)toIndexPath
{
   [[self data] exchangeObjectAtIndex:[fromIndexPath row] 
                    withObjectAtIndex:[toIndexPath row]];
}

- (void)tableView:(UITableView *)tableView 
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
   NameEditorViewController *newController = 
   [[NameEditorViewController alloc] initWithDefaultNib];
   [newController setDelegate:self];
   [newController setEditing:YES];
   [newController setIndexPath:indexPath];
   NSString *name = [[self data] objectAtIndex:[indexPath row]];
   [newController setDefaultNameText:name];
   [newController setModalPresentationStyle:UIModalPresentationFormSheet];
   [self presentModalViewController:newController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView 
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
   return YES;
}

- (void)tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (editingStyle == UITableViewCellEditingStyleDelete) {
      [[self data] removeObjectAtIndex:[indexPath row]];
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                       withRowAnimation:UITableViewRowAnimationFade];
   }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSIndexPath *oldCurrentAlbumIndexPath =
   [NSIndexPath indexPathForRow:[self currentAlbumIndex] inSection:0];
   [self setCurrentAlbumIndex:[indexPath row]];
   [tableView reloadRowsAtIndexPaths:
    [NSArray arrayWithObjects:indexPath, oldCurrentAlbumIndexPath, nil]
                    withRowAnimation:UITableViewRowAnimationNone];
   
   [[self detailViewController] setPhotoAlbum:[[self data] objectAtIndex:[indexPath row]]];
}

#pragma mark - NameEditorViewControllerDelegate

- (void)nameEditorViewControllerDidFinish:(NameEditorViewController *)controller
{
   NSString *newName = [[controller nameTextField] text];
   if (newName && [newName length] > 0) {
      if ([controller isEditing]) {
         NSMutableDictionary *photoAlbum = [[self data]
                                            objectAtIndex:[[controller indexPath] row]];
         [photoAlbum setObject:newName forKey:kPhotoAlbumNameKey];
      } else {
         [[self data] addObject:[self newPhotoAlbumWithName:newName]];
      }
      [self savePhotoAlbum];
      [[self tableView] reloadData];
   }
}

- (void)nameEditorViewControllerDidCancel:(NameEditorViewController *)controller
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - Read and save photo albums
- (NSURL *)photoAlbumPath
{
   NSURL *documentsDirectory = [[[NSFileManager defaultManager]
                                 URLsForDirectory:NSDocumentDirectory
                                 inDomains:NSUserDomainMask]
                                lastObject];
   NSURL *photoAlbumPath = [documentsDirectory
                            URLByAppendingPathComponent:(NSString *)kPhotoAlbumFilename];
   return photoAlbumPath;
}

- (NSMutableDictionary *)newPhotoAlbumWithName:(NSString *)albumName
{
   NSMutableDictionary *newAlbum = [NSMutableDictionary dictionary];
   [newAlbum setObject:albumName forKey:kPhotoAlbumNameKey];
   [newAlbum setObject:[NSDate date] forKey:kPhotoAlbumDateAddedKey];
   NSMutableArray *photos = [NSMutableArray array];
   for (NSUInteger index=0; index<10; index++) {
      [photos addObject:[NSDictionary dictionary]];
   }
   [newAlbum setObject:photos forKey:kPhotoAlbumPhotosKey];
   return newAlbum;
}

- (void)savePhotoAlbum
{
   [[self data] writeToURL:[self photoAlbumPath] atomically:YES];
}

- (void)readSavedPhotoAlbums
{
   NSMutableArray *savedAlbums = nil;
   
   NSData *photoAlbumData = [NSData dataWithContentsOfURL:[self photoAlbumPath]];
   if (photoAlbumData != nil) {
      NSMutableArray *albums = [NSPropertyListSerialization
                                propertyListWithData:photoAlbumData 
                                options:NSPropertyListMutableContainers 
                                format:nil 
                                error:nil];
      [self setData:albums];
   } else {
      savedAlbums = [NSMutableArray array];
      // Create an initial album
      [savedAlbums addObject:[self newPhotoAlbumWithName:@"First album"]];
      [self setData:savedAlbums];
      [self savePhotoAlbum];
   }
}

- (void)photoAlbumSaveNeeded:(NSNotification *)notification
{
   [self savePhotoAlbum];
}

@end
