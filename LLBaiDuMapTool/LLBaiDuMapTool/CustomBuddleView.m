
//
//  CustomBuddleView.m
//  07_BDMapDemo
//
//  Created by 李龙 on 16/7/27.
//  Copyright © 2016年 Yuen. All rights reserved.
//

#import "CustomBuddleView.h"


@interface CustomBuddleView ()
@property (nonatomic,strong) UIButton *currentBtn;
@property (nonatomic,strong) UILabel *currentLabel;
@end


@implementation CustomBuddleView

- (instancetype)init {
    if (self = [super init]) {
        //初始化控件
        [self initSubViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        //初始化控件
        [self initSubViews];
    }
    return self;
}

//不要xxx.frame = GRectmake()这样设置frame
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //初始化控件
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
 
    _currentBtn = ({
    
        UIButton *iconBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [iconBtn setBackgroundImage:[UIImage imageNamed:@"test2"] forState:0];
        [iconBtn addTarget:self action:@selector(btnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [iconBtn setTitle:@"ssssss" forState:0];
        [self addSubview:iconBtn];
        iconBtn;
    });
    
    _currentLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 100, 50)];
        label.text = @"xxxxxxxxx";
        [self addSubview:label];
        label;
    
    });
    
}

-(void)setCustomerName:(NSString *)customerName{
    _customerName = customerName;
    NSLog(@"===>%@",_customerName);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [_currentBtn setTitle:customerName forState:0];
        //    [_currentBtn setTitle:customerName forState:0];
        [_currentBtn setTitleColor:[UIColor redColor] forState:0];
    });
    
    
    _currentLabel.text = customerName;
}

- (void)btnOnClick:(UIButton *)btn{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.lilongcnc.cc"]];
}

@end
