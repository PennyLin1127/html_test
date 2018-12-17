//
//  NewsCategoryListViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/14.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "NewsCategoryListViewController.h"
#import "NewsCategoryTableViewCell.h"
#import "IHouseURLManager.h"
#import "NewsCategoryDetailViewController.h"
#import "SQLiteManager.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface NewsCategoryListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NewsCategoryListViewController

#pragma mark - View生命週期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //delegate
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    NSLog(@"nav is%@", self.navigationController);
    
    //if controller pushed from index page, then need to add view and label on top
    if (self.isLife1 == YES) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, -65)];
        view.backgroundColor = [UIColor whiteColor];
        [self.tableView addSubview:view];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, -1)];
        bottomLine.backgroundColor = [UIColor grayColor];
        [self.tableView addSubview:bottomLine];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, -65)];
        label.text = @"生活提案";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:20];
        [self.tableView addSubview:label];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - TableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"NewsCategoryCell";
    
    NewsCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    //reverse data and let latest date object on top
    NSArray *reverseArray = [[self.arrayData reverseObjectEnumerator] allObjects];
    NSDictionary *dic = [reverseArray objectAtIndex:indexPath.row];
    
    NSString *subject = [dic objectForKey:@"Subject"];
    cell.subjectLabel.text = subject;
    
    NSString *summary = [dic objectForKey:@"Summary"];
    cell.summaryLabel.text = summary;
    [cell.summaryLabel sizeToFit];
    
    NSString *startDate = [dic objectForKey:@"StartDate"];
    NSString *endDate = [dic objectForKey:@"EndDate"];
    cell.dateLabel.text = [NSString stringWithFormat:@"%@~%@", startDate, endDate];
    
    NSString *img = [dic objectForKey:@"Image"];
    NSString *imgURLStr = [NSString stringWithFormat:@"%@%@", [IHouseURLManager getPerfectURLByAppName:NEWS_IMAGE_PREFIX], img];
    NSURL *url = [NSURL URLWithString:imgURLStr];
    cell.asyncImageView.imageURL = url;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *tempDic = [self.arrayData objectAtIndex:indexPath.row];
    NSString *newsId = [tempDic objectForKey:@"NewsId"];
    
    NSArray *tempArray = [SQLiteManager getNewsDetailDataByNewsId:newsId];
    
    if (tempArray.count > 0) {

        NewsCategoryDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NewsCategoryDetailView"];
        vc.dicData = tempArray[0];
        vc.isLife2 = self.isLife1;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    
    // GA -- 選擇內容
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/news/item/%@",newsId]];
    [tracker send : [ [ GAIDictionaryBuilder createScreenView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/news/item/%@",newsId]
                                                          action:@"button_press"
                                                           label:nil
                                                           value:nil] build]];
}

@end
