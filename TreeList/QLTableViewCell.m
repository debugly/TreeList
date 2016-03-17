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

//处理 iOS8 之前的侧滑按钮
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    BOOL iOS8Before = ([[[UIDevice currentDevice]systemVersion]compare:@"8" options:NSNumericSearch] == NSOrderedAscending);
    
    if (iOS8Before && (NSNotFound != [NSStringFromClass([view class]) rangeOfString:@"TableViewCellDeleteConfirmationView"].location)) {
        
        [[view subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
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
            [view addSubview:btn];
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
    [super insertSubview:view atIndex:index];
}

@end
