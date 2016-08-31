//
//  ZRSqllib.m
//  Demo
//
//  Created by Ryan on 16/4/1.
//  Copyright © 2016年 monkey. All rights reserved.
//

#import "ZRSqlHelper.h"
#import <sqlite3.h>

@interface ZRSqlHelper ()
/** 数据库对象 */
//@property (nonatomic, weak) sqlite3 *db;
/** 数据库名称 */
@property (nonatomic, copy) NSString *dbName;
@end

@implementation ZRSqlHelper

#define DATABASE @"JetMaster.sqlite"

static sqlite3 *_db;

- (id)initWithDBName:(NSString *)dbname {
    if (self = [super init]) {
        if ([self openDatabase:dbname]) {
            [self closeDatabase];
        }
    }
    return self;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static ZRSqlHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

+ (instancetype)shareSqlHelper {
    return [[self alloc] initWithDBName:DATABASE];
}

- (NSString *)readyDatabase {
    static NSString *dbName = @"JetMaster.sqlite";
    
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *writeDBPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, dbName];
    success = [fileManager fileExistsAtPath:writeDBPath];
    if (!success) {
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:writeDBPath error:&error];
    }
    NSLog(@"%@", writeDBPath);
    return writeDBPath;
}


/**
 *  打开数据库，数据库文件不存在，自动创建，并自动创建目录
 *
 *  @param dbName 数据库名
 */
- (BOOL)openDatabase:(NSString *)dbName {
    self.dbName = dbName;
    
//    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *document = [path firstObject];
//    NSString *filename = [document stringByAppendingPathComponent:dbName];

    NSString *dataFilePath = [self readyDatabase];
//
    int result = sqlite3_open([dataFilePath UTF8String], &_db);
    if (result != SQLITE_OK) {
        NSLog(@"数据库创建失败");
        return NO;
    }
    NSLog(@"数据库打开（创建）成功");
    return YES;
}

/**
 *  关闭数据库
 */
- (void)closeDatabase {
    sqlite3_close(_db);
}

/**
 *  创建表
 *
 *  @param sql 创建表sql语句
 *
 *  @return 是否创建成功
 */
- (BOOL)createTable:(NSString *)sql {
    if (![self openDatabase:self.dbName]) {
        return NO;
    }
    char *errorMsg = NULL;
    int result = sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &errorMsg);
    if (result != SQLITE_OK) {
        NSLog(@"表创建失败:%s",errorMsg);
        return NO;
    }
    NSLog(@"表创建成功");
    [self closeDatabase];
    return YES;
}


/**
 *  插入数据
 *
 *  @param sql sql语句
 *
 *  @return 是否插入成功
 */
- (BOOL)insertWithSql:(NSString *)sql {
    if (![self openDatabase:self.dbName]) {
        return NO;
    }
    char *errorMsg = NULL;
    int result = sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &errorMsg);
    if (result != SQLITE_OK) {
        NSLog(@"插入失败:%s",errorMsg);
        return NO;
    }
    NSLog(@"插入成功");
    [self closeDatabase];
    return YES;
}


/**
 *  更新数据
 *
 *  @param sql sql语句
 *
 *  @return 是否更新成功
 */
- (BOOL)updateWithSql:(NSString *)sql {
    if (![self openDatabase:self.dbName]) {
        return NO;
    }
    char *errorMsg = NULL;
    int result = sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &errorMsg);
    if (result != SQLITE_OK) {
        NSLog(@"更新失败:%s",errorMsg);
        return NO;
    }
    NSLog(@"更新成功");
    [self closeDatabase];
    return YES;
}

/**
 *  删除数据
 *
 *  @param sql sql语句
 *
 *  @return 是否更新成功
 */
- (BOOL)deleteWithSql:(NSString *)sql {
    if (![self openDatabase:self.dbName]) {
        return NO;
    }
    char *errorMsg = NULL;
    int result = sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &errorMsg);
    if (result != SQLITE_OK) {
        NSLog(@"删除失败:%s",errorMsg);
        return NO;
    }
    NSLog(@"删除成功");
    [self closeDatabase];
    return YES;
}

/**
 *  查询数据
 *
 *  @param sql sql语句
 *
 *  @return 查询结果
 */
- (NSArray *)queryWithSql:(NSString *)sql {
    if (![self openDatabase:self.dbName]) {
        return nil;
    }
    
    
    // 2. 定义一个stmt存放结果集
    sqlite3_stmt *stmt = NULL;
    
    
    NSMutableArray *arrM = [NSMutableArray array];
    // 3. 检测sql语句的合法性
    int result = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &stmt, NULL);// - 1:自动计算sql语句长度
    if (result == SQLITE_OK) {
        NSLog(@"查询语句是合法的");
        
        while (sqlite3_step(stmt) == SQLITE_ROW) { // 真的查询到一条数据
            int count = sqlite3_column_count(stmt);
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            for (int i = 0; i < count; i ++) {
                NSString *columnValue = [NSString stringWithUTF8String:sqlite3_column_text(stmt, i)];
                NSString *columName = [NSString stringWithUTF8String:sqlite3_column_name(stmt, i)];
                [dict setValue:columnValue forKey:columName];
            }
            [arrM addObject:dict];
        }
    }
    else{
        NSLog(@"查询语句是不合法的");
        return nil;
    }
    sqlite3_finalize(stmt);
    [self closeDatabase];
    return arrM;
    
    
    // 以下方式造成内存泄漏
//
//    int row = 0;
//    int column = 0;
//    char *errorMsg = NULL;
//    char ** dbResult = NULL;
//    NSMutableArray *arrM = [NSMutableArray array];
//    if (sqlite3_get_table(_db, [sql UTF8String], &dbResult, &row, &column, &errorMsg) == SQLITE_OK) {
//        if (0 == row) {
//            [self closeDatabase];
//            return nil;
//        }
//        
//        int index = column;
//        for (int i = 0; i < row; i ++) {
//            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
//            for (int j = 0; j < column; j ++) {
//                if (dbResult[index]) {
//                    NSString *value = [[NSString alloc] initWithUTF8String:dbResult[index]];
//                    NSString *key = [[NSString alloc] initWithUTF8String:dbResult[j]];
//                    [dictM setValue:value forKey:key];
//                }
//                index ++;
//            }
//            [arrM addObject:dictM];
//        }
//    } else {
//        NSLog(@"查询失败%s", errorMsg);
//        [self closeDatabase];
//        return nil;
//    }
//    
//    [self closeDatabase];
//    return arrM;
}

//int processData(void *arrResult, int columnCount, char ** columnValue, char** columnName) {
//    int i;
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    for (int i = 0; i < columnCount; i ++) {
//        if (columnValue[i]) {
//            NSString *key = [[NSString alloc] initWithUTF8String:columnName[i]];
//            NSString *value = [[NSString alloc] initWithUTF8String:columnValue[i]];
//    }
//     [(__bridge NSMutableArray*)arrResult addObject:dict];
//        return 0;
//}
//
//- (NSArray *)queryTableByCallBackWithSql:(NSString *)sql {
//    if (![self openDatabase:self.dbName]) {
//        return nil;
//    }
//    char *errorMsg = NULL;
//    NSMutableArray *arrM = [NSMutableArray array];
//    if (sqlite3_exec(self.m_sql,[sqlQuerryUTF8String],processData,(void*)arrayResult,&errorMsg) !=SQLITE_OK)
//    {
//        printf("查询出错:%s",errorMsg);
//    }
//    [selfcloseDatabase];
//    return arrayResult;
//}

@end
