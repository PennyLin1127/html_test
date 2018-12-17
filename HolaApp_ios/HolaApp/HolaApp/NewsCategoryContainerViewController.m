//
//  NewsCategoryContainerViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/14.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "NewsCategoryContainerViewController.h"
#import "SQLiteManager.h"
#import "NewsCategoryListViewController.h"
#import "IHouseURLManager.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"
#import "IHouseUtility.h"

@interface NewsCategoryContainerViewController () {
    NSArray *newsCategoryName;
    NSMutableArray *buttonNameArray;
    NSMutableArray *buttonIdArray;
    NSMutableArray *buttonArray;
    NSMutableArray *vcArray;
    
    NSInteger currentButtonIndex;
    
    BOOL isInit;
}
@property (weak, nonatomic) IBOutlet UIScrollView *topButtonScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLabelConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLabelConstraint;

@end

@implementation NewsCategoryContainerViewController
#pragma mark - View生命週期
- (void)viewDidLoad {
    [super viewDidLoad];

    // get date (YYYY-MM-dd)
    NSDate *date=[NSDate date];
    NSString *dateStrFormate=[IHouseUtility createDateFormat:date];
    
    //撈出資料
    newsCategoryName = [SQLiteManager getNewsCategoryName];
    buttonArray = [[NSMutableArray alloc] init];
    buttonNameArray = [[NSMutableArray alloc] init];
    buttonIdArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dic in newsCategoryName) {
        NSString *categoryName  = [dic objectForKey:@"CategoryName"];
        NSString *categoryId = [dic objectForKey:@"CategoryId"];
        NSLog(@"categoryId -- %@", categoryId);
        [buttonNameArray addObject:categoryName];
        [buttonIdArray addObject:categoryId];
    }
    
    
    //TopButtonScrollView
    //頭尾加入 供無限循環
    NSString *firstButtonName = buttonNameArray[0];
    NSString *lastByttonName = buttonNameArray[buttonNameArray.count-1];
    [buttonNameArray insertObject:lastByttonName atIndex:0];
    [buttonNameArray insertObject:firstButtonName atIndex:buttonNameArray.count];

    NSString *firstButtonId = buttonIdArray[0];
    NSString *lastButtonId = buttonIdArray[buttonIdArray.count-1];
    [buttonIdArray insertObject:lastButtonId atIndex:0];
    [buttonIdArray insertObject:firstButtonId atIndex:buttonIdArray.count];
    
    self.topButtonScrollView.pagingEnabled = YES;
    self.topButtonScrollView.showsHorizontalScrollIndicator = NO;
    self.topButtonScrollView.showsVerticalScrollIndicator = NO;
    
    
    //動態產生ContainerView裡面的內容
    vcArray = [[NSMutableArray alloc] init];
    
    UIStoryboard *sb = self.storyboard;
    for (NSString *categoryId in buttonIdArray) {
    
        if ([HOLA_PERFECT_URL isEqualToString:HOLA_PERFECT_TEST]) {
            
            NewsCategoryListViewController *vc = [sb instantiateViewControllerWithIdentifier:@"NewsCategoryListView"];
            NSArray *tempArray = [SQLiteManager getNewsListDataByCategoryId:categoryId date:dateStrFormate];
            vc.arrayData = tempArray;
            
            [self addChildViewController:vc];
            [vcArray addObject:vc];
        }
        else
        {
            NewsCategoryListViewController *vc = [sb instantiateViewControllerWithIdentifier:@"NewsCategoryListView"];
            NSArray *tempArray = [SQLiteManager getNewsListDataByCategoryId:categoryId];
            vc.arrayData = tempArray;
            
            [self addChildViewController:vc];
            [vcArray addObject:vc];

        }
    }
    //
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    //delegate
    self.topButtonScrollView.delegate = self;
    self.scrollView.delegate = self;
    
    //改變左右邊label
    [self changeLable:1];
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isInit == NO) {
        isInit = YES;
        
        //init scrollView
        //TopButtonScrollView
        CGFloat scrollViewWidth = self.topButtonScrollView.frame.size.width;
        self.topButtonScrollView.contentSize = CGSizeMake(scrollViewWidth*buttonNameArray.count, self.topButtonScrollView.frame.size.height);
        // topButtonScrollView 上中間的 button 
        for (NSInteger i = 0; i<buttonNameArray.count; i ++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(scrollViewWidth*i, 0, scrollViewWidth, self.topButtonScrollView.frame.size.height)];
            [btn setTitle:buttonNameArray[i] forState:UIControlStateNormal];
            btn.tag = i;

            //Under Line start
//            NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:buttonNameArray[i]];
            
            // making text property to underline text-
//            [titleString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleString length])];
//            
//            [titleString addAttribute:NSForegroundColorAttributeName value:BUTTON_SELECTED_COLOR range:NSMakeRange(0, [titleString length])];
//            
//            // using text on button
//            [btn setAttributedTitle: titleString forState:UIControlStateNormal];
            //Under Line end
            
            [btn setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
            
            [buttonArray addObject:btn];
            [self.topButtonScrollView addSubview:btn];
            
        }
        
        //起始位置
        [self.topButtonScrollView scrollRectToVisible:CGRectMake(scrollViewWidth*1, 0, scrollViewWidth, self.topButtonScrollView.frame.size.height) animated:NO];
        
        //ScrollView
        self.scrollView.contentSize = CGSizeMake(scrollViewWidth*vcArray.count, self.scrollView.frame.size.height);
        
        for (NSInteger i = 0; i<vcArray.count; i++) {
            NewsCategoryListViewController *vc = vcArray[i];
            vc.view.frame = CGRectMake(scrollViewWidth*i, 0, scrollViewWidth, self.scrollView.frame.size.height);
            [self.scrollView addSubview:vc.view];
        }
        [self.scrollView scrollRectToVisible:CGRectMake(scrollViewWidth*1, 0, scrollViewWidth, self.scrollView.frame.size.height) animated:NO];
        
        
        //導向特定頁面
        if (self.needToGoSpecialCategory) {
            
            NSInteger spcialIndex = 0;
            for (NSInteger i= 0 ; i<buttonIdArray.count; i++) {
                NSString *tempStr = buttonIdArray[i];
                if ([tempStr isEqualToString:self.specialCategory]) {
                    spcialIndex = i;
                    break;
                }
            }
            
            [self changeLable:spcialIndex];
            
            //上方ButtonScollView
            [self.topButtonScrollView scrollRectToVisible:CGRectMake(scrollViewWidth*spcialIndex, 0, scrollViewWidth, self.topButtonScrollView.frame.size.height) animated:NO];
            
            //下方ScrollView
            [self.scrollView scrollRectToVisible:CGRectMake(scrollViewWidth*spcialIndex, 0, scrollViewWidth, self.scrollView.frame.size.height) animated:NO];
            
        }
         
    }
         
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scroll Delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView.tag == 100) {
        //上方ButtonScrollView
        CGRect rect = self.topButtonScrollView.frame;
        
        //切換ButtonView 做循環
        if (scrollView.contentOffset.x == 0) {
            [scrollView scrollRectToVisible:CGRectMake(rect.size.width*(buttonNameArray.count-2), 0, rect.size.width, rect.size.height) animated:NO];
        }else if(scrollView.contentOffset.x == rect.size.width*(buttonNameArray.count-1)) {
            [scrollView scrollRectToVisible:CGRectMake(rect.size.width, 0, rect.size.width, rect.size.height) animated:NO];
        }

        //換標簽
        NSInteger index = scrollView.contentOffset.x/rect.size.width;
        NSLog(@"換到第幾個標簽 -- %zd", index);
        [self changeLable:index];
        
        //連動下方scrollView
        CGRect bottomRect = self.scrollView.frame;
        [self.scrollView scrollRectToVisible:CGRectMake(bottomRect.size.width*currentButtonIndex, 0, bottomRect.size.width, bottomRect.size.height) animated:NO];

    }else {
        //下方內容ScrollView
        
        //切換ScrollView 做循環
        CGRect rect = self.scrollView.frame;
        if (scrollView.contentOffset.x == 0) {
            [scrollView scrollRectToVisible:CGRectMake(rect.size.width*(vcArray.count-2), 0, rect.size.width, rect.size.height) animated:NO];
        }else if(scrollView.contentOffset.x == rect.size.width*(vcArray.count-1)) {
            [scrollView scrollRectToVisible:CGRectMake(rect.size.width, 0, rect.size.width, rect.size.height) animated:NO];
        }
        
        [self changeLable:scrollView.contentOffset.x/rect.size.width];
        
        //連動上方按鈕ScrollView
        CGRect topRect = self.topButtonScrollView.frame;
        [self.topButtonScrollView scrollRectToVisible:CGRectMake(topRect.size.width*currentButtonIndex, 0, topRect.size.width, topRect.size.height) animated:NO];
        
        // for GA
        NSInteger index = (scrollView.contentOffset.x/rect.size.width);
        NSLog(@"buttonIdArray[%ld]", (long)index);
        
        NSString *categoryId = buttonIdArray[index];

        // GA -- 選擇標題
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        
        // 記畫面
        [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/news/category/%@",categoryId]];
        [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
        
        // 記事件
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/news/category/%@",categoryId]
                                                              action:@"button_press"
                                                               label:nil
                                                               value:nil] build]];
        
     
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.tag == 100) {
        CGRect rect = self.topButtonScrollView.frame;
        CGFloat offset = rect.size.width*currentButtonIndex - scrollView.contentOffset.x;
        //NSLog(@"位移量 -- (%f)", offset);
        
        //開始位移
        self.rightLabelConstraint.constant = 20 - offset;
        self.leftLabelConstraint.constant = 20 + offset;
        
        //位移大出畫面一半大就回到原點
        if (fabs(offset) >= rect.size.width/2) {
            self.rightLabelConstraint.constant = 20;
            self.leftLabelConstraint.constant = 20;
        }

    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 改變Label方法
-(void)changeLable:(NSInteger)currentIndex {
    
    currentButtonIndex = currentIndex;
    
    //左邊
    NSInteger i = currentIndex - 1;
    
    if (i < 0) {
        i = buttonNameArray.count-1;
    }
    
    NSString *strLeft = buttonNameArray[i];
    
    self.leftLabel.text = strLeft;
    
    //右邊
    NSInteger h = currentIndex + 1;
    
    if (h > buttonNameArray.count-1) {
        h = 0;
    }
    
    NSString *stRight = buttonNameArray[h];
    
    self.rightLabel.text = stRight;
}

@end
