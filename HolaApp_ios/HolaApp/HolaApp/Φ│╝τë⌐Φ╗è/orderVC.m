//
//  orderVC.m
//  HOLA
//
//  Created by Joseph on 2015/9/21.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "orderVC.h"
#import "IHouseURLManager.h"

@interface orderVC ()

@end

@implementation orderVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [self postData:HOLA_ORDER];
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationItem.rightBarButtonItems = nil;
}

@end
