//
//  QLTableViewCell.m
//  TreeList
//
//  Created by qianlongxu on 16/3/15.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import "QLTableViewCell.h"
#import "QLRowActionButton.h"
#import "QLVersionUtil.h"

@interface QLTableViewCell ()
{
    CGFloat swipWidth;
}

@property (nonatomic, weak) UIView *swipBgView;
@property (nonatomic, weak) UIView *confirmView;

@end

@implementation QLTableViewCell

/*处理iOS7的cell；
 UITableViewCell
 UITableViewCellScrollView
 UITableViewCellDeleteConfirmationView
 UITableViewCellContentView

处理iOS6的cell；
UITableViewCell
UITableViewCellContentView
UIView(sep line)
UITableViewCellDeleteConfirmationControl
*/

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    
    if ([QLVersionUtil iOS6]) {
        if (UITableViewCellStateDefaultMask == state) {
            if (self.swipBgView) {
                CGRect desRect = self.confirmView.frame;
                desRect.origin.x += swipWidth;
                
                [UIView animateWithDuration:0.25 animations:^{
                    self.confirmView.frame = desRect;
                }completion:^(BOOL finished) {
                    [self.swipBgView removeFromSuperview];
                }];
            }
        }else if (UITableViewCellStateShowingDeleteConfirmationMask == state){
            
            CGRect rect = self.confirmView.frame;
            CGRect desRect = rect;
            rect.origin.x += swipWidth;
            self.confirmView.frame = rect;
            
            [UIView animateWithDuration:0.25 animations:^{
                self.confirmView.frame = desRect;
            }];
        }
    }
}

- (void)addSubview:(UIView *)confirmView
{
    [super addSubview:confirmView];
    
    if(self.confirmView){
        return;
    }else if ([QLVersionUtil iOS7]) {
        [self handleiOS7];
    }else if([QLVersionUtil iOS6]){
        [self handleiOS6:confirmView];
    }
}

- (void)handleiOS6:(UIView *)confirmView
{
    if([NSStringFromClass([confirmView class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]){
        
        [[confirmView subviews] makeObjectsPerformSelector:@selector(setHidden:)withObject:@(YES)];
        
        self.confirmView = confirmView;
        
        UIView *v = [UIView new];
        v.frame = self.bounds;
        
        UITableView *tb = (id)self;
        while (![tb isKindOfClass:[UITableView class]]) {
            tb = (id)[tb superview];
        }
        
        NSIndexPath *idx = [tb indexPathForCell:self];
        NSArray *actions = [tb.delegate tableView:tb editActionsForRowAtIndexPath:idx];
        
        NSMutableArray *btns = [[NSMutableArray alloc]init];
        [actions enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(QLTableViewRowAction *action, NSUInteger idx, BOOL * _Nonnull stop) {
            QLRowActionButton *btn = [QLRowActionButton buttonWithRowAction:action];
            [btn sizeToFit];
            [v addSubview:btn];
            [btns addObject:btn];
        }];
        
        CGFloat detalW = 0;
        
        if (btns.count == 2){
            detalW = 30;
        }else if (btns.count == 3){
            detalW = 32;
        }else{
            detalW = 33;
        }
        
        CGFloat maxX = self.bounds.size.width;
        CGFloat height = self.bounds.size.height;
        
        for (UIView *btn in btns) {
            CGRect rect = btn.frame;
            rect.origin.y = 0;
            rect.size.width += detalW;
            rect.size.height = height;
            rect.origin.x = maxX - rect.size.width;
            maxX -= rect.size.width;
            btn.frame = rect;
        }
        swipWidth = v.frame.size.width - maxX;
        [super addSubview:v];
        self.swipBgView = v;
        return;
    }
}

- (void)handleiOS7
{
    NSArray *subviews = [self subviews];
    UIView *confirmView = nil;
    
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
    
    for (UIView *v in subviews) {
        if (NSNotFound != [NSStringFromClass([v class]) rangeOfString:@"TableViewCellDeleteConfirmationView"].location){
            confirmView = v;
            break;
        }
    }
    
    if (!confirmView) {
        return;
    }
    
    self.confirmView = confirmView;
    
    [[confirmView subviews] makeObjectsPerformSelector:@selector(setHidden:) withObject:@(YES)];
    
    UITableView *tb = (id)self;
    while (![tb isKindOfClass:[UITableView class]]) {
        tb = (id)[tb superview];
    }
    
    NSIndexPath *idx = [tb indexPathForCell:self];
    NSArray *actions = [tb.delegate tableView:tb editActionsForRowAtIndexPath:idx];
    
    NSMutableArray *btns = [[NSMutableArray alloc]init];
    [actions enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(QLTableViewRowAction *action, NSUInteger idx, BOOL * _Nonnull stop) {
        QLRowActionButton *btn = [QLRowActionButton buttonWithRowAction:action];
        [btn sizeToFit];
        [confirmView addSubview:btn];
        [btns addObject:btn];
    }];
    
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
    
    CGFloat lastX = 0;
    CGFloat height = self.bounds.size.height;
    
    for (UIView *btn in btns) {
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
    if ([QLVersionUtil iOS8Later]) {
        if (NSNotFound != [NSStringFromClass([view class]) rangeOfString:@"TableViewCellDeleteConfirmationView"].location){
            //iOS 8.3 display 1px bg is red；
            view.backgroundColor = self.backgroundColor;
        }
    }
    [super insertSubview:view atIndex:index];
}

@end
