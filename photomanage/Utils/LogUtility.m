#import "LogUtility.h"

@interface LogUtility ()

@property (nonatomic, strong) dispatch_queue_t logQueue;
@property (nonatomic, copy) NSString *logFilePath;
@property (nonatomic, assign) NSInteger logFileIndex;

@end

@implementation LogUtility

+ (instancetype)sharedInstance {
    static LogUtility *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _logQueue = dispatch_queue_create("com.example.logQueue", DISPATCH_QUEUE_SERIAL);
        _logFileIndex = [self loadLogFileIndex];
        _logFilePath = [self currentLogFilePath];
        [self cleanupOldLogs];
    }
    return self;
}

- (void)logInfoWithTag:(NSString *)tag message:(NSString *)message {
    [self logWithLevel:@"INFO" tag:tag message:message];
}

- (void)logDebugWithTag:(NSString *)tag message:(NSString *)message {
    [self logWithLevel:@"DEBUG" tag:tag message:message];
}

- (void)logErrorWithTag:(NSString *)tag message:(NSString *)message {
    [self logWithLevel:@"ERROR" tag:tag message:message];
}

- (void)logWarningWithTag:(NSString *)tag message:(NSString *)message {
    [self logWithLevel:@"WARNING" tag:tag message:message];
}

- (void)logWithLevel:(NSString *)level tag:(NSString *)tag message:(NSString *)message {
    dispatch_async(self.logQueue, ^{
        NSString *logMessage = [NSString stringWithFormat:@"%@ [%@][%@]: %@", [NSDate date], level, tag, message];
        
        // 输出到控制台
        NSLog(@"%@", logMessage);
        
        // 仅写入 INFO 级别及以上的日志
        if ([level isEqualToString:@"INFO"] || [level isEqualToString:@"WARNING"] || [level isEqualToString:@"ERROR"]) {
            [self writeLogToFile:logMessage];
        }
    });
}

- (NSString *)currentLogFilePath {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"app_%ld.log", (long)self.logFileIndex]];
}

- (void)writeLogToFile:(NSString *)message {
    NSString *logEntry = [NSString stringWithFormat:@"%@\n", message];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.logFilePath];
    
    if (fileHandle) {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[logEntry dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    } else {
        [logEntry writeToFile:self.logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    [self checkLogFileSizeAndRotate];
}

- (void)checkLogFileSizeAndRotate {
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.logFilePath error:nil];
    NSNumber *fileSize = attributes[NSFileSize];
    
    if (fileSize && [fileSize longLongValue] > 5 * 1024 * 1024) { // 大于 5 MB
        [self rotateLogFile];
    }
}

- (void)rotateLogFile {
    self.logFileIndex += 1;
    [self saveLogFileIndex];
    self.logFilePath = [self currentLogFilePath];
    
    // 创建新日志文件
    [@"" writeToFile:self.logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSInteger)loadLogFileIndex {
    NSString *indexPath = [self logIndexFilePath];
    NSString *indexString = [NSString stringWithContentsOfFile:indexPath encoding:NSUTF8StringEncoding error:nil];
    return indexString ? [indexString integerValue] : 0;
}

- (void)saveLogFileIndex {
    NSString *indexPath = [self logIndexFilePath];
    NSString *indexString = [NSString stringWithFormat:@"%ld", (long)self.logFileIndex];
    [indexString writeToFile:indexPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)logIndexFilePath {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentsDirectory stringByAppendingPathComponent:@"log_index.txt"];
}

- (void)cleanupOldLogs {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    for (NSString *file in files) {
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:file];
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:nil];
        NSDate *creationDate = attributes[NSFileCreationDate];
        
        if ([[NSDate date] timeIntervalSinceDate:creationDate] > 3 * 24 * 60 * 60) { // 3天
            [fileManager removeItemAtPath:filePath error:nil];
        }
    }
}

@end
