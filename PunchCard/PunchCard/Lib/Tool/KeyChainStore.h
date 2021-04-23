//
//  KeyChainStore.h
//  Template
//
//  Created by ky_mini on 2017/6/9.
//  Copyright © 2017年 KingYon. All rights reserved.
//
#define  KEY_USERNAME_PASSWORD @"com.company.app.usernamepassword"
#import <Foundation/Foundation.h>

@interface KeyChainStore : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteKeyData:(NSString *)service;

@end
