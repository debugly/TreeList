//
//  UIButton+rowAction.m
//  TreeList
//
//  Created by xuqianlong on 16/4/17.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import "UIButton+rowAction.h"
#import "QLTableViewRowActionInternal.h"
#import "QLVersionUtil.h"
#import "objc/runtime.h"

@implementation UIButton (rowAction)

- (void)setRowAction:(QLTableViewRowAction *)rowAction
{
    SEL s = NSSelectorFromString(@"rowAction");
    objc_setAssociatedObject(self, s, rowAction, OBJC_ASSOCIATION_RETAIN);
}

- (QLTableViewRowAction *)rowAction
{
    return objc_getAssociatedObject(self, _cmd);
}

+ (instancetype)buttonWithRowAction:(QLTableViewRowAction *)rowAction
{
    UIButton *btn = [self buttonWithType:UIButtonTypeCustom];
    [btn updateRowAction:rowAction];
    
    [btn setTitle:rowAction.title forState:UIControlStateNormal];
    [btn setTitle:rowAction.title forState:UIControlStateHighlighted];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:[QLVersionUtil iOS6]?14:18]];
    [btn setBackgroundColor:rowAction.backgroundColor];
    
    // Set 'more' button's numberOfLines to 0 to enable support for multiline titles.
    btn.titleLabel.numberOfLines = 0;
    
    // Set clipsToBounds to YES is necessary because otherwise it wouldn't be possible
    // to hide it settings it's frame's width to zero (the title would appear anyway).
    btn.clipsToBounds = YES;
    return btn;
}

- (void)updateRowAction:(QLTableViewRowAction *)rowAction
{
    [self removeObservers];
    self.rowAction = rowAction;
    [self addTarget:self action:@selector(clickedAction) forControlEvents:UIControlEventTouchUpInside];
    
    [rowAction addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [rowAction addObserver:self forKeyPath:@"backgroundColor" options:NSKeyValueObservingOptionNew context:nil];

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

- (void)removeObservers
{
    @try {
        [self.rowAction removeObserver:self forKeyPath:@"title"];
        [self.rowAction removeObserver:self forKeyPath:@"backgroundColor"];
    } @catch (NSException *exception) {
        
    }
}

- (void)dealloc
{
    [self removeObservers];
}

- (UITableViewCell *)cell {
    UIView *cell = self.superview;
    while(cell) {
        if(![cell isKindOfClass:[UITableViewCell class]]) {
            cell = cell.superview;
        }
        else {
            return (UITableViewCell *)cell;
        }
    }
    return nil;
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
    
    UITableViewCell *cell = [self cell];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([cell respondsToSelector:@selector(hideDeleteConfirmation)]) {
        [cell performSelector:@selector(hideDeleteConfirmation)];
    }
#pragma clang diagnostic pop
}

@end
