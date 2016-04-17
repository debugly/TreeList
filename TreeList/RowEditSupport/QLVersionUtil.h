//
//  QLVersionUtil.h
//  iPhoneVideo
//
//  Created by qianlongxu on 16/4/13.
//  Copyright © 2016年 Debugly. All rights reserved.
//
// https://github.com/debugly/TreeList

#import <Foundation/Foundation.h>

@interface QLVersionUtil : NSObject

///当前系统版本
+ (int)currentSystemVersion;
///当前系统版本是否是iOS8之后的
+ (BOOL)iOS8Later;
///当前系统版本是否是iOS7之后的
+ (BOOL)iOS7Later;
///当前系统版本是否是iOS7
+ (BOOL)iOS7;
///当前系统版本是否是iOS6
+ (int)iOS6;
@end
