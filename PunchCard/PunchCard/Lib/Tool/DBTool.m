//
//  DBTool.m
//  PunchCard
//
//  Created by 唐全 on 2021/4/23.
//

#import "DBTool.h"
#import "Tool.h"
#import "CalendarModel.h"

@interface DBTool ()
@end
@implementation DBTool

static DBTool *_shareInstance = nil;
+ (instancetype)shareInstance{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _shareInstance = [[DBTool alloc] init];
        NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fileName = [doc stringByAppendingPathComponent:@"collect.sqlite"];
        _shareInstance.db = [FMDatabase databaseWithPath:fileName];
    });
    return _shareInstance;
}
- (void)CreateChart:(NSString *)createStatement{
    if ([_db open]) {
        BOOL result =
        [_db executeUpdate:[NSString stringWithFormat:@"%@", createStatement]];
        if (result) {
            NSLog(@"成功创建创建表：%@",createStatement);
        }else{
            NSLog(@"创建创建表：%@失败",createStatement);
        }
    }
};

- (NSArray*)sqChart:(NSString*)chartnameStr byCalendarTime:(NSString*)timeStr{
    if ([_db open]) {
        NSString *query = [NSString stringWithFormat:@"select * from %@ where calendartime = '%@'", chartnameStr,timeStr];
        FMResultSet *rs = [self.db executeQuery:query];
        NSMutableArray *invArray = [NSMutableArray array];
        while ([rs next]) {
            CalendarModel *ml = [[CalendarModel alloc]init];
            ml.times_id = [rs stringForColumn:@"calendartime"];
            ml.detailtime = [rs stringForColumn:@"detailtime"];
            ml.continuedays = [rs stringForColumn:@"continuosusday"];
            ml.show_name = chartnameStr;
            [invArray addObject:ml];
        }
        return invArray;
    }else{
        return nil;
    }
}

- (NSArray *)sqChart:(NSString*)chartName{
    if ([_db open]) {
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@",chartName];
        FMResultSet *resultSet = [self.db executeQuery:query];
        NSMutableArray *Arr = [NSMutableArray array];
        while ([resultSet next]) {
            CalendarModel *ml = [[CalendarModel alloc]init];
            ml.times_id = [resultSet stringForColumn:@"calendartime"];
            ml.detailtime = [resultSet stringForColumn:@"detailtime"];
            ml.continuedays = [resultSet stringForColumn:@"continuosusday"];
            ml.show_name = chartName;
            [Arr addObject:ml];
        }
        return  Arr;
    }else{
        return nil;
    }
}

- (void)insertChart:(NSString*)chartnameStr byCalendarTime:(NSArray*)timeArr andcontinuedays:(NSString*)continuedays{
    if ([_db open]) {
        FMResultSet *resultSet = [self.db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",chartnameStr]];
        NSMutableArray *temparr = [NSMutableArray array];
        while ([resultSet next]) {
            [temparr addObject:[resultSet stringForColumn:@"calendartime"]];
        }
        for (NSString *timeStr in timeArr) {
            NSString *ymd = [[Tool timestampSwitchTime:timeStr] componentsSeparatedByString:@" "].firstObject;
            [self.db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (calendartime,detailtime,continuosusday) VALUES (?,?,?);",chartnameStr],ymd,timeStr,continuedays];
        }
        [_db close];
    }
}
- (void)deletedatafromeChart:(NSString *)chartnameStr byCalendarTime:(NSArray*)timeArr{
    if ([_db open]) {
        for (NSString *timeStr in timeArr) {
            NSString *str = [NSString stringWithFormat:@"DELETE FROM %@ WHERE detailtime = %@",chartnameStr,timeStr];
            BOOL res = [_db executeUpdate:str];
            if (!res) {
                NSLog(@"数据删除失败");
            } else {
                NSLog(@"数据删除成功");
            }
        }
        [_db close];
    }
}
@end
