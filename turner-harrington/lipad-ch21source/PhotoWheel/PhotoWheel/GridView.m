//
//  GridView.m
//  PhotoWheel
//
//  Created by Kirby Turner on 9/29/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "GridView.h"

#pragma mark - GridViewCell

@interface GridViewCell ()                                              // 1
@property (nonatomic, assign) NSInteger indexInGrid;
@end

@implementation GridViewCell                                            // 2
@synthesize selected = selected_;
@synthesize indexInGrid = indexInGrid_;
@end


#pragma mark - GridView

@interface GridView ()                                                  // 3
@property (nonatomic, strong) NSMutableSet *reusableViews;
@property (nonatomic, assign) NSInteger firstVisibleIndex;
@property (nonatomic, assign) NSInteger lastVisibleIndex;
@property (nonatomic, assign) NSInteger previousItemsPerRow;
@property (nonatomic, strong) NSMutableSet *selectedCellIndexes;
@end

@implementation GridView                                                // 4

@synthesize dataSource = _dataSource;
@synthesize reusableViews = _reusableViews;
@synthesize firstVisibleIndex = _firstVisibleIndex;
@synthesize lastVisibleIndex = _lastVisibleIndex;
@synthesize previousItemsPerRow = _previousItemsPerRow;
@synthesize selectedCellIndexes = _selectedCellIndexes;
@synthesize allowsMultipleSelection = _allowsMultipleSelection;

- (void)commonInit                                                      // 5
{
   // We keep a collection of reusable views. This 
   // improves scrolling performance by not requiring
   // creation of the view each and every time.
   self.reusableViews = [[NSMutableSet alloc] init];
   
   // We have no views visible at first so we
   // set index values high and low to trigger
   // the display during layoutSubviews.
   [self setFirstVisibleIndex:NSIntegerMax];
   [self setLastVisibleIndex:NSIntegerMin];
   [self setPreviousItemsPerRow:NSIntegerMin];
   
   [self setDelaysContentTouches:YES];                                  // 6
   [self setClipsToBounds:YES];                                         // 7
   [self setAlwaysBounceVertical:YES];                                  // 8
   
   [self setAllowsMultipleSelection:NO];                                // 9
   self.selectedCellIndexes = [[NSMutableSet alloc] init];              // 10
   
   UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] 
          initWithTarget:self action:@selector(didTap:)];               // 11
   [self addGestureRecognizer:tap];
}

- (id)init                                                              // 12
{
   self = [super init];
   if (self) {
      [self commonInit];
   }
   return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   if (self) {
      [self commonInit];
   }
   return self;
}

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) {
      [self commonInit];
   }
   return self;
}

- (id)dequeueReusableCell                                              // 13
{
   id view = [[self reusableViews] anyObject];
   if (view != nil) {
      [[self reusableViews] removeObject:view];
   }
   return view;
}

- (void)queueReusableCells                                             // 14
{
   for (UIView *view in [self subviews]) {
      if ([view isKindOfClass:[GridViewCell class]]) {
         [[self reusableViews] addObject:view];
         [view removeFromSuperview];
      }
   }
   
   [self setFirstVisibleIndex:NSIntegerMax];
   [self setLastVisibleIndex:NSIntegerMin];
   [[self selectedCellIndexes] removeAllObjects];
}

- (void)reloadData                                                      // 15
{
   [self queueReusableCells];
   [self setNeedsLayout];
}

- (GridViewCell *)cellAtIndex:(NSInteger)index                          // 16
{
   GridViewCell *cell = nil;
   if (index >= [self firstVisibleIndex] && index <= [self lastVisibleIndex]) {
      for (id view in [self subviews]) {
         if ([view isKindOfClass:[GridViewCell class]]) {
            if ([view indexInGrid] == index) {
               cell = view;
               break;
            }
         }
      }
   }
   
   if (cell == nil) {
      cell = [[self dataSource] gridView:self cellAtIndex:index];
   }
   
   return cell;
}

