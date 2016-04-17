//
//  UIButton+rowAction.h
//  TreeList
//
//  Created by xuqianlong on 16/4/17.
//  Copyright © 2016年 Debugly. All rights reserved.
//
//https://github.com/debugly/TreeList

#import <UIKit/UIKit.h>
#import "QLTableViewRowAction.h"

@interface UIButton (rowAction)

@property (nonatomic, strong) QLTableViewRowAction *rowAction;

+ (instancetype)buttonWithRowAction:(QLTableViewRowAction *)rowAction;

- (void)updateRowAction:(QLTableViewRowAction *)rowAction;

@end
