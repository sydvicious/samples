//
//  PhotoAlbumViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/13/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoAlbumViewController.h"
#import "PhotoAlbum.h"
#import "Photo.h"
#import "ImageGridViewCell.h"

@interface PhotoAlbumViewController ()
@property (nonatomic, strong) PhotoAlbum *photoAlbum;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIPopoverController *imagePickerPopoverController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) SendEmailController *sendEmailController;

- (void)presentPhotoPickerMenu;
- (void)emailPhotos;
@end

@implementation PhotoAlbumViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize objectID = _objectID;
@synthesize toolbar = _toolbar;
@synthesize textField = _textField;
@synthesize addButton = _addButton;
@synthesize photoAlbum = _photoAlbum;
@synthesize imagePickerController = _imagePickerController;
@synthesize imagePickerPopoverController = _imagePickerPopoverController;
@synthesize gridView = _gridView;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize shadowImageView = _shadowImageView;
@synthesize sendEmailController = _sendEmailController;

- (void)didMoveToParentViewController:(UIViewController *)parent
{
   // Position the view within the new parent.
   [[parent view] addSubview:[self view]];
   CGRect newFrame = CGRectMake(26, 18, 716, 717);
   [[self view] setFrame:newFrame];
   
   [[self view] setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   [self reload];
}

- (void)viewDidUnload
{
   [self setToolbar:nil];
   [self setTextField:nil];
   [self setAddButton:nil];
   [self setGridView:nil];
   [super viewDidUnload];
}
- (UIImagePickerController *)imagePickerController
{
   if (_imagePickerController) {
      return _imagePickerController;
   }
   
   self.imagePickerController = [[UIImagePickerController alloc] init];
   [self.imagePickerController setDelegate:self];
   
   return _imagePickerController;
}

#pragma mark Photo album management

- (void)reload
{
   if ([self managedObjectContext] && [self objectID]) {
      self.photoAlbum = (PhotoAlbum *)[self.managedObjectContext 
                                       objectWithID:[self objectID]];
      [[self toolbar] setHidden:NO];
      [[self textField] setText:[self.photoAlbum name]];
   } else {
      [self setPhotoAlbum:nil];
      [[self toolbar] setHidden:YES];
      [[self textField] setText:@""];
   }
   
   [self setFetchedResultsController:nil];
   [[self gridView] reloadData];
}

- (void)saveChanges
{
   // Save the context.
   NSManagedObjectContext *context = [self managedObjectContext];
   NSError *error = nil;
   if (![context save:&error])
   {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. 
       You should not use this function in a shipping application, although 
       it may be useful during development. If it is not possible to recover 
       from the error, display an alert panel that instructs the user to quit 
       the application by pressing the Home button.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
   [textField setBorderStyle:UITextBorderStyleRoundedRect];
   [textField setTextColor:[UIColor blackColor]];
   [textField setBackgroundColor:[UIColor whiteColor]];
   return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
   [textField setBackgroundColor:[UIColor clearColor]];
   [textField setTextColor:[UIColor whiteColor]];
   [textField setBorderStyle:UITextBorderStyleNone];
   
   [[self photoAlbum] setName:[textField text]];
   [self saveChanges];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [textField resignFirstResponder];
   return NO;
}

#pragma mark Actions

- (IBAction)showActionMenu:(id)sender 
{
   UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
   [actionSheet setDelegate:self];
   
   if ([SendEmailController canSendMail]) {
      [actionSheet addButtonWithTitle:@"Email Photo Album"];
   }
   
   [actionSheet addButtonWithTitle:@"Delete Photo Album"];
   [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (IBAction)addPhoto:(id)sender 
{
   if ([self imagePickerPopoverController]) {
      [[self imagePickerPopoverController] dismissPopoverAnimated:YES];
   }
   
   [self presentPhotoPickerMenu];   
}

#pragma mark - Confirm and delete photo album

- (void)confirmDeletePhotoAlbum
{
   NSString *message;
   NSString *name = [[self photoAlbum] name];
   if ([name length] > 0) {
      message = [NSString stringWithFormat:
                 @"Delete the photo album \"%@\". This action cannot be undone.", 
                 name];
   } else {
      message = @"Delete this photo album? This action cannot be undone.";
   }
   UIAlertView *alertView = [[UIAlertView alloc] 
                             initWithTitle:@"Delete Photo Album" 
                             message:message 
                             delegate:self 
                             cancelButtonTitle:@"Cancel" 
                             otherButtonTitles:@"OK", nil];
   [alertView show];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView 
clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if (buttonIndex == 1) {
      [self.managedObjectContext deleteObject:[self photoAlbum]];
      [self setPhotoAlbum:nil];
      [self setObjectID:nil];
      [self saveChanges];
      [self reload];
   }
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet 
clickedButtonAtIndex:(NSInteger)buttonIndex
{
   // Do nothing if the user taps outside the action 
   // sheet (thus closing the popover containing the
   // action sheet).
   if (buttonIndex < 0) {
      return;
   }
   
   NSMutableArray *names = [[NSMutableArray alloc] init];
   
   if ([actionSheet tag] == 0) {
      if ([SendEmailController canSendMail]) [names addObject:@"emailPhotos"];
      [names addObject:@"confirmDeletePhotoAlbum"];
      
   } else {
      BOOL hasCamera = [UIImagePickerController 
               isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
      if (hasCamera) [names addObject:@"presentCamera"];
      [names addObject:@"presentPhotoLibrary"];
   }
   
   SEL selector = NSSelectorFromString([names objectAtIndex:buttonIndex]);
   [self performSelector:selector];
}

#pragma mark - Image picker helper methods

- (void)presentCamera
{
   // Display the camera.
   UIImagePickerController *imagePicker = [self imagePickerController];
   [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
   [self presentModalViewController:imagePicker animated:YES];
}

- (void)presentPhotoLibrary
{
   // Display assets from the photo library only.
   UIImagePickerController *imagePicker = [self imagePickerController];
   [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
   
   UIPopoverController *newPopoverController = 
      [[UIPopoverController alloc] initWithContentViewController:imagePicker];
   [newPopoverController presentPopoverFromBarButtonItem:[self addButton] 
                                permittedArrowDirections:UIPopoverArrowDirectionAny 
                                                animated:YES];
   [self setImagePickerPopoverController:newPopoverController];
}

- (void)presentPhotoPickerMenu
{
   UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
   [actionSheet setDelegate:self];
   BOOL hasCamera = [UIImagePickerController 
               isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
   if (hasCamera) {
      [actionSheet addButtonWithTitle:@"Take Photo"];
   }
   [actionSheet addButtonWithTitle:@"Choose from Library"];
   [actionSheet setTag:1];
   [actionSheet showFromBarButtonItem:[self addButton] animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   // If the popover controller is available, 
   // assume the photo is selected from the library
   // and not from the camera.
   BOOL takenWithCamera = ([self imagePickerPopoverController] == nil);
   
   if (takenWithCamera) {
      [self dismissModalViewControllerAnimated:YES];
   } else {
      [[self imagePickerPopoverController] dismissPopoverAnimated:YES];
      [self setImagePickerPopoverController:nil];
   }
   
   // Retrieve and display the image.
   UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
   
   NSManagedObjectContext *context = [self managedObjectContext];
   Photo *newPhoto = 
      [NSEntityDescription insertNewObjectForEntityForName:@"Photo" 
                                    inManagedObjectContext:context];
   [newPhoto setDateAdded:[NSDate date]];
   [newPhoto saveImage:image];
   [newPhoto setPhotoAlbum:[self photoAlbum]];
   
   [self saveChanges];
}

#pragma mark - NSFetchedResultsController and NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController
{
   if (_fetchedResultsController) {
      return _fetchedResultsController;
   }
   
   NSManagedObjectContext *context = [self managedObjectContext];
   if (!context) {
      return nil;
   }
   
   NSString *cacheName = [NSString stringWithFormat:@"%@-%@", 
                          [self.photoAlbum name], [self.photoAlbum dateAdded]];
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entityDescription = 
      [NSEntityDescription entityForName:@"Photo" 
                  inManagedObjectContext:context];
   [fetchRequest setEntity:entityDescription];
   
   NSSortDescriptor *sortDescriptor = 
      [NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:YES];
   [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
   
   [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"photoAlbum = %@", 
                               [self photoAlbum]]];
   
   NSFetchedResultsController *newFetchedResultsController = 
      [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                          managedObjectContext:context 
                                            sectionNameKeyPath:nil 
                                                     cacheName:cacheName];
   [newFetchedResultsController setDelegate:self];
   [self setFetchedResultsController:newFetchedResultsController];
   
   NSError *error = nil;
   if (![[self fetchedResultsController] performFetch:&error])
   {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. 
       You should not use this function in a shipping application, although 
       it may be useful during development. If it is not possible to recover 
       from the error, display an alert panel that instructs the user to quit 
       the application by pressing the Home button.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
   
   return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
   [[self gridView] reloadData];
}

#pragma mark GridViewDataSource methods

- (NSInteger)gridViewNumberOfCells:(GridView *)gridView
{
   NSInteger count = [[[[self fetchedResultsController] sections] 
                       objectAtIndex:0] numberOfObjects];
   return count;
}

- (GridViewCell *)gridView:(GridView *)gridView cellAtIndex:(NSInteger)index
{
   ImageGridViewCell *cell = [gridView dequeueReusableCell];
   if (cell == nil) {
      cell = [ImageGridViewCell imageGridViewCellWithSize:CGSizeMake(100, 100)];
   }
   
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   Photo *photo = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   [[cell imageView] setImage:[photo smallImage]];
   
   return cell;
}
- (CGSize)gridViewCellSize:(GridView *)gridView
{
   return CGSizeMake(100, 100);
}

- (void)gridView:(GridView *)gridView didSelectCellAtIndex:(NSInteger)index
{
   [self performSegueWithIdentifier:@"PushPhotoBrowser" sender:self];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   PhotoBrowserViewController *destinationViewController = 
      [segue destinationViewController];
   [destinationViewController setDelegate:self];
   NSInteger index = [[self gridView] indexForSelectedCell];
   [destinationViewController setStartAtIndex:index];
}

#pragma mark - PhotoBrowserViewControllerDelegate methods

- (NSInteger)photoBrowserViewControllerNumberOfPhotos:
(PhotoBrowserViewController *)photoBrowser                              // 3
{
   NSInteger count = [[[[self fetchedResultsController] sections] 
                       objectAtIndex:0] numberOfObjects];
   return count;
}

- (UIImage *)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser 
                           imageAtIndex:(NSInteger)index                // 4
{
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   Photo *photo = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   return [photo largeImage];
}

#pragma mark -

- (NSInteger)indexForSelectedGridCell
{
   GridView *gridView = [self gridView];
   NSInteger selectedIndex = [gridView indexForSelectedCell];
   NSInteger count = [[[[self fetchedResultsController] sections] 
                       objectAtIndex:0] numberOfObjects];
   if (selectedIndex < 0 && count > 0) {
      selectedIndex = 0;
   }
   return selectedIndex;
}


- (UIImage *)selectedImage
{
   UIImage *selectedImage = nil;
   NSInteger selectedIndex = [self indexForSelectedGridCell];
   if (selectedIndex >= 0) {
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedIndex 
                                                  inSection:0];
      Photo *photo = [[self fetchedResultsController] 
                      objectAtIndexPath:indexPath];
      selectedImage = [photo largeImage];
   }
   return selectedImage;
}

- (CGRect)selectedCellFrame
{
   CGRect rect;
   GridView *gridView = [self gridView];
   NSInteger selectedIndex = [self indexForSelectedGridCell];
   if (selectedIndex >= 0) {
      GridViewCell *cell = [gridView cellAtIndex:selectedIndex];
      UIView *parentView = [[self parentViewController] view];
      rect = [parentView convertRect:[cell frame] fromView:gridView];
   } else {
      CGRect gridFrame = [gridView frame];
      rect = CGRectMake(CGRectGetMidX(gridFrame), 
                        CGRectGetMidY(gridFrame), 0, 0);
   }
   return rect;
}

- (void)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser 
                deleteImageAtIndex:(NSInteger)index
{
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   Photo *photo = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   NSManagedObjectContext *context = [self managedObjectContext];
   [context deleteObject:photo];
   [self saveChanges];   
}

#pragma mark - Rotation support

- (void)layoutForLandscape
{
   [[self view] setFrame:CGRectMake(18, 20, 738, 719)];
   [[self backgroundImageView] setImage:[UIImage 
                             imageNamed:@"stack-viewer-bg-landscape-right.png"]];
   [[self backgroundImageView] setFrame:[[self view] bounds]];
   [[self shadowImageView] setFrame:CGRectMake(9, 51, 678, 8)];
   [[self gridView] setFrame:CGRectMake(20, 52, 654, 632)];
   [[self toolbar] setFrame:CGRectMake(9, 6, 678, 44)];
}

- (void)layoutForPortrait
{
   [[self view] setFrame:CGRectMake(26, 18, 716, 717)];
   [[self backgroundImageView] setImage:[UIImage 
                                   imageNamed:@"stack-viewer-bg-portrait.png"]];
   [[self backgroundImageView] setFrame:[[self view] bounds]];
   [[self shadowImageView] setFrame:CGRectMake(9, 51, 698, 8)];
   [[self gridView] setFrame:CGRectMake(20, 51, 678, 597)];
   [[self toolbar] setFrame:CGRectMake(9, 6, 698, 44)];
}

- (void)willAnimateRotationToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
      [self layoutForLandscape];
   } else {
      [self layoutForPortrait];
   }
}

#pragma mark - Email and SendEmailControllerDelegate methods

- (void)emailPhotos
{
   NSManagedObjectContext *context = [self managedObjectContext];
   PhotoAlbum *album = (PhotoAlbum *)[context objectWithID:[self objectID]];
   NSSet *photos = [[album photos] set];
   
   SendEmailController *controller = [[SendEmailController alloc] 
                                      initWithViewController:self];
   [controller setPhotos:photos];
   [controller sendEmail];
   
   [self setSendEmailController:controller];
}

- (void)sendEmailControllerDidFinish:(SendEmailController *)controller
{
   if ([controller isEqual:[self sendEmailController]]) {
      [self setSendEmailController:nil];
   }
}

@end
