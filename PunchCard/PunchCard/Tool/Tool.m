//
//  Tool.m
//  PunchCard
//
//  Created by 唐全 on 2021/4/23.
//

#import "Tool.h"
#import "KeyChainStore.h"

@implementation Tool

/**
 *获取当前时间戳有两种方法(以秒为单位)
 */
+(NSString *)getNowTimeTimestamp{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;

    [formatter setDateStyle:NSDateFormatterMediumStyle];

    [formatter setTimeStyle:NSDateFormatterShortStyle];

    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制

    //设置时区,这个对于时间的处理有时很重要

    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];

    [formatter setTimeZone:timeZone];

    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式

    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];

    return timeSp;

}

/**
 *时间戳转时间字符串
 */
+(NSString *)timestampSwitchTime:(NSString*)timestamp{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp.integerValue];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

/**
 *获取时间（其一天当天后一天前一天的ymd）
 */
+(NSString *)getDate:(dayis)days{
    NSDate *dates;
    if (days==dayis_last) {
        dates = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:[NSDate date]];//前一天
    }else if(days == dayis_next){
        dates = [NSDate dateWithTimeInterval:24*60*60 sinceDate:[NSDate date]];//后一天
    }else{
        dates = [NSDate date];//当前时间
    }
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSDate转NSString
    NSString *currentDateString = [dateFormatter stringFromDate:dates];
    return [currentDateString componentsSeparatedByString:@" "].firstObject;
}

/**
 *获取UUID
 */
+ (NSString *)getUUID{
    NSString * strUUID = (NSString *)[KeyChainStore load:@"com.company.app.usernamepassword"];
    //首次执行该方法时，uuid为空
    if ([strUUID isEqualToString:@""] || !strUUID)
    {
        //生成一个uuid的方法
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        
        //将该uuid保存到keychain
        [KeyChainStore save:KEY_USERNAME_PASSWORD data:strUUID];
        
    }
    return strUUID;
}
@end
