//
//  DemoVC.m
//  Demo
//
//  Created by wujun on 2020/6/20.
//  Copyright © 2020 Company. All rights reserved.
//

#import "DemoVC.h"
#import <SensorsSDK/SensorsAnalyticsSDK.h>
@interface DemoVC ()

@end

@implementation DemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, 100, 100)];
    [self.view addSubview:lbl];
    lbl.text = @"手势点击埋点";
    lbl.backgroundColor = [UIColor redColor];
    
    UITapGestureRecognizer * ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
    [ges addTarget:self action:@selector(click:)];
    [lbl addGestureRecognizer:ges];
    lbl.userInteractionEnabled = YES;
    
    
    UIButton *startBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 0, 50, 44)];
    [self.view addSubview:startBtn];
    [startBtn setTitle:@"start" forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startBtn:) forControlEvents:UIControlEventTouchUpInside];
    startBtn.backgroundColor = [UIColor redColor];
    
    UIButton *endBtn = [[UIButton alloc]initWithFrame:CGRectMake(startBtn.frame.origin.x + startBtn.frame.size.width, 0, 50, 44)];
    [self.view addSubview:endBtn];
    [endBtn setTitle:@"end" forState:UIControlStateNormal];
    [endBtn addTarget:self action:@selector(endBtn:) forControlEvents:UIControlEventTouchUpInside];
    endBtn.backgroundColor = [UIColor greenColor];

    
    UIButton *pauseBtn = [[UIButton alloc]initWithFrame:CGRectMake(endBtn.frame.origin.x + endBtn.frame.size.width, 0, 60, 44)];
    [self.view addSubview:pauseBtn];
    [pauseBtn setTitle:@"pause" forState:UIControlStateNormal];
    [pauseBtn addTarget:self action:@selector(pauseBtn:) forControlEvents:UIControlEventTouchUpInside];
    pauseBtn.backgroundColor = [UIColor grayColor];
    
    
    UIButton *resumeBtn = [[UIButton alloc]initWithFrame:CGRectMake(pauseBtn.frame.origin.x + pauseBtn.frame.size.width, 0, 60, 44)];
    [self.view addSubview:resumeBtn];
    [resumeBtn setTitle:@"resume" forState:UIControlStateNormal];
    [resumeBtn addTarget:self action:@selector(resume:) forControlEvents:UIControlEventTouchUpInside];
    resumeBtn.backgroundColor = [UIColor orangeColor];
    
    
    UIButton *flushBtn = [[UIButton alloc]initWithFrame:CGRectMake(resumeBtn.frame.origin.x + resumeBtn.frame.size.width, 0, 60, 44)];
    [self.view addSubview:flushBtn];
    [flushBtn setTitle:@"flush" forState:UIControlStateNormal];
    [flushBtn addTarget:self action:@selector(flush:) forControlEvents:UIControlEventTouchUpInside];
    flushBtn.backgroundColor = [UIColor blueColor];
    
    UIButton *crashedBtn = [[UIButton alloc]initWithFrame:CGRectMake(startBtn.frame.origin.x + startBtn.frame.size.width, startBtn.frame.origin.y+startBtn.frame.size.height, 80, 44)];
    [self.view addSubview:crashedBtn];
    [crashedBtn setTitle:@"crashed" forState:UIControlStateNormal];
    [crashedBtn addTarget:self action:@selector(crashed:) forControlEvents:UIControlEventTouchUpInside];
    crashedBtn.backgroundColor = [UIColor blueColor];
    
}
-(void)startBtn:(id)sender{
    [[SensorsAnalyticsSDK sharedInstance] trackTimerStart:@"doSomething"];
}
-(void)endBtn:(id)sender{
    [[SensorsAnalyticsSDK sharedInstance] trackTimerEnd:@"doSomething" properties:nil];
}
-(void)pauseBtn:(id)sender{
    [[SensorsAnalyticsSDK sharedInstance] trackTimerPause:@"doSomething"];
}
-(void)resume:(id)sender{
    [[SensorsAnalyticsSDK sharedInstance] trackTimerResume:@"doSomething"];
}
-(void)flush:(id)sender{
    [[SensorsAnalyticsSDK sharedInstance] flush];
}
-(void)crashed:(id)sender{
    NSArray *array = @[@"first",@"second"];
    NSLog(@"---%@",array[2]);
}
-(void)click:(id)sender{
    NSLog(@"click");
}

@end
