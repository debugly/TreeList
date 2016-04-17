//
//  QLVersionUtil.m
//  iPhoneVideo
//
//  Created by qianlongxu on 16/4/13.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import "QLVersionUtil.h"
#import <UIKit/UIKit.h>

@implementation QLVersionUtil

+ (int)currentSystemVersion
{
    static int v = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = [[[UIDevice currentDevice]systemVersion] intValue];
    });
    return v;
}

+ (BOOL)iOS8Later
{
    return [self currentSystemVersion] >= 8;
}

+ (BOOL)iOS7Later
{
    return [self currentSystemVersion] >= 7;
}

+ (BOOL)iOS7
{
    return [self currentSystemVersion] == 7;
}

+ (int)iOS6
{
    return [self currentSystemVersion] == 6;
}

@end
