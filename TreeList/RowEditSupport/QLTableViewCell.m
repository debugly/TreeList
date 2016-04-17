//
//  QLTableViewCell.m
//  TreeList
//
//  Created by qianlongxu on 16/3/15.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import "QLTableViewCell.h"
#import "UIButton+rowAction.h"
#import "QLVersionUtil.h"
#import "objc/message.h"

@interface QLTableViewCell ()

///iOS6
@property (nonatomic, weak) UIView *deleteConfirmView;
@property (nonatomic, assign)CGFloat swipWidth;

///iOS7
@property (nonatomic, assign) bool showedOptionButton;
@property (nonatomic, strong) UIScrollView *cellScrollView;

@end

@implementation QLTableViewCell

/*
 实现思路：
 
 iOS8 later: use system provide；
 ===============================
 
 iOS7 :改写在系统的，参考：MSCMoreOptionTableViewCell
 
 cell 层级结构：
 
 UITableViewCell
 UITableViewCellScrollView
 UITableViewCellDeleteConfirmationView
 UITableViewCellContentView
 ===============================
 
 iOS6 :自己添加侧滑 view 和手势
 
 cell 层级结构：
 
 UITableViewCell
 UITableViewCellContentView
 UIView(sep line)
 UITableViewCellDeleteConfirmationControl
 
 最终统一为rowaction回调处理点击！
 ===============================
 */

- (void)_commoninit
{
    _showedOptionButton = NO;
    _cellScrollView = nil;
    if ([QLVersionUtil iOS7]) {
        [self setupObserving];
    }else if ([QLVersionUtil iOS6]){
        //默认放到cell之外；
        UIView *deleteConfirmView = [[UIView alloc]initWithFrame:CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height)];
        deleteConfirmView.backgroundColor = self.backgroundColor;
        
        [self insertSubview:deleteConfirmView aboveSubview:self.contentView];
        self.deleteConfirmView = deleteConfirmView;
        //添加侧滑手势；
        UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiped:)];
        swip.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swip];
        
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _commoninit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commoninit];
    }
    return self;
}

#pragma mark - handle iOS6

- (void)swiped:(UISwipeGestureRecognizer *)sender
{
    //已经有侧滑的cell了，就把这个关闭了！
    bool finded = [self findSwipedCellAndClosed];
    
    if (finded) {
        return;
    }
    
    CGFloat width = [self configureiOS6MoreOptionButtonwithDeleteConfirmationView:self.deleteConfirmView];
    self.swipWidth = width;
    CGRect rect = self.contentView.frame;
    rect.origin.x = -width;
//    rect.size.width -= width; why？
    
    CGRect deleteConfirmViewRect = self.deleteConfirmView.frame;
    deleteConfirmViewRect.origin.x = self.bounds.size.width - width;
 
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.frame = rect;
        self.deleteConfirmView.frame = deleteConfirmViewRect;
    }];
}

//配置侧滑按钮，返回总宽度；
- (CGFloat)configureiOS6MoreOptionButtonwithDeleteConfirmationView:(UIView *)deleteConfirmationView {
    UITableView *tableView = [self tableView];
    NSIndexPath *indexPath = [tableView indexPathForCell:self];
    
    // Need to get the delegate as strong variable because it's a weak property
    id<UITableViewDelegate> strongDelegate = (id)tableView.delegate;
    if (strongDelegate) {
        
        NSArray *actions = [strongDelegate tableView:tableView editActionsForRowAtIndexPath:indexPath];
        
        if (actions.count > 0) {
            NSMutableArray *allButons = [[NSMutableArray alloc]init];
            for (int i = actions.count-1; i >= 0; i --) {
                QLTableViewRowAction *action = actions[i];
                
                UIButton *moreOptionButton = [UIButton buttonWithRowAction:action];
                [self configureButtonCommonProperteis:moreOptionButton rowAction:action];
                // add the 'more' button to the cell's view hierarchy
                [deleteConfirmationView addSubview:moreOptionButton];
                [allButons addObject:moreOptionButton];
            }
           
            // Size buttons as they would be displayed.
            CGFloat deleteConfirmationButtonHeight = self.frame.size.height;
            
            CGFloat lastX = 0;
            for (UIButton *btn in allButons) {
                // Size 'more' button
                CGRect moreButtonFrame = CGRectZero;
                moreButtonFrame.size = [btn intrinsicContentSize];
                moreButtonFrame.size.height = deleteConfirmationButtonHeight;
                moreButtonFrame.size.width += 30;
                moreButtonFrame.origin.x = lastX;
                // Fix 'delete' button's origin.x and set the frame
                lastX += moreButtonFrame.size.width;
                btn.frame = moreButtonFrame;
            }

            return lastX;
        }
    }
    return 0;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject(NSKeyValueObserving) | iOS 7 functionality
////////////////////////////////////////////////////////////////////////

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
                    
                    if (!_showedOptionButton) {
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
                _showedOptionButton = NO;
            }
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)willRemoveSubview:(UIView *)subview {
    [super willRemoveSubview:subview];
    
    // Set the 'more' button to nil if the 'swipe to delete' container view won't be visible anymore.
    NSString *className = NSStringFromClass(subview.class);
    if ([className hasPrefix:@"UI"] && [className hasSuffix:@"ConfirmationView"]) {
        _showedOptionButton = NO;
    }
}


