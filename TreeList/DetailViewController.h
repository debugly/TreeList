//
//  DetailViewController.h
//  TreeList
//
//  Created by xuqianlong on 16/3/14.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

