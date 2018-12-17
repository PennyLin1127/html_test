//
//  CouponBigImageViewController.m
//  HOLA
//
//  Created by Jimmy Liu on 2015/5/21.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "CouponBigImageViewController.h"

@interface CouponBigImageViewController () {
    UIImageView *imageView;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation CouponBigImageViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self holaBackCus];
    NSLog(@"圖片的聯結 -- %@", self.urlStr);
    
    //delegate
    self.scrollView.delegate = self;
   
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
    NSURL *url = [NSURL URLWithString:self.urlStr];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            float width1 = self.view.frame.size.width;
            float height1 = image.size.height / (image.size.width / width1 );
            NSLog(@"height1:%f",height1);
            
            CGRect rect = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, width1, height1);

            self.scrollView.contentSize = rect.size;
            imageView = [[UIImageView alloc] initWithFrame:rect];
            [imageView setImage:image];

            [self.scrollView addSubview:imageView];

        });
    });

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Back Buton
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

#pragma mark - ScrollView delegate 
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}
@end
