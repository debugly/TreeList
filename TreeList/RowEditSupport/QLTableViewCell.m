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

@property (nonatomic, strong) UIButton *moreOptionButton;
@property (nonatomic, strong) UIScrollView *cellScrollView;
@end

@implementation QLTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _moreOptionButton = nil;
        _cellScrollView = nil;
        if ([QLVersionUtil iOS7]) {
            [self setupObserving];
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _moreOptionButton = nil;
        _cellScrollView = nil;
        if ([QLVersionUtil iOS7]) {
            [self setupObserving];
        }
    }
    return self;
}


- (void)dealloc {
    [self.cellScrollView.layer removeObserver:self forKeyPath:@"sublayers" context:nil];
}

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

- (CGFloat)configureRowActionButtons:(UIView *)superview
{
    UITableView *tb = (id)self;
    while (![tb isKindOfClass:[UITableView class]]) {
        tb = (id)[tb superview];
    }
    
    NSIndexPath *idx = [tb indexPathForCell:self];
    NSArray *actions = [tb.delegate tableView:tb editActionsForRowAtIndexPath:idx];
    
    CGFloat startX = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    for (QLTableViewRowAction *action in actions) {
        QLRowActionButton *btn = [QLRowActionButton buttonWithRowAction:action];
        [btn sizeToFit];
        [superview addSubview:btn];
        CGRect rect = btn.frame;
        rect.origin.y = 0;
        rect.size.width += 15;
        rect.size.height = height;
        rect.origin.x = (startX -= rect.size.width);
        btn.frame = rect;
    }
    return startX;
}

- (void)handleiOS6:(UIView *)confirmView
{
    if([NSStringFromClass([confirmView class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]){
        
        [self updateConfirmView:confirmView];
        CGRect rect = confirmView.frame;
        
        UIView *v = [UIView new];
        v.frame = self.bounds;
        [super addSubview:v];
        self.swipBgView = v;
        
        CGFloat startX = [self configureRowActionButtons:v];
        self.swipWidth = v.frame.size.width - startX;
        rect.origin.x = self.swipWidth;
        rect.size.width = self.swipWidth;
        confirmView.frame = rect;
        
        return;
    }
}

- (void)setupObserving {
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.delegate isKindOfClass:[UIScrollView class]]) {
            _cellScrollView = (UIScrollView *)layer.delegate;
            [_cellScrollView.layer addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionNew context:nil];
            break;
        }
    }
}

- (void)willRemoveSubview:(UIView *)subview {
    [super willRemoveSubview:subview];
    if ([QLVersionUtil iOS7]) {
        // Set the 'more' button to nil if the 'swipe to delete' container view won't be visible anymore.
        NSString *className = NSStringFromClass(subview.class);
        if ([className hasPrefix:@"UI"] && [className hasSuffix:@"ConfirmationView"]) {
            self.moreOptionButton = nil;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"sublayers"]) {
        /*
         * Using '==' instead of 'isEqual:' to compare the observed object and the cell's contentScrollView's layer
         * (for iOS 7) OR the cell's layer (for iOS 8) because it must be the same instance and not an equal one.
         */
        if (object == self.cellScrollView.layer || object == self.layer) {
            BOOL swipeToDeleteControlVisible = NO;
            for (CALayer *layer in [(CALayer *)object sublayers]) {
                /*
                 * Check if the view is the 'swipe to delete' container view.
                 */
                NSString *name = NSStringFromClass([layer.delegate class]);
                if ([name hasPrefix:@"UI"] && [name hasSuffix:@"ConfirmationView"]) {
                    
                    swipeToDeleteControlVisible = YES;
                    
                    if (!self.moreOptionButton) {
                        
                        UIView *deleteConfirmationView = layer.delegate;
                        UIButton *deleteConfirmationButton = nil;
                        
                        for (UIView *subview in deleteConfirmationView.subviews) {
                            NSString *subviewClass = NSStringFromClass([subview class]);
                            if ([subviewClass hasPrefix:@"UI"] &&
                                [subviewClass rangeOfString:@"Delete"].length > 0 &&
                                [subviewClass hasSuffix:@"Button"]) {
                                
                                deleteConfirmationButton = (UIButton *)subview;
                                break;
                            }
                        }
                        
                        [self configureMoreOptionButtonForDeleteConfirmationView:deleteConfirmationView
                                                    withDeleteConfirmationButton:deleteConfirmationButton];
                    }
                }
            }
            // Set the 'more' button to nil if the 'swipe to delete' container view isn't visible anymore.
            if (!swipeToDeleteControlVisible) {
                self.moreOptionButton = nil;
            }
        }
    }
}

- (UITableView *)tableView {
    UIView *tableView = self.superview;
    while(tableView) {
        if(![tableView isKindOfClass:[UITableView class]]) {
            tableView = tableView.superview;
        }
        else {
            return (UITableView *)tableView;
        }
    }
    return nil;
}


- (void)configureMoreOptionButtonForDeleteConfirmationView:(UIView *)deleteConfirmationView
                              withDeleteConfirmationButton:(UIButton *)deleteConfirmationButton {
    
    /*
     * 'Normalize' 'UITableViewCellDeleteConfirmationView's' title text implementation, because
     * under iOS 7 UIKit itself doesn't show the text using it's 'UIButtonLabel's' setTitle: but
     * using a seperate 'UILabel'.
     *
     * WHY Apple, WHY?
     *
     */
    
    if (![QLVersionUtil iOS6]) {
        [deleteConfirmationButton.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            if ([view class] == [UILabel class]) {
                UILabel *titleLabel = (UILabel *)view;
                NSString *deleteConfirmationButtonTitle = titleLabel.text;
                [titleLabel removeFromSuperview];
                titleLabel = nil;
                
                [deleteConfirmationButton setTitle:deleteConfirmationButtonTitle forState:UIControlStateNormal];
                
                // Needed because otherwise the sizing algorithm wouldn't work for iOS 7
                deleteConfirmationButton.autoresizingMask = UIViewAutoresizingNone;
                
                *stop = YES;
            }
        }];
        // Set default titleEdgeInsets on 'delete' button
        [deleteConfirmationButton setTitleEdgeInsets:UIEdgeInsetsMake(0.f, 15.f, 0.f, 15.f)];
        // Set clipsToBounds to YES on 'delete' button is necessary because otherwise it wouldn't
        // be possible to hide it settings it's frame's width to zero (the title would appear anyway).
        deleteConfirmationButton.clipsToBounds = YES;
        
    }
    
    
    [self.moreOptionButton setTitle:@"取消自动删除" forState:UIControlStateNormal];
    
    // If created add the 'more' button to the cell's view hierarchy
    if (self.moreOptionButton) {
        [deleteConfirmationView addSubview:self.moreOptionButton];
    }
    
}


@end
