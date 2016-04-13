//
//  TreeModel.m
//  TreeList
//
//  Created by xuqianlong on 16/3/14.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import "TreeModel.h"

@implementation TreeModel

- (instancetype)initWithLeval:(NSInteger)leval
{
    self = [super init];
    if (self) {
        self.leval = leval;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"leval:%ld,Date:%@",(long)_leval,_date];
}
@end
