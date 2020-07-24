//
//  ViewController.m
//  Demo
//
//  Created by wujun on 2020/6/19.
//  Copyright © 2020 Company. All rights reserved.
//

#import "ViewController.h"
#import "DemoVC.h"
//#import <sqlite3.h>
#import "UIWebViewVC.h"

static NSString * identifier = @"cxCellID";


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
    UIButton *butn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    butn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:butn];
    [butn setTitle:@"按钮" forState:UIControlStateNormal];
    [butn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *webViewBtn = [[UIButton alloc]initWithFrame:CGRectMake(butn.frame.origin.x + butn.frame.size.width, 0, 44, 44)];
    webViewBtn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:webViewBtn];
    [webViewBtn setTitle:@"webView" forState:UIControlStateNormal];
    [webViewBtn addTarget:self action:@selector(webClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    UISwitch *ben = [[UISwitch alloc]initWithFrame:CGRectMake(0, 100, 50, 44)];
    [self.view addSubview:ben];
    [ben addTarget:self action:@selector(vauleChange) forControlEvents:UIControlEventTouchUpInside];
    
    UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(0, ben.frame.size.height+ben.frame.origin.y, 50, 44)];
    [self.view addSubview:slider];
    [slider addTarget:self action:@selector(slider) forControlEvents:UIControlEventValueChanged];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, slider.frame.origin.y +slider.frame.size.height, self.view.frame.size.width, 300) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    
    [self.view addSubview:self.collectionView];

}
-(UICollectionView *)collectionView{

    if (!_collectionView) {
        //自动网格布局
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
        //网格布局
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, self.tableView.frame.origin.y+self.tableView.frame.size.height, self.tableView.frame.size.width, 300) collectionViewLayout:flowLayout];
        //注册cell
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identifier];
        //设置数据源代理
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}
-(void)vauleChange{
    NSLog(@"vauleChange");
}
-(void)click{
    NSLog(@"click");
    DemoVC *vc = [[DemoVC alloc]init];
    [self presentViewController:vc animated:YES completion:^{
    }];
}
-(void)slider{
    NSLog(@"slider");
}
-(void)webClick{
    UIWebViewVC *vc = [[UIWebViewVC alloc]init];
    [self presentViewController:vc animated:YES completion:^{}];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"UITableViewCell";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = @"大佬";
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}



#pragma mark - deleDate

//有多少的分组

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}
//每个分组里有多少个item

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 100;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor orangeColor];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didSelectItemAtIndexPath");
}

@end
