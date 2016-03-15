//
//  QLTableViewCell.m
//  TreeList
//
//  Created by qianlongxu on 16/3/15.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import "QLTableViewCell.h"

@implementation QLTableViewCell

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL isS = [super pointInside:point withEvent:event];
    return isS;
}

@end
