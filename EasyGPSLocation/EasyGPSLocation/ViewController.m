//
//  ViewController.m
//  EasyGPSLocation
//
//  Created by Liangk on 2017/11/8.
//  Copyright © 2017年 liang. All rights reserved.
//

#import "ViewController.h"
#import "EasyGPSLocation.h"

@interface ViewController ()

/* 显示 */
@property (weak, nonatomic) IBOutlet UITextView *msgTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - 开始定位
- (IBAction)clickStartLocationBtn:(UIButton *)sender {
    
    if (![EasyGPSLocation locationServicesEnabled]) {
        NSLog(@"定位服务不可用");
    }
    else {
        
        [[EasyGPSLocation sharedInstance] registerGPSLocationResultBlock:^(BOOL success, NSString *msg) {
            if (success) {
                NSLog(@"定位成功：%@",[EasyGPSLocation getLocation]);
                NSLog(@"%@",[EasyGPSLocation getLocationCity]);
                
                self.msgTextView.text = [NSString stringWithFormat:@"定位成功!\n\n 定位地址:%@ \n\n 定位城市:%@",[EasyGPSLocation getLocation],[EasyGPSLocation getLocationCity]];
            }
            else {
                NSLog(@"定位失败：%@",msg);
                NSLog(@"缓存的定位位置：%@",[EasyGPSLocation getLocation]);
                NSLog(@"缓存的定位城市：%@",[EasyGPSLocation getLocationCity]);
                
                self.msgTextView.text = [NSString stringWithFormat:@"定位失败!\n失败原因:%@ 缓存的定位位置:%@ \n 缓存的定位城市:%@",msg,[EasyGPSLocation getLocation],[EasyGPSLocation getLocationCity]];
            }
        }];
        
        NSLog(@"开始定位~");
        [[EasyGPSLocation sharedInstance] startLocation];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