- (void)layoutSubviews                                                  // 17
{
   [super layoutSubviews];
   
   CGRect visibleBounds = [self bounds];                                // 18
   NSInteger visibleWidth = visibleBounds.size.width;
   NSInteger visibleHeight = visibleBounds.size.height;
   
   CGSize viewSize = [[self dataSource] gridViewCellSize:self];         // 19
   
   // Do some math to determine which rows and columns
   // are visible.
   NSInteger itemsPerRow = NSIntegerMin;                                // 20
   if ([[self dataSource] respondsToSelector:@selector(gridViewCellsPerRow:)]) {
      itemsPerRow = [[self dataSource] gridViewCellsPerRow:self];
   }
   if (itemsPerRow == NSIntegerMin) {
      // Calculate the number of items per row.
      itemsPerRow = floor(visibleWidth / viewSize.width);
   }
   if (itemsPerRow != [self previousItemsPerRow]) {
      // Force reload of grid views. Unfortunately this means
      // visible views will reload, which can hurt performance
      // when the view isn't cached. Need to find a better 
      // approach someday.
      [self queueReusableCells];
   }
   [self setPreviousItemsPerRow:itemsPerRow];
   
   // Ensure a minimum amount of space between views.
   NSInteger minimumSpace = 5;
   if (visibleWidth - itemsPerRow * viewSize.width < minimumSpace) {
      itemsPerRow--;
   }
   
   if (itemsPerRow < 1) itemsPerRow = 1;  // Ensure at least one view per row.
   
   NSInteger spaceWidth = 
      round((visibleWidth - viewSize.width * itemsPerRow) / (itemsPerRow + 1));
   NSInteger spaceHeight = spaceWidth;
   
   // Calculate the content size for the scroll view.
   NSInteger viewCount = [[self dataSource] gridViewNumberOfCells:self];
   NSInteger rowCount = ceil(viewCount / (float)itemsPerRow);
   NSInteger rowHeight = viewSize.height + spaceHeight;
   CGSize contentSize = CGSizeMake(visibleWidth, 
                                   (rowHeight * rowCount + spaceHeight));
   [self setContentSize:contentSize];                                   // 21
   
   NSInteger numberOfVisibleRows = visibleHeight / rowHeight;
   NSInteger topRow = MAX(0, floorf(visibleBounds.origin.y / rowHeight));
   NSInteger bottomRow = topRow + numberOfVisibleRows;
   
   CGRect extendedVisibleBounds = 
      CGRectMake(visibleBounds.origin.x, 
                 MAX(0, visibleBounds.origin.y), 
                 visibleBounds.size.width, 
                 visibleBounds.size.height + rowHeight);
   
   // Recycle all views that are no longer visible.
   for (UIView *view in [self subviews]) {                              // 22
      if ([view isKindOfClass:[GridViewCell class]]) {
         CGRect viewFrame = [view frame];
         
         // If the view doesn't intersect, it's not visible, so recycle it.
         if (!CGRectIntersectsRect(viewFrame, extendedVisibleBounds)) {
            [[self reusableViews] addObject:view];
            [view removeFromSuperview];
         }
      }
   }
   
   /////////////
   // Whew! We're now ready to lay out the subviews.                    // 23
   
   NSInteger startAtIndex = MAX(0, topRow * itemsPerRow);
   NSInteger stopAtIndex = MIN(viewCount, 
                               (bottomRow * itemsPerRow) + itemsPerRow);
   
   // Set the initial origin.
   NSInteger x = spaceWidth;
   NSInteger y = spaceHeight + (topRow * rowHeight);
   
   // Iterate through the needed views, adding any views that are missing.
   for (NSInteger index = startAtIndex; index < stopAtIndex; index++) {
      
      // Set the frame so the view is placed in the correct position.
      GridViewCell *view = [self cellAtIndex:index];
      CGRect newFrame = CGRectMake(x, y, viewSize.width, viewSize.height);
      [view setFrame:newFrame];
      
      // If the index is between the first and last, the
      // view is not missing.
      BOOL isViewMissing = 
         !(index >= [self firstVisibleIndex] && index < [self lastVisibleIndex]);
      if (isViewMissing) {
         BOOL selected = [[self selectedCellIndexes] 
                          containsObject:[NSNumber numberWithInteger:index]];
         [view setSelected:selected];
         [view setIndexInGrid:index];
         [self addSubview:view];
      }
      
      // Adjust the position.
      if ((index+1) % itemsPerRow == 0) {
         // Start new row.
         x = spaceWidth;
         y += viewSize.height + spaceHeight;
      } else {
         x += viewSize.width + spaceWidth;
      }
   }
   
   // Finally, remember which view indexes are visible.
   [self setFirstVisibleIndex:startAtIndex];
   [self setLastVisibleIndex:stopAtIndex];
}

