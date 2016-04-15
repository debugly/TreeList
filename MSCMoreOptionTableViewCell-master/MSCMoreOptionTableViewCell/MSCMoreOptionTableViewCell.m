//
//  MSCMoreOptionTableViewCell.m
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2014 Manfred Scheiner (@scheinem). All rights reserved.
//

#import "MSCMoreOptionTableViewCell.h"
#import <objc/message.h>
#import "QLVersionUtil.h"

const CGFloat MSCMoreOptionTableViewCellButtonWidthSizeToFit = CGFLOAT_MIN;

@interface MSCMoreOptionTableViewCell ()

@property (nonatomic, strong) UIButton *moreOptionButton;
@property (nonatomic, strong) UIScrollView *cellScrollView;

@end

@implementation MSCMoreOptionTableViewCell

////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
////////////////////////////////////////////////////////////////////////

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _moreOptionButton = nil;
        _cellScrollView = nil;
        if (![QLVersionUtil iOS6]) {
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
        
        [self setupObserving];
    }
    return self;
}

- (void)dealloc {
    [self.cellScrollView.layer removeObserver:self forKeyPath:@"sublayers" context:nil];
}



- (void)willRemoveSubview:(UIView *)subview {
    [super willRemoveSubview:subview];
    
    // Set the 'more' button to nil if the 'swipe to delete' container view won't be visible anymore.
    NSString *className = NSStringFromClass(subview.class);
    if ([className hasPrefix:@"UI"] && [className hasSuffix:@"ConfirmationView"]) {
        self.moreOptionButton = nil;
    }
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

////////////////////////////////////////////////////////////////////////
#pragma mark - MSCMoreOptionTableViewCell
////////////////////////////////////////////////////////////////////////

- (void)hideDeleteConfirmation {
    UITableView *tableView = [self tableView];
    
    SEL hideConfirmationViewSelector = NSSelectorFromString([NSString stringWithFormat:@"_endSwi%@teRowDi%@:", @"peToDele", @"dDelete"]);
    SEL getCellSelector = NSSelectorFromString([NSString stringWithFormat:@"_sw%@oDele%@ll", @"ipeT", @"teCe"]);
    
    if ([tableView respondsToSelector:hideConfirmationViewSelector] && [tableView respondsToSelector:getCellSelector]) {
        id cellShowingDeleteConfirmationView = ((id(*)(id, SEL))objc_msgSend)(tableView, getCellSelector);
        if ([self isEqual:cellShowingDeleteConfirmationView]) {
            ((void(*)(id, SEL, BOOL))objc_msgSend)(tableView, hideConfirmationViewSelector, NO);
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - private methods
////////////////////////////////////////////////////////////////////////

- (void)configureMoreOptionButtonForDeleteConfirmationView:(UIView *)deleteConfirmationView
                              withDeleteConfirmationButton:(UIButton *)deleteConfirmationButton {
    
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
    
    
    if (!self.moreOptionButton) {
        self.moreOptionButton = [self freshMoreOptionButton];
    }
    [self.moreOptionButton setTitle:@"取消自动删除" forState:UIControlStateNormal];
    
    CGFloat deleteConfirmationButtonWidth = 80;
    CGFloat moreOptionButtonWidth = 160;
    
    [self.moreOptionButton setBackgroundColor:[UIColor blueColor]];
    
    [self sizeMoreOptionButtonAndDeleteConfirmationButton:deleteConfirmationButton
                            deleteConfirmationButtonWidth:deleteConfirmationButtonWidth
                                    moreOptionButtonWidth:moreOptionButtonWidth];

    
    // If created add the 'more' button to the cell's view hierarchy
    if (self.moreOptionButton) {
        [deleteConfirmationView addSubview:self.moreOptionButton];
    }

}

- (void)sizeMoreOptionButtonAndDeleteConfirmationButton:(UIButton *)deleteConfirmationButton
                          deleteConfirmationButtonWidth:(CGFloat)deleteConfirmationButtonWidth
                                  moreOptionButtonWidth:(CGFloat)moreOptionButtonWidth {
    
    CGRect moreButtonFrame = CGRectZero;
    moreButtonFrame.size.width = deleteConfirmationButtonWidth;
    moreButtonFrame.size.height = self.frame.size.height;
    self.moreOptionButton.frame = moreButtonFrame;
    
    // Size 'delete' button
    CGRect deleteButtonFrame = CGRectZero;
    deleteButtonFrame.size = [deleteConfirmationButton intrinsicContentSize];
    

    deleteButtonFrame.size.width = deleteConfirmationButtonWidth;
    deleteButtonFrame.size.height = moreButtonFrame.size.height;
    

    // Get needed variables
    UIView *deleteConfirmationView = deleteConfirmationButton.superview;
    CGRect deleteConfirmationFrame = deleteConfirmationView.frame;
    CGFloat oldDeleteConfirmationFrameSuperViewWidth = deleteConfirmationFrame.origin.x + deleteConfirmationFrame.size.width;
    
    // Fix 'delete' button's origin.x and set the frame
    deleteButtonFrame.origin.x = self.moreOptionButton.frame.origin.x + self.moreOptionButton.frame.size.width;
    deleteConfirmationButton.frame = deleteButtonFrame;
    
    // Adjust the 'UITableViewCellDeleteConfirmationView's' frame to fit the new button sizes.
    deleteConfirmationFrame.size.width = self.moreOptionButton.frame.size.width + deleteConfirmationButton.frame.size.width;
    deleteConfirmationFrame.origin.x = oldDeleteConfirmationFrameSuperViewWidth - deleteConfirmationFrame.size.width;
    
    deleteConfirmationView.frame = deleteConfirmationFrame;
}

- (void)moreOptionButtonPressed:(id)sender {
    id<MSCMoreOptionTableViewCellDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(tableView:moreOptionButtonPressedInRowAtIndexPath:)]) {
        [strongDelegate tableView:[self tableView] moreOptionButtonPressedInRowAtIndexPath:[[self tableView] indexPathForCell:self]];
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

- (UIButton *)freshMoreOptionButton {
    // Initialize the 'more' button.
    UIButton *freshMoreOptionButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [freshMoreOptionButton addTarget:self action:@selector(moreOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Set 'more' button's numberOfLines to 0 to enable support for multiline titles.
    freshMoreOptionButton.titleLabel.numberOfLines = 0;
    
    // Set clipsToBounds to YES is necessary because otherwise it wouldn't be possible
    // to hide it settings it's frame's width to zero (the title would appear anyway).
    freshMoreOptionButton.clipsToBounds = YES;
    
    return freshMoreOptionButton;
}
//_UITableViewCellDeleteConfirmationControl
- (void)addSubview:(UIView *)view
{
    [super addSubview:view];
    if([NSStringFromClass([view class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]){
        __block UIButton *button = nil;
        [view.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
            if ([NSStringFromClass(subview.class) hasPrefix:@"_"] &&
                [NSStringFromClass(subview.class) hasSuffix:@"DeleteConfirmationControl"]) {
                button = (UIButton *)subview;
                *stop = YES;
            }
        }];
        
        [self configureMoreOptionButtonForDeleteConfirmationView:view
                                    withDeleteConfirmationButton:button];

    }
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
     * For iOS 8:
     * ==========
     *
     * UIDeleteConfirmationView will get added to the cell directly.
     * So there is no need for KVO anymore and we can use 
     * 'insertSubview:atIndex:' and 'willRemoveSubview:' instead.
     */
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.delegate isKindOfClass:[UIScrollView class]]) {
            _cellScrollView = (UIScrollView *)layer.delegate;
            [_cellScrollView.layer addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionNew context:nil];
            break;
        }
    }
}

@end
