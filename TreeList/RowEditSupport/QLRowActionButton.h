//
//  QLRowActionButton.h
//  TreeList
//
//  Created by qianlongxu on 16/4/13.
//  Copyright © 2016年 Debugly. All rights reserved.
//
//https://github.com/debugly/TreeList

#import <UIKit/UIKit.h>
#import "QLTableViewRowAction.h"

@interface QLRowActionButton : UIButton

@property (nonatomic, strong ,readonly) QLTableViewRowAction *rowAction;

+ (instancetype)buttonWithRowAction:(QLTableViewRowAction *)rowAction;

@end
