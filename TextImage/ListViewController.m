//
//  ListViewController.m
//  TextImage
//
//  Created by 王长旭 on 15/11/5.
//  Copyright © 2015年 王长旭. All rights reserved.
//

#import "ListViewController.h"
#import "TextImageCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ChatBar.h"

#define stateBarHeight 20
#define padding 10

@interface ListViewController ()<ChatBarDelegate>

@property(nonatomic,strong) ChatBar * chatBar;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView fd_heightForCellWithIdentifier:@"TextImageCell" cacheByIndexPath:indexPath configuration:^(id cell) {
        NSString *mes = [self.dataArray[indexPath.row] copy];
        [cell setMessages:mes];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextImageCell"];
    cell.backgroundColor = tableView.backgroundColor;
    NSString *mes = [self.dataArray[indexPath.row] copy];
    [cell setMessages:mes];
    return cell;
}

#pragma mark - ChatBarDelegate

- (void) ChatBarDidChange:(ChatBar*)chatBar  Frame:(CGRect)frame{
    CGRect tableView = self.tableView.frame;
    tableView.size.height = chatBar.frame.origin.y - stateBarHeight;
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.frame = tableView;
        [self scrollToBottom];
    }completion:nil];
}

- (void) sendMessage:(NSString*) message{
    [self.dataArray addObject:message];
    [self.tableView reloadData];
    [self scrollToBottom];
}

#pragma mark - Public Methods


-(void) setup{
    self.view.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:234/255.0f blue:234/255.f alpha:1.0f];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.chatBar];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endInputing)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
}

-(void)endInputing{
    [self.chatBar endInputing];
}

- (void)scrollToBottom {
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
}

#pragma mark - Getter


-(UITableView*)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, stateBarHeight, self.view.frame.size.width,self.view.frame.size.height - stateBarHeight - chatBarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [self.view backgroundColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerClass:[TextImageCell class] forCellReuseIdentifier:@"TextImageCell"];
    }
    
    return _tableView;
}

-(ChatBar *) chatBar{
    if(!_chatBar){
        _chatBar = [[ChatBar alloc] initWithFrame:CGRectMake(0, self.tableView.frame.size.height + stateBarHeight, self.view.frame.size.width, chatBarHeight)];
        _chatBar.backgroundColor = self.view.backgroundColor;
        _chatBar.delegate = self;
    }
    return _chatBar;
}

-(NSArray *) dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] initWithObjects:@"啊就是肯德基123123撒了空间的卡拉斯京抵抗力就仨快递",@"1",@"asjkdl",@"[--1]",@"ajklhs[--2][--23][--12][--10][--10][--2][--23][--12][--12]",@"123",@"123",nil];
    }
    return _dataArray;
}

@end
