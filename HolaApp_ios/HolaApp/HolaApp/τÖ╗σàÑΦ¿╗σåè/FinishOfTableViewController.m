//
//  FinishOfTableViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/18.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "FinishOfTableViewController.h"

@interface FinishOfTableViewController ()

@end

@implementation FinishOfTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self holaBackCus];
    //顯示資料
    self.nameLabel.text = self.name;
    self.birthdayLabel.text = self.birthday;
    self.emailLabel.text = self.email;
    self.phoneLabel.text = self.phone;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// HOLA back button
- (void)holaBackCus {
    
    UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithImage:image1 style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backAction)];

    [barBtnItem setImage:image1];
    self.navigationItem.leftBarButtonItem = barBtnItem;
    
}

-(void) backAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}

@end
