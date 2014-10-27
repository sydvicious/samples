//
//  PrepareTVC.m
//  Grocery Dude
//
//  Created by Syd Polk on 10/5/14.
//  Copyright (c) 2014 Tim Roadley. All rights reserved.
//

#import "PrepareTVC.h"
#import "CoreDataHelper.h"
#import "Item.h"
#import "Unit.h"
#import "AppDelegate.h"

@interface PrepareTVC ()

@end

@implementation PrepareTVC

#define debug 1

#pragma mark - DATA

- (void) configureFetch {
    if (debug) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    CoreDataHelper *cdh = [(AppDelegate *) [[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"locationAtHome.storedIn" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];
    [request setFetchBatchSize:50];
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:@"locationAtHome.storedIn" cacheName:nil];
    self.frc.delegate = self;
}

#pragma mark - VIEW

- (void) viewDidLoad {
    if (debug) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    [self configureFetch];
    [self performFetch];
    self.clearConfirmActionSheet.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performFetch) name:@"SomethingChanged" object:nil];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (debug) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    static NSString *cellIdentifier = @"Item Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    Item *item = [self.frc objectAtIndexPath:indexPath];
    
    NSMutableString *title = [NSMutableString stringWithFormat:@"%@ %@ %@", item.quantity, item.unit.name, item.name];
    [title replaceOccurrencesOfString:@"(null)" withString:@"" options:0 range:NSMakeRange(0, [title length])];
    cell.textLabel.text = title;
    
    // make selected items orange;
    
    if ([item.listed boolValue]) {
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:18]];
        [cell.textLabel setTextColor:[UIColor orangeColor]];
    } else {
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:16]];
        [cell.textLabel setTextColor:[UIColor grayColor]];
    }
    return cell;
}

- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (debug) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return nil;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (debug) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Item *deleteTarget = [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:deleteTarget];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (debug) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSManagedObjectID *itemid = [[self.frc objectAtIndexPath:indexPath] objectID];
    
    Item *item = (Item *)[self.frc.managedObjectContext existingObjectWithID:itemid error:nil];
    
    if ([item.listed boolValue]) {
        item.listed = [NSNumber numberWithBool:NO];
    } else {
        item.listed = [NSNumber numberWithBool:YES];
        item.collected = [NSNumber numberWithBool:NO];
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - INTERACTION

- (IBAction)clear:(id)sender {
    if (debug) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CoreDataHelper *cdh = [(AppDelegate *) [[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request = [cdh.model fetchRequestTemplateForName:@"ShoppingList"];
    NSArray *shoppingList = [cdh.context executeFetchRequest:request error:nil];
    
    if (shoppingList.count > 0) {
        self.clearConfirmActionSheet = [[UIActionSheet alloc] initWithTitle:@"Clear Entire Shopping List?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear" otherButtonTitles:nil];
        [self.clearConfirmActionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nothing to clear" message:@"Add items to the Shop tab by tapping them on the Prepare tab. Remove all items from the Shob tab by clicking Clar on the Prepare tab." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    shoppingList = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (debug) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (actionSheet == self.clearConfirmActionSheet) {
        if (buttonIndex == [actionSheet destructiveButtonIndex]) {
            [self performSelector:@selector(clearList)];
        } else if (buttonIndex == [actionSheet cancelButtonIndex]) {
            [actionSheet dismissWithClickedButtonIndex:[actionSheet cancelButtonIndex] animated:YES];
        }
    }
}

- (void) clearList {
    if (debug) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CoreDataHelper *cdh = [(AppDelegate *) [[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request = [cdh.model fetchRequestTemplateForName:@"ShoppingList"];
    NSArray *shoppingList = [cdh.context executeFetchRequest:request error:nil];
    
    for (Item *item in shoppingList) {
        item.listed = [NSNumber numberWithBool:NO];
    }
}

@end
