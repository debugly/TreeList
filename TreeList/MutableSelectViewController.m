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

///自定义编辑按钮！
- (UIBarButtonItem *)editButtonItem
{
    //根据当前的编辑状态返回标题
    BOOL isEdit = self.isEditing;
    NSString *title = isEdit ? @"完成" : @"编辑";
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(clickedEditingItem:)];
    return item;
}

- (void)clickedEditingItem:(UIBarButtonItem *)editItem
{
    //与当前相反！
    [self setEditing:!self.editing animated:YES];
}

- (void)updateEditBarButtonItem
{
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)prefareHeaderView
{
    UIView *bg = [[UIView alloc]init];
    self.tableView.backgroundView = bg;
    
    UILabel *trip = [[UILabel alloc]init];
    trip.text = @"完全使用 iOS8 前的API，所以侧滑只能展示一个按钮；\n你可以修改他的 Title；\nDemo实现了自定义编辑按钮，支持多选和侧滑删除！";
    trip.numberOfLines = 0;
    trip.textAlignment = NSTextAlignmentLeft;
    trip.font = [UIFont systemFontOfSize:16];
    trip.textColor = [UIColor orangeColor];
    
    CGSize tripSize = [trip sizeThatFits:CGSizeMake(self.view.bounds.size.width - 30, CGFLOAT_MAX)];
    trip.frame = CGRectMake(15, 68, tripSize.width, tripSize.height);
    
    [self.tableView.backgroundView addSubview:trip];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateEditBarButtonItem];
    
    int random = arc4random() % 200 + 15;
    int i = 0;
    while (random--) {
        [self.objects addObject:@(i++)];
    }
  
    [self prefareHeaderView];
    
//正常情况下的选择，不影响编辑状态！
    /*
     是否允许选中；不会影响 allowsMultipleSelection；即使这个为NO，也可以多选！
     */
    self.tableView.allowsSelection = YES;
    
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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"row:%ld",indexPath.row];
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

//删除，插入，侧滑都会调用此方法；iOS8形式的侧滑除外！多选不会触发这个方法！
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete == editingStyle) {
        [self doDeleteRows:@[indexPath]];
    }
}

//修改默认红色标题！
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"移至废纸篓";
}

//重写这个方法，处理多选处理！侧滑删除完也会调用这个，不过 indexPathsForSelectedRows = nil;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    NSLog(@"---%d",self.tableView.allowsMultipleSelectionDuringEditing);
    
    //结束编辑;
    if (!editing) {
        //获取选择行的indexpath；
        NSArray *selectedRows = self.tableView.indexPathsForSelectedRows;
        [self doDeleteRows:selectedRows];
    }
    //先处理业务，然后再调用super，因为调用super会清空 indexPathsForSelectedRows ！！！
    [super setEditing:editing animated:animated];
    //更新下；
    [self updateEditBarButtonItem];
}

- (void)printfIndexPath:(NSIndexPath *)idx optPrefix:(NSString *)prefix
{
    NSLog(@"%@idx<%p>:%ld-%ld",prefix?prefix:@"",idx,(long)idx.section,(long)idx.row);
}

///编辑态、正常态 点击选择均会回调哦！
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.isEditing){
        [self printfIndexPath:indexPath optPrefix:@"当次选择："];
        [self printfIndexPath:tableView.indexPathForSelectedRow optPrefix:@"SelectedRow："];
        for (NSIndexPath *idx in tableView.indexPathsForSelectedRows) {
            [self printfIndexPath:idx optPrefix:@"SelectedRows:"];
        }
    }else{
        ///自动取消选择
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - 删除业务
- (void)doDeleteRows:(NSArray *)selectedRows
{
    if (!selectedRows || selectedRows.count < 1) {
        return;
    }
    //因为我只有一个区，因此我可以偷懒（^_^）,直接获取row数组；对应的就是数组的下标！
    NSArray *selectedIdx = [selectedRows valueForKeyPath:@"self.row"];
    //很多人没用过这个方法，将arr转为indexset的；
    NSIndexSet *indexset = [selectedIdx indexesOfObjectsPassingTest:^BOOL(NSNumber * obj, NSUInteger idx, BOOL * stop) {
        return YES;
    }];
    
    //有选择就删除；这里可以根据自己的业务逻辑写；
    if (indexset && indexset.count > 0) {
        [self.objects removeObjectsAtIndexes:indexset];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }

}
@end
