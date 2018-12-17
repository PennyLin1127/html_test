//
//  SubscribeTableViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/3/30.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "SubscribeTableViewController.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"

@interface SubscribeTableViewController () {
    UIImage *imageOn;
    UIImage *imageOff;
    
    BOOL dmIsOn;
    BOOL telIsOn;
    BOOL edmIsOn;
    BOOL mmsIsOn;
    
    
    NSUserDefaults *userDefaults;
    

}

@property (weak, nonatomic) IBOutlet UIButton *dmButton;
@property (weak, nonatomic) IBOutlet UIButton *telButton;
@property (weak, nonatomic) IBOutlet UIButton *edmButton;
@property (weak, nonatomic) IBOutlet UIButton *mmsButton;

@property (weak, nonatomic) IBOutlet UILabel *hiLabel;

- (IBAction)buttonAction:(id)sender;

@end

@implementation SubscribeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init image
    imageOn = [UIImage imageNamed:@"switch_On"];
    imageOff = [UIImage imageNamed:@"switch_Off"];
    
    //init var
    dmIsOn = YES;
    telIsOn = YES;
    edmIsOn = YES;
    mmsIsOn = YES;
    
    //init var
    userDefaults = [NSUserDefaults standardUserDefaults];

    
    //初始化Label
    //Name
    NSString *name = [userDefaults objectForKey:USER_NAME];
    self.hiLabel.text = [NSString stringWithFormat:@"Hi %@ 您好~\n因作業程序，會員異動資料後 30 日內，仍有可能收到優惠訊息;為避免錯失活動優惠通知，建議請選擇接收訊息以保障您的權益。", name];

    
    //解析資料
    
    if (self.arrayData.count > 0) {
        
        for (NSDictionary *tempDic in self.arrayData) {
            NSString *subscribeChannel = [tempDic objectForKey:@"subscribeChannel"];
            
            //HOLA才處理
            if ([subscribeChannel isEqualToString:@"HOLA"]) {
                
                NSString *subscribeCategory = [tempDic objectForKey:@"subscribeCategory"];
                NSString *subscribeValue = [tempDic objectForKey:@"subscribeValue"];
                
                NSLog(@"subscribeCategory -- %@", subscribeCategory);
                NSLog(@"subscribeValue -- %@", subscribeValue);
                
                //做個別處理
                if ([subscribeCategory isEqualToString:@"DM"]) {
                    if ([subscribeValue isEqualToString:@"y"]) {
                        dmIsOn = YES;
                    }else {
                        dmIsOn = NO;
                    }
                    [self changeButtonImage:self.dmButton isOn:dmIsOn];
                }else if ([subscribeCategory isEqualToString:@"TEL"]) {
                    if ([subscribeValue isEqualToString:@"y"]) {
                        telIsOn = YES;
                    }else {
                        telIsOn = NO;
                    }
                    [self changeButtonImage:self.telButton isOn:telIsOn];
                }else if ([subscribeCategory isEqualToString:@"EDM"]) {
                    if ([subscribeValue isEqualToString:@"y"]) {
                        edmIsOn = YES;
                    }else {
                        edmIsOn = NO;
                    }
                    [self changeButtonImage:self.edmButton isOn:edmIsOn];
                }else if ([subscribeCategory isEqualToString:@"MMS"]) {
                    if ([subscribeValue isEqualToString:@"y"]) {
                        mmsIsOn = YES;
                    }else {
                        mmsIsOn = NO;
                    }
                    [self changeButtonImage:self.mmsButton isOn:mmsIsOn];
                }
                
            }else {
                continue;
            }
            
        }
        
    }
    
    
    //
    [self holaBackCus];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    
    if (section==0)
    {
        return 1;
    }else if(section==1)
    {
        return 4;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section==0) {
        return 84;
    }else if (indexPath.section==1){
        return 44;
    }
    return 0;
}



