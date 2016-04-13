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

@property (nonatomic, weak) UIView *swipBgView;//用于iOS6上做动画
@property (nonatomic, weak) UIView *confirmView;//
@property (nonatomic, assign)CGFloat swipWidth;

@end

@implementation QLTableViewCell

/*iOS7 cell 层级结构：
 UITableViewCell
 UITableViewCellScrollView
 UITableViewCellDeleteConfirmationView
 UITableViewCellContentView

iOS6 cell 层级结构：
UITableViewCell
UITableViewCellContentView
UIView(sep line)
UITableViewCellDeleteConfirmationControl
 
 因此分别处理！
*/

//处理 iOS6 上的动画！
- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    
    if ([QLVersionUtil iOS6]) {
        if (UITableViewCellStateDefaultMask == state) {
            if (self.swipBgView) {
                CGRect desRect = self.confirmView.frame;
                desRect.origin.x += self.swipWidth;
                
                [UIView animateWithDuration:0.25 animations:^{
                    self.confirmView.frame = desRect;
                }completion:^(BOOL finished) {
                    [self.swipBgView removeFromSuperview];
                }];
            }
        }else if (UITableViewCellStateShowingDeleteConfirmationMask == state){
            if (self.confirmView) {
                CGRect rect = self.confirmView.frame;
                CGRect desRect = rect;
                rect.origin.x += self.swipWidth;
                self.confirmView.frame = rect;
                
                [UIView animateWithDuration:0.25 animations:^{
                    self.confirmView.frame = desRect;
                }];
            }
        }
    }
}

//该方法为突破口，处理侧滑view；
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
//处理iOS 8 问题；
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

#pragma mark - private methods

- (void)updateConfirmView:(UIView *)confirmView
{
    [[confirmView subviews] makeObjectsPerformSelector:@selector(setHidden:)withObject:@(YES)];
    self.confirmView = confirmView;
}

- (CGFloat)configureRowActionButtons:(UIView *)superview detal:(CGFloat (^)(NSUInteger count))detalBlock
{
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
        [superview addSubview:btn];
        [btns addObject:btn];
    }];
    
    CGFloat detalW = detalBlock(btns.count);
    CGFloat maxX = superview.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    for (UIView *btn in btns) {
        CGRect rect = btn.frame;
        rect.origin.y = 0;
        rect.size.width += detalW;
        rect.size.height = height;
        rect.origin.x = (maxX -= rect.size.width);
        btn.frame = rect;
    }
    
    return maxX;
}

- (void)handleiOS6:(UIView *)confirmView
{
    if([NSStringFromClass([confirmView class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]){
        
        [self updateConfirmView:confirmView];
        
        UIView *v = [UIView new];
        v.frame = self.bounds;
        [super addSubview:v];
        self.swipBgView = v;
        
        CGFloat startX = [self configureRowActionButtons:v detal:^CGFloat(NSUInteger count) {
            CGFloat detalW = 0;
            if (count == 2){
                detalW = 30;
            }else if (count == 3){
                detalW = 32;
            }else{
                detalW = 33;
            }
            return detalW;
        }];
        self.swipWidth = v.frame.size.width - startX;
        
        return;
    }
}

- (void)handleiOS7
{
    NSArray *subviews = [self subviews];
    UIView *confirmView = nil;
    
    UIView *scrollView = nil;
    for (UIView *v in subviews){
        if (NSNotFound != [NSStringFromClass([v class]) rangeOfString:@"TableViewCellScrollView"].location){
            scrollView = v;
            break;
        }
    }
    
    if (!scrollView){
        return;
    }
    
    subviews = [scrollView subviews];
    
    for (UIView *v in subviews) {
        if (NSNotFound != [NSStringFromClass([v class]) rangeOfString:@"TableViewCellDeleteConfirmationView"].location){
            confirmView = v;
            break;
        }
    }
    
    if (!confirmView){
        return;
    }
    
    [self updateConfirmView:confirmView];
    
    [self configureRowActionButtons:confirmView detal:^CGFloat(NSUInteger count) {
        CGFloat detalW = 0;
        if (count == 1) {
            detalW = 30;
        }else if (count == 2){
            detalW = 33;
        }else if (count == 3){
            detalW = 34;
        }else{
            detalW = 35;
        }
        return detalW;
    }];
}

@end
