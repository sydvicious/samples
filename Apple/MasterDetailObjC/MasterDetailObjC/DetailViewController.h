//
//  DetailViewController.h
//  MasterDetailObjC
//
//  Created by Sydney Polk on 6/6/17.
//  Copyright © 2017 Sydney Polk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterDetailObjC+CoreDataModel.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Event *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