////////////////////////////////////////////////////////////////////////
#pragma mark - MSCMoreOptionTableViewCell
////////////////////////////////////////////////////////////////////////

- (void)hideDeleteConfirmation {
    
    if([QLVersionUtil iOS7Later]){
        UITableView *tableView = [self tableView];
        
        SEL hideConfirmationViewSelector = NSSelectorFromString([NSString stringWithFormat:@"_endSwi%@teRowDi%@:", @"peToDele", @"dDelete"]);
        SEL getCellSelector = NSSelectorFromString([NSString stringWithFormat:@"_sw%@oDele%@ll", @"ipeT", @"teCe"]);
        
        if ([tableView respondsToSelector:hideConfirmationViewSelector] && [tableView respondsToSelector:getCellSelector]) {
            id cellShowingDeleteConfirmationView = ((id(*)(id, SEL))objc_msgSend)(tableView, getCellSelector);
            if ([self isEqual:cellShowingDeleteConfirmationView]) {
                ((void(*)(id, SEL, BOOL))objc_msgSend)(tableView, hideConfirmationViewSelector, NO);
            }
        }
    }else if([QLVersionUtil iOS6]){
        if(self.swipWidth > 0){
            CGRect rect = self.contentView.frame;
            rect.origin.x = 0;
            
            CGRect deleteConfirmViewRect = self.deleteConfirmView.frame;
            deleteConfirmViewRect.origin.x = self.bounds.size.width;
            
            [UIView animateWithDuration:0.25 animations:^{
                self.contentView.frame = rect;
                self.deleteConfirmView.frame = deleteConfirmViewRect;
            }completion:^(BOOL finished) {
                self.swipWidth = 0;
            }];
        }
    }
}


#pragma mark - button configure

- (void)configureButtonCommonProperteis:(UIButton *)deleteConfirmationButton rowAction:(QLTableViewRowAction *)rowAction
{
    NSString *moreTitle = rowAction.title;
    
    if ([QLVersionUtil iOS6]) {
        for (UIView *label in deleteConfirmationButton.subviews) {
            if ([label isKindOfClass:[UILabel class]]) {
                [(UILabel*)label setText:moreTitle];
                break;
            }
        }
    }else{
        [deleteConfirmationButton setTitle:moreTitle forState:UIControlStateNormal];
        
        UIEdgeInsets edgeInsets = rowAction.edgeInsets;
        // Try to get 'Delete' edgeInsets from delegate
        [deleteConfirmationButton setTitleEdgeInsets:edgeInsets];
    }
    
    // Try to get 'Delete' backgroundColor from delegate
    UIColor *backgroundColor = rowAction.backgroundColor;
    if (backgroundColor) {
        deleteConfirmationButton.backgroundColor = backgroundColor;
    }

    // Try to get 'Delete' titleColor from delegate
    UIColor *deleteButtonTitleColor = rowAction.backgroundColor;
    if (deleteButtonTitleColor) {
        for (UIView *label in deleteConfirmationButton.subviews) {
            if ([label isKindOfClass:[UILabel class]]) {
                [(UILabel*)label setTextColor:deleteButtonTitleColor];
                break;
            }
        }
    }
}

- (void)configureDeleteButton:(UIButton *)deleteConfirmationButton rowAction:(QLTableViewRowAction *)rowAction
{
    /*
     * 'Normalize' 'UITableViewCellDeleteConfirmationView's' title text implementation, because
     * under iOS 7 UIKit itself doesn't show the text using it's 'UIButtonLabel's' setTitle: but
     * using a seperate 'UILabel'.
     *
     * WHY Apple, WHY?
     *
     */
    
    [deleteConfirmationButton.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if ([view class] == [UILabel class]) {
            UILabel *titleLabel = (UILabel *)view;
            [titleLabel removeFromSuperview];
            titleLabel = nil;
            
            // Needed because otherwise the sizing algorithm wouldn't work for iOS 7
            deleteConfirmationButton.autoresizingMask = UIViewAutoresizingNone;
            
            *stop = YES;
        }
    }];
    
    //bind click event handler;
    [deleteConfirmationButton updateRowAction:rowAction];
    
    [self configureButtonCommonProperteis:deleteConfirmationButton rowAction:rowAction];
}


- (void)dealloc {
    [self.cellScrollView.layer removeObserver:self forKeyPath:@"sublayers" context:nil];
}

