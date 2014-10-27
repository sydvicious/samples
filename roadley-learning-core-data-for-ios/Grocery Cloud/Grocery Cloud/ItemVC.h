//
//  ItemVC.h
//  Grocery Cloud
//
//  Created by Tim Roadley on 19/09/13.
//  Copyright (c) 2013 Tim Roadley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
#import "UnitPickerTF.h"
#import "LocationAtHomePickerTF.h" 
#import "LocationAtShopPickerTF.h"

@interface ItemVC : UIViewController <UITextFieldDelegate,CoreDataPickerTFDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) NSManagedObjectID *selectedItemID;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *quantityTextField;
@property (strong, nonatomic) IBOutlet UnitPickerTF *unitPickerTextField;
@property (strong, nonatomic) IBOutlet LocationAtHomePickerTF *homeLocationPickerTextField;
@property (strong, nonatomic) IBOutlet LocationAtShopPickerTF *shopLocationPickerTextField;
@property (strong, nonatomic) IBOutlet UITextField *activeField;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) UIImagePickerController *camera;
@end
