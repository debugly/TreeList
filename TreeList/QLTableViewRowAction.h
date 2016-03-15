//
//  QLTableViewRowAction.h
//  TreeList
//
//  Created by qianlongxu on 16/3/15.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QLTableViewRowActionStyle) {
    QLTableViewRowActionStyleDefault = 0,
    QLTableViewRowActionStyleDestructive = QLTableViewRowActionStyleDefault,
    QLTableViewRowActionStyleNormal
};

@interface QLTableViewRowAction : NSObject<NSCopying>

+ (instancetype)rowActionWithStyle:(QLTableViewRowActionStyle)style title:(NSString *)title handler:(void (^)(QLTableViewRowAction *action, NSIndexPath *indexPath))handler;

@property (nonatomic, readonly) QLTableViewRowActionStyle style;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) UIColor *backgroundColor; // default background color is dependent on style

@end
