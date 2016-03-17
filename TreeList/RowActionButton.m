//
//  RowActionButton.m
//  TreeList
//
//  Created by qianlongxu on 16/3/15.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import "RowActionButton.h"
#import "QLTableViewRowActionInternal.h"

@interface RowActionButton ()

@property (nonatomic, strong ,readwrite) QLTableViewRowAction *rowAction;

@end

@implementation RowActionButton

+ (instancetype)buttonWithRowAction:(QLTableViewRowAction *)rowAction
{
    RowActionButton *btn = [self buttonWithType:UIButtonTypeCustom];
    btn.rowAction = rowAction;
    [btn setTitle:rowAction.title forState:UIControlStateNormal];
    [btn setTitle:rowAction.title forState:UIControlStateHighlighted];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [btn setBackgroundColor:rowAction.backgroundColor];

    [btn addTarget:btn action:@selector(clickedAction) forControlEvents:UIControlEventTouchUpInside];
    
    [rowAction addObserver:btn forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [rowAction addObserver:btn forKeyPath:@"backgroundColor" options:NSKeyValueObservingOptionNew context:nil];
    
    return btn;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([@"title" isEqualToString:keyPath]) {
        NSString *title = [change objectForKey:NSKeyValueChangeNewKey];
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitle:title forState:UIControlStateHighlighted];
    }else if ([@"backgroundColor" isEqualToString:keyPath]){
        UIColor *bgc = [change objectForKey:NSKeyValueChangeNewKey];
        [self setBackgroundColor:bgc];
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc
{
    [self.rowAction removeObserver:self forKeyPath:@"title"];
    [self.rowAction removeObserver:self forKeyPath:@"backgroundColor"];
}

- (void)clickedAction
{
    if (self.rowAction && self.rowAction.RowActionHanler) {
        
        UITableViewCell *cell = (id)self;
        while (![cell isKindOfClass:[UITableViewCell class]]) {
            cell = (id)[cell superview];
        }
        
        UITableView *tb = (id)cell;
        while (![tb isKindOfClass:[UITableView class]]) {
            tb = (id)[tb superview];
        }
        NSIndexPath *idx = [tb indexPathForCell:cell];

        self.rowAction.RowActionHanler(self.rowAction,idx);
    }
}

@end
