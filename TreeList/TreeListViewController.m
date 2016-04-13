//
//  TreeListViewController.m
//  TreeList
//
//  Created by qianlongxu on 16/3/18.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import "TreeListViewController.h"
#import "TreeModel.h"
#import "DetailViewController.h"

@interface TreeListViewController ()

@property (nonatomic, strong) NSMutableArray *objects;

@end

@implementation TreeListViewController

- (NSMutableArray *)objects
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc]init];
    }
    return _objects;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    if(self.objects.count < 1){
        int random = arc4random() % 6 + 1;
        while (random--) {
            TreeModel *root = [[TreeModel alloc]initWithLeval:0];
            root.date = [NSDate date];
            [self.objects addObject:root];
        }
        [self.tableView reloadData];
    }
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
    TreeModel *model = self.objects[indexPath.row];
    cell.indentationLevel = model.leval;
    cell.indentationWidth = 10 * cell.indentationLevel;
    cell.detailTextLabel.text = [model.date description];
    cell.textLabel.text = [NSString stringWithFormat:@"I'm Leval:%ld",(long)model.leval];
    return cell;
}

- (TreeModel *)model4IndexPath:(NSIndexPath *)idx
{
    return  (self.objects.count > idx.row) ? self.objects[idx.row] : nil;
}


- (void)showDetailViewController:(TreeModel *)model
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *detailViewController = [sb instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailViewController.detailItem = model;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TreeModel *model = [self model4IndexPath:indexPath];
    if (!model.isOpened) {
        if (model.leval < 5) {
            NSArray *arr = [self prepareData4Leval:model.leval idx:indexPath];
            NSIndexSet *idxSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row + 1, arr.count)];
            [self.objects insertObjects:arr atIndexes:idxSet];
            
            NSMutableArray *idxArr = [NSMutableArray array];
            NSInteger i = 0;
            while (i < arr.count) {
                i ++;
                [idxArr addObject:[NSIndexPath indexPathForRow:indexPath.row + i inSection:indexPath.section]];
            }
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:idxArr withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            [model setOpened:YES];
        }else{
            //show detail;
            [self showDetailViewController:model];
        }
    }else{
        //关闭
        [model setOpened:NO];
        NSMutableArray *tmpArr = [NSMutableArray array];
        NSMutableArray *idxArr = [NSMutableArray array];
        
        for (NSInteger i = [self.objects indexOfObject:model] + 1; i < self.objects.count; i ++) {
            TreeModel *m = self.objects[i];
            
            if (m.leval <= model.leval) {
                break;
            }else{
                [tmpArr addObject:m];
                [idxArr addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
            }
        }
        
        [self.objects removeObjectsInArray:tmpArr];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:idxArr withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (NSArray *)prepareData4Leval:(NSInteger)leval idx:(NSIndexPath *)idx
{
    int random = arc4random() % 20 + 1;
    NSMutableArray *arr = [NSMutableArray array];
    while (random--) {
        TreeModel *model = [[TreeModel alloc]initWithLeval:leval + 1];
        model.date = [NSDate date];
        [arr addObject:model];
    }
    return [arr copy];
}

@end