- (void)configureMoreOptionButtonForDeleteConfirmationView:(UIView *)deleteConfirmationView
                              withDeleteConfirmationButton:(UIButton *)deleteConfirmationButton {
    UITableView *tableView = [self tableView];
    NSIndexPath *indexPath = [tableView indexPathForCell:self];
    
    // Need to get the delegate as strong variable because it's a weak property
    id<UITableViewDelegate> strongDelegate = (id)tableView.delegate;
    if (strongDelegate) {
        
        NSArray *actions = [strongDelegate tableView:tableView editActionsForRowAtIndexPath:indexPath];
        
        if (actions.count > 0) {
            //just a delete ；
            if (actions.count == 1) {
                QLTableViewRowAction *action = actions[0];
                [self configureDeleteButton:deleteConfirmationButton rowAction:action];
            }else{
                NSMutableArray *otherBtns = [[NSMutableArray alloc]init];
                for (int i = actions.count-1; i >= 0; i --) {
                    QLTableViewRowAction *action = actions[i];
                    
                    if (i == 0) {
                        [self configureDeleteButton:deleteConfirmationButton rowAction:action];
                    }else{
                        
                        UIButton *moreOptionButton = [UIButton buttonWithRowAction:action];
                        [self configureButtonCommonProperteis:moreOptionButton rowAction:action];
                        // add the 'more' button to the cell's view hierarchy
                        [deleteConfirmationView addSubview:moreOptionButton];
                        [otherBtns addObject:moreOptionButton];
                    }
                }
                
                // Size buttons as they would be displayed.
                [self sizeMoreOptionButtonAndDeleteConfirmationButton:deleteConfirmationButton otherButtons:otherBtns];
            }
        }
    }
}

- (void)sizeMoreOptionButtonAndDeleteConfirmationButton:(UIButton *)deleteConfirmationButton
                                           otherButtons:(NSArray *)otherBtns
{
    //整理顺序！
    NSMutableArray *allButons = [NSMutableArray arrayWithArray:otherBtns];
    [allButons addObject:deleteConfirmationButton];
    
    // Get 'delete' button height calculated by UIKit.
    CGFloat deleteConfirmationButtonHeight = deleteConfirmationButton.frame.size.height;
    
    CGFloat lastX = 0;
    for (UIButton *btn in allButons) {
        // Size 'more' button
        CGRect moreButtonFrame = CGRectZero;
        moreButtonFrame.size = [btn intrinsicContentSize];
        moreButtonFrame.size.height = deleteConfirmationButtonHeight;
        if (![QLVersionUtil iOS6]) {
            moreButtonFrame.size.width += deleteConfirmationButton.titleEdgeInsets.left + deleteConfirmationButton.titleEdgeInsets.right;
        }
        
        moreButtonFrame.origin.x = lastX;
        // Fix 'delete' button's origin.x and set the frame
        lastX += moreButtonFrame.size.width;
        btn.frame = moreButtonFrame;
    }
    
    // Get needed variables
    UIView *deleteConfirmationView = deleteConfirmationButton.superview;
    CGRect deleteConfirmationFrame = deleteConfirmationView.frame;
    CGFloat oldDeleteConfirmationFrameSuperViewWidth = deleteConfirmationFrame.origin.x + deleteConfirmationFrame.size.width;
    
    // Adjust the 'UITableViewCellDeleteConfirmationView's' frame to fit the new button sizes.
    deleteConfirmationFrame.size.width = lastX;
    deleteConfirmationFrame.origin.x = oldDeleteConfirmationFrameSuperViewWidth - deleteConfirmationFrame.size.width;
    
    deleteConfirmationView.frame = deleteConfirmationFrame;
}

- (void)setupObserving {
    /*
     * For iOS 7:
     * ==========
     *
     * Look for UITableViewCell's scrollView.
     * Any CALayer found here can only be generated by UITableViewCell's
     * 'initWithStyle:reuseIdentifier:', so there is no way adding custom
     * sublayers before. This means custom sublayers are no problem and
     * don't break MSCMoreOptionTableViewCell's functionality.
     *
     */
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.delegate isKindOfClass:[UIScrollView class]]) {
            _cellScrollView = (UIScrollView *)layer.delegate;
            [_cellScrollView.layer addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionNew context:nil];
            break;
        }
    }
}

#pragma mark - iOS 8 handle
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


#pragma mark - utils

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

- (bool)findSwipedCellAndClosed
{
    bool finded = NO;
    UITableView *tb = [self tableView];;
    for (QLTableViewCell *cell in [tb visibleCells]) {
        if (cell.swipWidth > 0) {
            [cell hideDeleteConfirmation];
            finded = YES;
            break;
        }
    }
    return finded;
}

#pragma mark - handle touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    bool finded = NO;
    if ([QLVersionUtil iOS6]) {
        finded = [self findSwipedCellAndClosed];
    }
    
    if (!finded) {
        [super touchesBegan:touches withEvent:event];
    }
}

@end
