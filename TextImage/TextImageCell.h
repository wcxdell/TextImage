//
//  TextImageCell.h
//  TextImage
//
//  Created by 王长旭 on 15/11/5.
//  Copyright © 2015年 王长旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextImageCell : UITableViewCell

@property (strong,nonatomic) UIImageView * backgroundImageView;
@property (strong,nonatomic) UILabel * messageLabel;

- (void)setMessages:(NSString *)message;

@end
