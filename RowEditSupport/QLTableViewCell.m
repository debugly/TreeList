//
//  QLTableViewCell.m
//  TreeList
//
//  Created by qianlongxu on 16/3/15.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import "QLTableViewCell.h"
#import "RowActionButton.h"

@implementation QLTableViewCell

- (BOOL)iOS8Before
{
    __block BOOL iOS8Before = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iOS8Before = ([[[UIDevice currentDevice]systemVersion]compare:@"8" options:NSNumericSearch] == NSOrderedAscending);
    });
    return iOS8Before;
}

/*处理iOS8之前的cell；
 UITableViewCell
 UITableViewCellScrollView
 UITableViewCellDeleteConfirmationView
 UITableViewCellContentView
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([self iOS8Before]){
        return;
    }
    
    NSArray *subviews = [self subviews];
    UIView *scrollView = nil;
    for (UIView *v in subviews) {
        if (NSNotFound != [NSStringFromClass([v class]) rangeOfString:@"TableViewCellScrollView"].location){
            scrollView = v;
            break;
        }
    }
    
    if (!scrollView) {
        return;
    }
    subviews = [scrollView subviews];
    UIView *confirmView = nil;
    for (UIView *v in subviews) {
        if (NSNotFound != [NSStringFromClass([v class]) rangeOfString:@"TableViewCellDeleteConfirmationView"].location){
            confirmView = v;
            break;
        }
    }
    
    if (!confirmView) {
        return;
    }
    
    [[confirmView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UITableView *tb = (id)self;
    while (![tb isKindOfClass:[UITableView class]]) {
        tb = (id)[tb superview];
    }
    
    NSIndexPath *idx = [tb indexPathForCell:self];
    NSArray *actions = [tb.delegate tableView:tb editActionsForRowAtIndexPath:idx];
    
    NSMutableArray *btns = [[NSMutableArray alloc]init];
    [actions enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(QLTableViewRowAction *action, NSUInteger idx, BOOL * _Nonnull stop) {
        RowActionButton *btn = [RowActionButton buttonWithRowAction:action];
        [btn sizeToFit];
        [confirmView addSubview:btn];
        [btns addObject:btn];
    }];
    
    CGFloat lastX = 0;
    CGFloat detalW = 0;
    if (btns.count == 1) {
        detalW = 30;
    }else if (btns.count == 2){
        detalW = 33;
    }else if (btns.count == 3){
        detalW = 34;
    }else{
        detalW = 35;
    }
    CGFloat height = self.bounds.size.height;
    
    for (RowActionButton *btn in btns) {
        CGRect rect = btn.frame;
        rect.origin.x = lastX;
        rect.origin.y = 0;
        rect.size.width += detalW;
        rect.size.height = height;
        lastX += rect.size.width;
        btn.frame = rect;
    }
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    if (![self iOS8Before]) {
        if (NSNotFound != [NSStringFromClass([view class]) rangeOfString:@"TableViewCellDeleteConfirmationView"].location){
            //iOS 8.3 display 1px bg is red；
            view.backgroundColor = self.backgroundColor;
        }
    }
    [super insertSubview:view atIndex:index];
}

@end
