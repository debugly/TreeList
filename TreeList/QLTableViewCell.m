//
//  QLTableViewCell.m
//  TreeList
//
//  Created by qianlongxu on 16/3/15.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import "QLTableViewCell.h"
#import "RowActionButton.h"

@interface QLTableViewCell ()

@property (nonatomic, copy) NSArray *(^editActionsBlock)(QLTableViewCell *cell);

@end

@implementation QLTableViewCell

- (void)editActions:(NSArray *(^)(QLTableViewCell *))aBlcok
{
    self.editActionsBlock = aBlcok;
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    if (self.editActionsBlock && (NSNotFound != [NSStringFromClass([view class]) rangeOfString:@"TableViewCellDeleteConfirmationView"].location)) {
        
        [[view subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        NSArray *actions = self.editActionsBlock(self);
        NSMutableArray *btns = [[NSMutableArray alloc]init];
        for (int i = 0; i < actions.count; i ++) {
            QLTableViewRowAction *action = actions[i];
            RowActionButton *btn = [RowActionButton buttonWithRowAction:action];
            [btn sizeToFit];
            [view addSubview:btn];
            [btns addObject:btn];
        }
        
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
