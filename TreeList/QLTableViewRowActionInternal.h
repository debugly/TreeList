
//
//  QLTableViewRowActionInternal.h
//  TreeList
//
//  Created by qianlongxu on 16/3/15.
//  Copyright © 2016年 Debugly. All rights reserved.
//

@interface QLTableViewRowAction ()

@property (nonatomic, readwrite) QLTableViewRowActionStyle style;
@property (nonatomic, copy)  void (^RowActionHanler)(QLTableViewRowAction *action, NSIndexPath *indexPath);

@end