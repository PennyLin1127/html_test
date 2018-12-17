//
//  CouponDetailViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/13.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "CouponDetailViewController.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"
#import "PerfectAPIManager.h"
#import "RSBarcodes.h"
#import "UseCouponViewController.h"

@interface CouponDetailViewController (){
    NSInteger currentCount;
    NSInteger totalCount;
}
@property (weak, nonatomic) IBOutlet AsyncImageView *asyncImageView;
@property (weak, nonatomic) IBOutlet UIImageView *barcodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *couponIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
- (IBAction)plusAction:(id)sender;
- (IBAction)subtractAction:(id)sender;
- (IBAction)confirmAction:(id)sender;

-(void)resizeAsyncImageFrame;

@end

@implementation CouponDetailViewController

#pragma mark - View生命週期
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setBackButton];
    
    //Data
    NSLog(@"self.dicData -- %@", self.dicData);
    NSString *couponId = [self.dicData objectForKey:@"COUPONID"];
    self.couponIdLabel.text = couponId;
    
    NSArray *tempArray;
    if (self.isForStore == YES) {
        NSLog(@"限門市使用");
        tempArray = [self.dicData objectForKey:@"DISCOUNTID"];
    }else {
        NSLog(@"共用折價劵");
        //2015-04-30 Henry 修改代碼為序號 DISCOUNTID
        tempArray = [self.dicData objectForKey:@"DISCOUNTID"];
    }
    
    currentCount = tempArray.count;
    totalCount = currentCount;
    
    self.numberLabel.text = [NSString stringWithFormat:@"%zd", currentCount];
    
    //image
    NSString *img = [self.dicData objectForKey:@"BIGIMG"];
    NSString *imgStr = [NSString stringWithFormat:@"%@%@", [IHouseURLManager getPerfectURLByAppName:COUPON_IMAGE_PREFIX], img];
    NSURL *url = [NSURL URLWithString:imgStr];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(AsyncImageLoadDidFinish:)
//                                                 name:@"AsyncImageLoadDidFinish"
//                                               object:nil];
//    
//    [self.asyncImageView setImageURL:url];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.asyncImageView setImage:image];
            float width1 = self.asyncImageView.frame.size.width;
            float height1 = image.size.height / (image.size.width / width1 );
            NSLog(@"height1:%f",height1);
            
            self.asyncImageView.frame = CGRectMake(self.asyncImageView.frame.origin.x, self.asyncImageView.frame.origin.y, width1, height1);
        });
    });

    NSLog(@"url -- %@", url);

//    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
//    UIImage *image = [[UIImage alloc] initWithData:data];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//    
//    UIGraphicsBeginImageContext(self.view.frame.size);
//    [image drawInRect:self.view.bounds];
//    UIImage *image1 = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    self.view.backgroundColor = [UIColor colorWithPatternImage:image1];
    
    //Barcode
    self.barcodeImageView.image = [CodeGen genCodeWithContents:couponId machineReadableCodeObjectType:AVMetadataObjectTypeCode39Code];

//    [self.asyncImageView setContentMode:UIViewContentModeScaleAspectFit];
}


//-(void)viewWillAppear:(BOOL)animated {
//    [self resizeAsyncImageFrame];
//    [super viewWillAppear:animated];
//}

-(void)viewDidAppear:(BOOL)animated{
    //Joseph 0602
    // add web view
    //image
    NSString *img = [self.dicData objectForKey:@"BIGIMG"];
    NSString *imgStr = [NSString stringWithFormat:@"%@%@", [IHouseURLManager getPerfectURLByAppName:COUPON_IMAGE_PREFIX], img];
    NSURL *url = [NSURL URLWithString:imgStr];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    self.webView.delegate=self;
    [self.webView loadRequest:requestObj];
}

- (void) AsyncImageLoadDidFinish:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
//    NSLog(@"image width: %f",self.asyncImageView.image.size.width);
//    NSLog(@"image height: %f",self.asyncImageView.image.size.height);
//       NSLog(@"asyncImageView height: %f",self.asyncImageView.frame.size.height);
//    Henry 2015-05-17 fixed scale problem
    NSLog(@"asyncImageView:%f x %f",self.asyncImageView.frame.size.width,self.asyncImageView.frame.size.height);
    NSLog(@"image: %f x %f",self.asyncImageView.image.size.width,self.asyncImageView.image.size.height);

    [self resizeAsyncImageFrame];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"AsyncImageLoadDidFinish"
                                                  object:nil];
    if ([[notification name] isEqualToString:@"AsyncImageLoadDidFinish"])
        NSLog (@"Successfully received the test AsyncImageLoadDidFinish!");
}

-(void)resizeAsyncImageFrame {
    if (self.asyncImageView.image != nil) {
        float width1 = self.asyncImageView.frame.size.width;
        float height1 = self.asyncImageView.image.size.height / (self.asyncImageView.image.size.width / width1 );
        NSLog(@"height1:%f",height1);
        
        self.asyncImageView.frame = CGRectMake(self.asyncImageView.frame.origin.x, self.asyncImageView.frame.origin.y, width1, height1);
    }
}
//
//-(void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
////    
//    NSLog(@"%@", NSStringFromCGRect(self.view.frame));
//    
//    NSString *img = [self.dicData objectForKey:@"DETAILIMG"];
//    NSString *imgStr = [NSString stringWithFormat:@"%@%@", [IHouseURLManager getPerfectURLByAppName:COUPON_IMAGE_PREFIX], img];
//    NSURL *url = [NSURL URLWithString:imgStr];
//
//    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
//    UIImage *image = [[UIImage alloc] initWithData:data];
//    
//    UIGraphicsBeginImageContext(self.view.frame.size);
//    [image drawInRect:self.view.bounds];
//    UIImage *image1 = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext(); // Add this line.
//    self.view.backgroundColor = [UIColor colorWithPatternImage:image1];
    
//    UIView *tempView = [[UIView alloc] initWithFrame:self.view.frame];
//    tempView.backgroundColor = [UIColor colorWithPatternImage:image1];
//    [self.view addSubview:tempView];
    
//    
//    
//}

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

#pragma mark - Button Event
- (IBAction)plusAction:(id)sender {
    
    NSInteger i = currentCount + 1;
    
    if (i > totalCount) {
        return;
    }else {
        currentCount = i;
        self.numberLabel.text = [NSString stringWithFormat:@"%zd", currentCount];
    }
}

- (IBAction)subtractAction:(id)sender {
    NSInteger i = currentCount -1;
    
    if (i <=0) {
        return;
    }else {
        currentCount = i;
        self.numberLabel.text = [NSString stringWithFormat:@"%zd", currentCount];
    }
}

- (IBAction)confirmAction:(id)sender {
    
    UIStoryboard *sb = self.storyboard;
    UseCouponViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UseCouponView"];
    vc.isForStore = self.isForStore;
    
    [self addChildViewController:vc];
    
    vc.dicData = self.dicData;
    vc.useCount = currentCount;
    
    [vc.view setBackgroundColor:[UIColor whiteColor]];
    vc.view.frame = CGRectMake(0, 0, 280, 220);
    vc.view.center = self.view.center;
    [vc.view.layer setBorderWidth:1];
    [vc.view.layer setBorderColor:[UIColor blackColor].CGColor];
    [vc.view.layer setCornerRadius:8];
    

    __weak CouponDetailViewController *tempVC = self;
    vc.finishCallBack = ^(){
        NSLog(@"init callback");        
        [tempVC.navigationController popViewControllerAnimated:YES];
    };
    
    [self.view addSubview:vc.view];
}
@end
