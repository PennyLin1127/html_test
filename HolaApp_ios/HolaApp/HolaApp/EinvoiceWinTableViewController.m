//
//  EinvoiceWinTableViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/3/31.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "EinvoiceWinTableViewController.h"

@interface EinvoiceWinTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *invoiceNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceZoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceWinClassLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceWinPrizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mmsLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *mailLabel;

@end

@implementation EinvoiceWinTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //解析Dic data
    //中獎發票
    NSString *invoiceNo = [self.dicData objectForKey:@"invoiceNo"];
    self.invoiceNoLabel.text = [NSString stringWithFormat:@"中獎發票:%@", invoiceNo];
    
    //發票金額
    NSString *amount = [self.dicData objectForKey:@"amount"];
    self.amountLabel.text = [NSString stringWithFormat:@"%@元",amount];
    
    //列印狀態
    NSString *invoiceStatus = [self.dicData objectForKey:@"invoiceStatus"];
    self.invoiceStatusLabel.text = invoiceStatus;
    
    //中獎期數
    NSString *invoiceZone = [self.dicData objectForKey:@"invoiceZone"];
    self.invoiceZoneLabel.text = [self getZoneByString:invoiceZone];
    
    
    //中獎獎別
    NSString *invoiceWinClass = [self.dicData objectForKey:@"invoiceWinClass"];
    self.invoiceWinClassLabel.text = [self getWinClassByString:invoiceWinClass];
    
    //中獎金額
    NSString *invoiceWinPrize = [self.dicData objectForKey:@"invoiceWinPrize"];
    self.invoiceWinPrizeLabel.text = invoiceWinPrize;
    
    //MMS
    BOOL notifyViaSMSDateBOOL = [[self.dicData objectForKey:@"notifyViaSMSDate"] boolValue];
    if (notifyViaSMSDateBOOL == YES) {
        NSString *notifyViaSMSDate = [self.dicData objectForKey:@"notifyViaSMSDate"];
        NSString *notifyViaSMSPhone = [self.dicData objectForKey:@"notifyViaSMSPhone"];
        self.mmsLabel.text = [NSString stringWithFormat:@"簡訊於%@發送至您的手機%@", notifyViaSMSDate, notifyViaSMSPhone];
    }else {
        self.mmsLabel.text = @"";
    }
    
    
    
    //EMAIL
    BOOL notifyViaEmailDateBOOL = [[self.dicData objectForKey:@"notifyViaEmailDate"] boolValue];
    if (notifyViaEmailDateBOOL == YES) {
        NSString *notifyViaEmailDate = [self.dicData objectForKey:@"notifyViaEmailDate"];
        NSString *notifyViaEmailAddress = [self.dicData objectForKey:@"notifyViaEmailAddress"];
        self.emailLabel.text = [NSString stringWithFormat:@"郵件於%@發送至您的信箱%@", notifyViaEmailDate, notifyViaEmailAddress];
    }else {
        self.emailLabel.text = @"";
    }

    
    //MAIL
    BOOL paperInvoiceSendDateBOOL = [[self.dicData objectForKey:@"paperInvoiceSendDate"] boolValue];
    if (paperInvoiceSendDateBOOL == YES) {
        NSString *paperInvoiceSendDate = [self.dicData objectForKey:@"paperInvoiceSendDate"];
        NSString *paperInvoiceSendTrackNumber = [self.dicData objectForKey:@"paperInvoiceSendTrackNumber"];
        
        self.mailLabel.text = [NSString stringWithFormat:@"於%@郵寄(掛號單號:%@)", paperInvoiceSendDate, paperInvoiceSendTrackNumber];
    }else {
        self.mailLabel.text = @"";
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 3;
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

#pragma mark - 其他方法
//獎別
-(NSString*)getWinClassByString:(NSString*)str {
//    中獎獎別(A:一千萬特別獎，0:特獎；1:頭獎；2:二獎；3:三獎；4:四獎；5:五獎；6:六獎；N:不明)
    
    NSString *result;
    if ([str isEqualToString:@"A"]) {
        result = @"一千萬特別獎";
    }else if ([str isEqualToString:@"0"]) {
        result = @"特獎";
    }else if ([str isEqualToString:@"1"]) {
        result = @"頭獎";
    }else if ([str isEqualToString:@"2"]) {
        result = @"二獎";
    }else if ([str isEqualToString:@"3"]) {
        result = @"三獎";
    }else if ([str isEqualToString:@"4"]) {
        result = @"四獎";
    }else if ([str isEqualToString:@"5"]) {
        result = @"五獎";
    }else if ([str isEqualToString:@"6"]) {
        result = @"六獎";
    }else if ([str isEqualToString:@"N"]) {
        result = @"不明";
    }
    
    return result;
}

//期數
-(NSString*)getZoneByString:(NSString*)str {
    NSString *result;
    
    if (str == nil || str.length == 0 || str.length != 5) {
        return result;
    }
    
    NSString *year = [str substringToIndex:3];
    NSLog(@"year -- %@", year);
    
    NSString *month = [str substringFromIndex:3];
    NSLog(@"month -- %@", month);
    NSLog(@"%zd", month.integerValue);
    NSInteger endMonth = month.integerValue;
    NSInteger startMonth = endMonth - 1;

    result = [NSString stringWithFormat:@"中華民國%@年%02zd~%02zd月期", year, startMonth, endMonth];

    return result;
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

-(void) backAction {    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
