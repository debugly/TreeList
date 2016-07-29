//
//  MutableDeleteViewController.m
//  TreeList
//
//  Created by qianlongxu on 16/3/18.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import "MutableDeleteViewController.h"
#import "QLTableViewRowAction.h"
#import "QLTableViewCell.h"
#import "QLVersionUtil.h"

@interface MutableDeleteViewController ()

@property (nonatomic, strong) NSArray *sectionObjects;

@end

@implementation MutableDeleteViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    int random = arc4random() % 26 + 1;
    
    NSMutableArray *section0Arr = [[NSMutableArray alloc]init];
    NSMutableArray *section1Arr = [[NSMutableArray alloc]init];
    
    while (random--) {
        if(random % 2){
            [section0Arr addObject:@(random)];
        }else{
            [section1Arr addObject:@(random)];
        }
    }
    
    self.sectionObjects = @[section0Arr,section1Arr];
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionObjects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionObjs = self.sectionObjects[section];
    return sectionObjs.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return @"支持侧滑";
    }else{
        return @"不支持侧滑";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSArray *sectionObjs = self.sectionObjects[indexPath.section];
    
    NSNumber *i = sectionObjs[indexPath.row];
    cell.textLabel.text = [i description];
    return cell;
}

#pragma mark - edit logic begin

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 1) {
        return NO;
    }
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *actions = [self tableView:tableView editActionsForRowAtIndexPath:indexPath];
    QLTableViewRowAction *action = [actions firstObject];
    return [action title];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QLTableViewRowAction *action1 = [QLTableViewRowAction rowActionWithStyle:QLTableViewRowActionStyleDefault title:@"1自动删除" handler:^(QLTableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"clicked :%@",action.title);
    }];
    
    QLTableViewRowAction *action2 = [QLTableViewRowAction rowActionWithStyle:QLTableViewRowActionStyleDefault title:@"2自删除" handler:^(QLTableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"clicked :%@",action.title);
        //iOS 8 later，you need close it；
        if ([QLVersionUtil iOS8Later]) {
            [[tableView cellForRowAtIndexPath:indexPath]hideDeleteConfirmation];
        }
    }];
    
    QLTableViewRowAction *action3 = [QLTableViewRowAction rowActionWithStyle:QLTableViewRowActionStyleNormal title:@"3删除" handler:^(QLTableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"clicked :%@",action.title);
    }];
    
    QLTableViewRowAction *action4 = [QLTableViewRowAction rowActionWithStyle:QLTableViewRowActionStyleNormal title:@"4不删除" handler:^(QLTableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"clicked :%@",action.title);
    }];
    
    NSArray *bgColors = @[[UIColor colorWithRed:255.0f/255.0f green:59.0f/255.0f blue:48.0f/255.0f alpha:1.0],
                          [UIColor colorWithRed:255.0f/255.0f green:156.0f/255.0f blue:3.0f/255.0f alpha:1.0],
                          [UIColor colorWithRed:255.0f/255.0f green:128.0f/255.0f blue:1.0f/255.0f alpha:1.0]];
    
    action2.backgroundColor = bgColors[1];
    action3.backgroundColor = bgColors[1];
    action4.backgroundColor = bgColors[2];
    if (indexPath.row == 0) {
        return @[action1];
    }else if (indexPath.row == 1){
        return @[action1,action2];
    }else if (indexPath.row == 2){
        return @[action1,action2,action3];
    }
    
    return @[action1,action2,action3,action4];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        //just handle other edit style
    }
}

//滑动的时候关闭侧滑的cell；
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    UITableView *tb = (id)scrollView;
    for (QLTableViewCell *cell in [tb visibleCells]) {
        [cell hideDeleteConfirmation];
    }
}

@end
