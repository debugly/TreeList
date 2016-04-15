//
//  CustomTableViewCellController.m
//  MSCMoreOptionTableViewCellDemo
//
//  Created by Manfred Scheiner (@scheinem) on 24.08.13.
//  Copyright (c) 2014 Manfred Scheiner (@scheinem). All rights reserved.
//

#import "StoryboardTableViewCellController.h"
#import "MSCMoreOptionTableViewCell.h"

@interface StoryboardTableViewCellController () <MSCMoreOptionTableViewCellDelegate>

@end

@implementation StoryboardTableViewCellController

////////////////////////////////////////////////////////////////////////
#pragma mark - Initializer
////////////////////////////////////////////////////////////////////////

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MSCMoreOptionTableViewCell";
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"MSCMoreOptionTableViewCell";
    MSCMoreOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
	cell.delegate = self;
	
	[cell setConfigurationBlock:^(UIButton *deleteButton, UIButton *moreOptionButton, CGFloat *deleteButtonWitdh, CGFloat *moreOptionButtonWidth) {
        // Hide delete button every second row (odd-numbered)
        *deleteButtonWitdh = 80;
        *moreOptionButtonWidth = 120;
        // Give the 'more' button an orange background every third row
        moreOptionButton.backgroundColor = [UIColor orangeColor];
    }];

    cell.textLabel.text = @"Cell";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Called when 'delete' button is pushed.
        NSLog(@"DELETE button pressed in row at: %@", indexPath.description);
        // Hide 'more'- and 'delete'-confirmation view
        [tableView.visibleCells enumerateObjectsUsingBlock:^(MSCMoreOptionTableViewCell *cell, NSUInteger idx, BOOL *stop) {
            if ([[tableView indexPathForCell:cell] isEqual:indexPath]) {
                [cell hideDeleteConfirmation];
            }
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate
////////////////////////////////////////////////////////////////////////

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.f;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MSCMoreOptionTableViewCellDelegate
////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath {
    // Called when 'more' button is pushed.
    NSLog(@"MORE button pressed in row at: %@", indexPath.description);
    // Hide 'more'- and 'delete'-confirmation view
    [tableView.visibleCells enumerateObjectsUsingBlock:^(MSCMoreOptionTableViewCell *cell, NSUInteger idx, BOOL *stop) {
        if ([[tableView indexPathForCell:cell] isEqual:indexPath]) {
            [cell hideDeleteConfirmation];
        }
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"取消自动删除";
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

@end
