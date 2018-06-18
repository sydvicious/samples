//
//  DetailViewController.h
//  MasterDetailObjC
//
//  Created by Syd Polk on 6/17/18.
//  Copyright © 2018 Bone Jarring Games and Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterDetailObjC+CoreDataModel.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Event *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

