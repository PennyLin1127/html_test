//
//  NSData+AES.h
//  eBook
//
//  Created by Perfect on 13/10/3.
//  Copyright (c) 2013年 Taitra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES)

- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;

@end
