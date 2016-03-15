//
//  QLTableViewRowAction.m
//  TreeList
//
//  Created by qianlongxu on 16/3/15.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import "QLTableViewRowAction.h"
#import "QLTableViewRowActionInternal.h"

@implementation QLTableViewRowAction

+ (instancetype)rowActionWithStyle:(QLTableViewRowActionStyle)style title:(NSString *)title handler:(void (^)(QLTableViewRowAction *action, NSIndexPath *indexPath))handler
{
   return [[self alloc]initWithStyle:style title:title handler:handler];
}

- (instancetype)initWithStyle:(QLTableViewRowActionStyle)style title:(NSString *)title handler:(void (^)(QLTableViewRowAction *action, NSIndexPath *indexPath))handler
{
    self = [super init];
    if (self) {
        self.style = style;
        self.title = title;
        self.RowActionHanler = handler;
        switch (style) {
            case QLTableViewRowActionStyleDefault:
            {
                self.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:59.0f/255.0f blue:48.0f/255.0f alpha:1.0];
            }
                break;
            case QLTableViewRowActionStyleNormal:
            {
                self.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0];
            }
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [QLTableViewRowAction rowActionWithStyle:self.style title:self.title handler:self.RowActionHanler];
}

@end
