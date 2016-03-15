//
//  RowActionButton.h
//  TreeList
//
//  Created by qianlongxu on 16/3/15.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QLTableViewRowAction.h"

@interface RowActionButton : UIButton

@property (nonatomic, strong ,readonly) QLTableViewRowAction *rowAction;

+ (instancetype)buttonWithRowAction:(QLTableViewRowAction *)rowAction;

@end
