//
//  CompareListDelegate.h
//  HOLA
//
//  Created by Joseph on 2015/5/4.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProductCompareDelegate
@required
-(void)productSelected:(NSString *)productID;
@end


@interface CompareListDelegate : NSObject

@end