-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    return view;
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (IBAction)switchAction:(id)sender {
    
    UISwitch *sw = (UISwitch*)sender;
    NSInteger index = sw.tag;
    NSLog(@"剛剛修改哪個switch -- %zd", index);
    
    //ORG Value
    BOOL dmValue = dmIsOn;
    BOOL telValue = telIsOn;
    BOOL edmValue = edmIsOn;
    BOOL mmsValue = mmsIsOn;
    
    NSString *dmStrValue = dmValue == YES ? @"y" : @"n";
    NSString *telStrValue = telValue == YES ? @"y" : @"n";
    NSString *edmStrValue = edmValue == YES ? @"y" : @"n";
    NSString *mmsStrValue = mmsValue == YES ? @"y" : @"n";
    
    //組成Dic
    NSDictionary *dmDic = @{@"subscribeChannel": @"HOLA", @"subscribeCategory":@"DM", @"subscribeValue":dmStrValue};
    NSDictionary *telDic = @{@"subscribeChannel": @"HOLA", @"subscribeCategory":@"TEL", @"subscribeValue":telStrValue};
    NSDictionary *edmDic = @{@"subscribeChannel": @"HOLA", @"subscribeCategory":@"EDM", @"subscribeValue":edmStrValue};
    NSDictionary *mmsDic = @{@"subscribeChannel": @"HOLA", @"subscribeCategory":@"MMS", @"subscribeValue":mmsStrValue};
    
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    
    NSDictionary *dic = @{@"sessionId": sessionId, @"detail":@[dmDic, telDic, edmDic, mmsDic]};
    
    //傳送資料
    //撈資料
    __block NSData *returnData;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:MY_SAVE_SUBSCRIBE] AndDic:dic];
        
    } completionBlock:^{
        
        [hud show:NO];
        [hud hide:YES];
        
        //資料為空
        if (returnData == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            
            [alert show];
            
            return;
            
        }else {
            NSString *testStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            NSLog(@"testStr -- %@", testStr);
            PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];

            NSDictionary *returnDic = [perfectAPIManager convertEncryptionNSDataToDic:returnData];
            NSLog(@"returnDic -- %@", returnDic);
            
            if (returnDic == nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [alert show];
                
                return;
            }
            
            //儲存sessionId
            NSString *sessionId = [returnDic objectForKey:@"sessionId"];
            [IHouseUtility saveSessionIDToUserDefaults:sessionId];
            
            BOOL status = [[returnDic objectForKey:@"status"] integerValue];
            
            NSLog(@"status -- %zd", status);
            
            if (status == NO) {
                //狀態失敗 直接顯示回傳的訊息
                NSString *msg = [returnDic objectForKey:@"msg"];
                
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [av show];
                
                //改回原來的值
                if (index == 0) {
                    dmIsOn = dmValue == YES ? NO : YES;
                }else if (index == 1) {
                    telIsOn = telValue == YES ? NO : YES;
                }else if (index == 2) {
                    edmIsOn = edmValue == YES ? NO : YES;
                }else if (index == 3) {
                    mmsIsOn = mmsValue == YES ? NO : YES;
                }
                
                return;
                
            }else {
                //成功
                NSLog(@"修改資料成功");
                NSString *msg = [returnDic objectForKey:@"msg"];
                NSLog(@"msg -- %@", msg);
            }
        }
    }];
    
}

#pragma mark - Navigation Bar
// HOLA back button
- (void)holaBackCus {
    
    UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backAction)];
    [barBtnItem setImage:image1];
    self.navigationItem.leftBarButtonItem = barBtnItem;
    
}

-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Button 事件
- (IBAction)buttonAction:(id)sender {
    UIButton *btn = (UIButton*)sender;
    NSInteger index = btn.tag;
    NSLog(@"目前選到哪一個按鈕 -- %zd", index);
    
    BOOL isOn;
    
    if (index == 0) {
        if (dmIsOn) {
            dmIsOn = NO;
        }else {
            dmIsOn = YES;
        }
        
        isOn = dmIsOn;
//        [self changeButtonImage:btn isOn:dmIsOn];
    }else if (index == 1) {
        if (telIsOn) {
            telIsOn = NO;
        }else {
            telIsOn = YES;
        }
        
        isOn = telIsOn;
        
//        [self changeButtonImage:btn isOn:telIsOn];
    }else if (index == 2) {
        if (edmIsOn) {
            edmIsOn = NO;
        }else {
            edmIsOn = YES;
        }
        
        isOn = edmIsOn;
        
//        [self changeButtonImage:btn isOn:edmIsOn];
    }else if (index == 3) {
        if (mmsIsOn) {
            mmsIsOn = NO;
        }else {
            mmsIsOn = YES;
        }
        
        isOn = mmsIsOn;

    }
    
    [self changeButtonImage:btn isOn:isOn];
    
    [self sendDataToServer:btn isOn:isOn];
}


