//
//  MutableSelectDeleteViewController.m
//  TreeList
//
//  Created by qianlongxu on 16/3/18.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import "MutableSelectDeleteViewController.h"
#import "QLTableViewRowAction.h"

@interface MutableSelectDeleteViewController ()

@property (nonatomic, strong) NSMutableArray *objects;
//@property (nonatomic, assign) BOOL isSwipeDeleteStyle;

@end

@implementation MutableSelectDeleteViewController

- (NSMutableArray *)objects
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc]init];
    }
    return _objects;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    int random = arc4random() % 200 + 15;
    while (random--) {
        [self.objects addObject:@(random)];
    }
    
    //开启多选编辑 iOS 7开启之后会导致不能侧滑！！！
//    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

//注意cell必须继承QLTableViewCell，我在 storyboard 里设置的！！！
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDate *date = self.objects[indexPath.row];
    cell.textLabel.text = [date description];
    return cell;
}

//删除，插入，侧滑都会调用此方法；iOS8侧滑除外！多选不会触发这个方法！
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //nothing,just show delete;
}

//- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(nonnull NSIndexPath *)indexPath
//{
//    self.isSwipeDeleteStyle = YES;
//}
//
//- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(nonnull NSIndexPath *)indexPath
//{
//    self.isSwipeDeleteStyle = NO;
//}

//重写这个方法，处理多选处理！
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    
    if (!editing) {
        NSArray *idxs = self.tableView.indexPathsForSelectedRows;
        
        if (!idxs) {
            [super setEditing:editing animated:YES & animated];
        }else{
            [super setEditing:editing animated:NO];
            
            NSMutableArray *objs = [NSMutableArray array];
            
            for (NSIndexPath *idx in idxs) {
                NSObject *obj = [self.objects objectAtIndex:idx.row];
                [objs addObject:obj];
            }
            [self.objects removeObjectsInArray:objs];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:idxs withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView endUpdates];
        }
        self.tableView.allowsMultipleSelectionDuringEditing = NO;
    }else{
        self.tableView.allowsMultipleSelectionDuringEditing = YES;
        [super setEditing:editing animated:animated];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *actions = [self tableView:tableView editActionsForRowAtIndexPath:indexPath];
    NSArray *titles  = [actions valueForKeyPath:@"title"];
    return [titles componentsJoinedByString:@"拼接"];
}

//兼容 iOS8 和 之前版本；
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QLTableViewRowAction *action1 = [QLTableViewRowAction rowActionWithStyle:QLTableViewRowActionStyleDefault title:@"1取消" handler:^(QLTableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"%@",action.title);
        [self setEditing:NO animated:NO];
    }];
    
    QLTableViewRowAction *action2 = [QLTableViewRowAction rowActionWithStyle:QLTableViewRowActionStyleNormal title:@"2删除" handler:^(QLTableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"%@",action.title);
        
        NSObject *obj = [self.objects objectAtIndex:indexPath.row];
        [self.objects removeObject:obj];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [tableView endUpdates];
    }];
    
    QLTableViewRowAction *action3 = [QLTableViewRowAction rowActionWithStyle:QLTableViewRowActionStyleNormal title:@"3置顶" handler:^(QLTableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"%@",action.title);
        NSObject *obj = [self.objects objectAtIndex:indexPath.row];
        [self.objects removeObjectAtIndex:indexPath.row];
        [self.objects insertObject:obj atIndex:0];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [tableView endUpdates];
    }];
    
    QLTableViewRowAction *action4 = [QLTableViewRowAction rowActionWithStyle:QLTableViewRowActionStyleNormal title:@"4没实现" handler:^(QLTableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"%@",action.title);
    }];
    
    NSArray *bgColors = @[[UIColor colorWithRed:255.0f/255.0f green:156.0f/255.0f blue:3.0f/255.0f alpha:1.0],
                          [UIColor colorWithRed:255.0f/255.0f green:128.0f/255.0f blue:1.0f/255.0f alpha:1.0]];
    
    action3.backgroundColor = bgColors[0];
    action4.backgroundColor = bgColors[1];
    if (indexPath.row == 0) {
        return @[action1];
    }else if (indexPath.row == 1){
        return @[action1,action2];
    }else if (indexPath.row == 2){
        return @[action1,action2,action3];
    }
    
    return @[action1,action2,action3,action4];
}

@end