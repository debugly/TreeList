//
//  MutableSelectViewController.m
//  TreeList
//
//  Created by qianlongxu on 16/3/18.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import "MutableSelectViewController.h"

@interface MutableSelectViewController ()

@property (nonatomic, strong) NSMutableArray *objects;

@end

@implementation MutableSelectViewController

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
        [self.objects addObject:[NSDate date]];
    }
  
//正常情况下的选择，不影响编辑状态！
    /*
     是否允许选中；不会影响 allowsMultipleSelection；即使这个为NO，也可以多选！
     */
    self.tableView.allowsSelection = NO;
    
    /*
     是否允许正常情况下多选；允许时，可通过这个属性获取选择的cell；
     tableView.indexPathsForSelectedRows
     */
    self.tableView.allowsMultipleSelection = NO;
 
//编辑情况下的选择，不影响正常状态！
    /*
     编辑的时候是否允许单选选中，允许时点击cell会触发：didSelectRowAtIndexPath 代理方法；
     仅仅在这3种模式下生效：
     UITableViewCellEditingStyleNone,
     UITableViewCellEditingStyleDelete,
     UITableViewCellEditingStyleInsert
     
     如果使用 UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert；则没用，因为这属于多选！
     */
    self.tableView.allowsSelectionDuringEditing = YES;
    
    /*
     这个属性意味着要不要开启多选！开启多选后，点击编辑完成处理选中的cell！
     如果开启，就会忽略 editingStyleForRowAtIndexPath 代理方法；
     不开启，就会去调用这个代理方法；
     PS：还有一种开启多选的方法就是在 editingStyleForRowAtIndexPath 代理方法里返回 UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert；不过 allowsMultipleSelectionDuringEditing 还是 NO，不会变为YES！
     */
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    /**
     *  侧滑是编辑的另一种形式，出现侧滑删除的条件：
         1. canEditRowAtIndexPath 为 YES；
         2. editingStyleForRowAtIndexPath 返回 UITableViewCellEditingStyleDelete；
         3. 实现 commitEditingStyle 方法；
     *
     */
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDate *date = self.objects[indexPath.row];
    cell.textLabel.text = [date description];
    return cell;
}

/*
 
//默认是 UITableViewCellEditingStyleDelete；
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

//默认是YES
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

*/

//删除，插入，侧滑都会调用此方法；iOS8侧滑除外！多选不会触发这个方法！
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

//重写这个方法，处理多选处理！
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    NSLog(@"---%d",self.tableView.allowsMultipleSelectionDuringEditing);
}

- (void)printfIndexPath:(NSIndexPath *)idx optPrefix:(NSString *)prefix
{
    NSLog(@"%@idx<%p>:%ld-%ld",prefix?prefix:@"",idx,(long)idx.section,(long)idx.row);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self printfIndexPath:indexPath optPrefix:@"当次选择："];
    [self printfIndexPath:tableView.indexPathForSelectedRow optPrefix:@"SelectedRow："];
    for (NSIndexPath *idx in tableView.indexPathsForSelectedRows) {
        [self printfIndexPath:idx optPrefix:@"SelectedRows:"];
    }
}

@end