//改變Button圖片
-(void)changeButtonImage:(UIButton*)btn isOn:(BOOL)isOn {
    
    if (isOn == YES) {
        //開
        [btn setImage:imageOn forState:UIControlStateNormal];
    }else{
        //關
        [btn setImage:imageOff forState:UIControlStateNormal];
    }
}

#pragma mark - send Data to Server
-(void) sendDataToServer:(UIButton*)btn isOn:(BOOL)isOn {
    
    //Org Value
    BOOL orgValue = isOn == YES ? NO : YES; //原本未改變的值
    NSLog(@"原來的值 -- %zd", orgValue);
    NSString *value =  isOn == YES ? @"y" : @"n";
    
    //組成Dic
    NSDictionary *changeDic;
    if (btn == self.dmButton) {
        changeDic = @{@"subscribeChannel": @"HOLA", @"subscribeCategory":@"DM", @"subscribeValue":value};
    }else if (btn == self.telButton) {
        changeDic = @{@"subscribeChannel": @"HOLA", @"subscribeCategory":@"TEL", @"subscribeValue":value};
    }else if (btn == self.edmButton) {
        changeDic = @{@"subscribeChannel": @"HOLA", @"subscribeCategory":@"EDM", @"subscribeValue":value};
    }else if (btn == self.mmsButton) {
        changeDic = @{@"subscribeChannel": @"HOLA", @"subscribeCategory":@"MMS", @"subscribeValue":value};
    }
    
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    
    NSDictionary *dic = @{@"sessionId": sessionId, @"detail":@[changeDic]};

    //傳送資料
    __block NSData *returnData;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:MY_SAVE_SUBSCRIBE] AndDic:dic];
        
    } completionBlock:^{
        
        [hud show:NO];
        [hud hide:YES];
        
        //資料為空
        if (returnData == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            
            //改回原來的值
            [self changeButtonImage:btn isOn:orgValue];
            [self changeToOrgValue:btn isOn:orgValue];
            
            [alert show];
            
            return;
            
        }else {
            NSString *testStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            NSLog(@"testStr -- %@", testStr);
            PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];

            NSDictionary *returnDic = [perfectAPIManager convertEncryptionNSDataToDic:returnData];
            NSLog(@"returnDic -- %@", returnDic);
            
            if (returnDic == nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [alert show];
                
                //改回原來的值
                [self changeButtonImage:btn isOn:orgValue];
                [self changeToOrgValue:btn isOn:orgValue];
                
                return;
            }
            
            //儲存sessionId
            NSString *sessionId = [returnDic objectForKey:@"sessionId"];
            [IHouseUtility saveSessionIDToUserDefaults:sessionId];
            
            BOOL status = [[returnDic objectForKey:@"status"] integerValue];
            
            NSLog(@"status -- %zd", status);
            
            if (status == NO) {
                //狀態失敗 直接顯示回傳的訊息
                NSString *msg = [returnDic objectForKey:@"msg"];
                
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [av show];
                
                //改回原來的值
                [self changeButtonImage:btn isOn:orgValue];
                [self changeToOrgValue:btn isOn:orgValue];
                return;
                
            }else {
                //成功
                NSLog(@"修改資料成功");
                NSString *msg = [returnDic objectForKey:@"msg"];
                NSLog(@"msg -- %@", msg);
            }
        }
    }];

    
}

//改回原來的值
-(void)changeToOrgValue:(UIButton*)btn isOn:(BOOL)isOn {

    if (btn == self.dmButton) {
        dmIsOn = isOn;
    }else if (btn == self.telButton) {
        telIsOn = isOn;
    }else if (btn == self.edmButton) {
        edmIsOn = isOn;
    }else if (btn == self.mmsButton) {
        mmsIsOn = isOn;
    }
    
}
@end