- (void)didTap:(UITapGestureRecognizer *)recognizer                     // 24
{
   // Need to figure out if the user tapped a cell or not.
   // If a cell was tapped, let the data source know
   // which cell was tapped.
   
   CGPoint touchPoint = [recognizer locationInView:self];
   
   for (id view in [self subviews]) {
      if ([view isKindOfClass:[GridViewCell class]]) {
         if (CGRectContainsPoint([view frame], touchPoint)) {           // 25
            
            NSInteger previousIndex = -1;                               // 26
            NSInteger selectedIndex = -1;
            
            NSMutableSet *selectedCellIndexes = [self selectedCellIndexes];
            if ([self allowsMultipleSelection] == NO) {
               // Out with the old.
               if ([selectedCellIndexes count] > 0) {
                  previousIndex = [[selectedCellIndexes anyObject] integerValue];
                  [[self cellAtIndex:previousIndex] setSelected:NO];
                  [selectedCellIndexes removeAllObjects];
               }
               
               // And in with the new.
               selectedIndex = [view indexInGrid];
               [view setSelected:YES];
               [selectedCellIndexes 
                  addObject:[NSNumber numberWithInteger:selectedIndex]];
               
            } else {
               NSInteger indexInGrid = [view indexInGrid];
               NSNumber *numberIndexInGrid = 
                  [NSNumber numberWithInteger:indexInGrid];
               if ([selectedCellIndexes containsObject:numberIndexInGrid]) {
                  previousIndex = indexInGrid;
                  [view setSelected:NO];
                  [selectedCellIndexes removeObject:numberIndexInGrid];
               } else {
                  selectedIndex = indexInGrid;
                  [view setSelected:YES];
                  [selectedCellIndexes addObject:numberIndexInGrid];
               }
            }
            
            id <GridViewDataSource> dataSource = [self dataSource];     // 27
            if (previousIndex >= 0) {
               if ([dataSource 
                    respondsToSelector:@selector(gridView:didDeselectCellAtIndex:)])
               {
                  [dataSource gridView:self didDeselectCellAtIndex:previousIndex];
               }
            }
            if (selectedIndex >= 0) {
               if ([dataSource 
                    respondsToSelector:@selector(gridView:didSelectCellAtIndex:)])
               {
                  [dataSource gridView:self didSelectCellAtIndex:selectedIndex];
               }
            }
            
            break;
         }
      }
   }
}

- (NSInteger)indexForSelectedCell                                       // 28
{
   NSInteger selectedIndex = -1;
   NSMutableSet *selectedCellIndexes = [self selectedCellIndexes];
   if ([selectedCellIndexes count] > 0) {
      selectedIndex = [[selectedCellIndexes anyObject] integerValue];
   }
   return selectedIndex;
}

- (NSArray *)indexesForSelectedCells                                   // 29
{
   NSArray *selectedIndexes = nil;
   NSMutableSet *selectedCellIndexes = [self selectedCellIndexes];
   if ([selectedCellIndexes count] > 0) {
      NSSortDescriptor *sortDescriptor = [NSSortDescriptor 
                                          sortDescriptorWithKey:@"self" 
                                          ascending:YES];
      selectedIndexes = [selectedCellIndexes 
       sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
   }
   return selectedIndexes;
}

@end