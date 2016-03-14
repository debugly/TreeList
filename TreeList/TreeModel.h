//
//  TreeModel.h
//  TreeList
//
//  Created by xuqianlong on 16/3/14.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreeModel : NSObject

@property (nonatomic, assign) NSInteger leval;//缩进等级，从0开始；
@property (nonatomic, assign, getter=isOpened) BOOL opened;

@property (nonatomic, strong) NSDate *date;

- (instancetype)initWithLeval:(NSInteger)leval;

@end
