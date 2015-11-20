//
//  ListViewController.h
//  TextImage
//
//  Created by 王长旭 on 15/11/5.
//  Copyright © 2015年 王长旭. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong,nonatomic) UITableView * tableView;
@property (strong,nonatomic) NSMutableArray * dataArray;
@end
