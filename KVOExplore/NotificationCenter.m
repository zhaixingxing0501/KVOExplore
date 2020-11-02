//
//  NotificationCenter.m
//  KVOExplore
//
//  Created by nucarf on 2020/11/2.
//

#import "NotificationCenter.h"

static NotificationCenter *manager = nil;

typedef void (^hander)(id argu);

@implementation NotificationInfo

- (instancetype)initWithName:(NSString *)name observer:(id)observer selector:(SEL)selector
{
    self = [super init];
    if (self) {
        self.name = name;
        self.selector = selector;
        self.observer = observer;
    }
    return self;
}

@end

@interface NotificationCenter ()

@property (nonatomic, strong) NSMutableDictionary *notificationInfo;

@end

@implementation NotificationCenter

+ (instancetype)sharedInstanced {
    return [[self alloc] init];
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super init];
    });
    return manager;
}

- (void)notificationInfoWithName:(NSString *)name observer:(id)observer callBack:(id)callBack selector:(SEL)selector {
    NotificationInfo *info = [[NotificationInfo alloc] initWithName:name observer:observer selector:selector];
    info.callBack = callBack;

    NSArray *keys = self.notificationInfo.allKeys;
    NSMutableArray *arr;

    if ([keys containsObject:name]) {
        arr = [[self.notificationInfo objectForKey:name] mutableCopy];
        [arr addObject:info];
    } else {
        arr = [NSMutableArray array];
        [arr addObject:info];
    }

    [self.notificationInfo setValue:arr forKey:name];
}

- (void)addObserver:(id)observer selector:(SEL)selector name:(NSString *)name {
    [self notificationInfoWithName:name observer:observer callBack:nil selector:selector];
}

- (void)addObserver:(id)observer name:(NSString *)name callBlack:(void (^)(NotificationInfo *argu))callback {
    [self notificationInfoWithName:name observer:observer callBack:callback selector:nil];
}

- (void)postNotificationWithName:(NSString *)name object:(NSObject *)object {
    NSMutableArray *arr = [self.notificationInfo objectForKey:name];

    for (NotificationInfo *info in arr) {
        if (info.callBack) {
            info.callBack(info);
        }

        if ([info.observer respondsToSelector:info.selector]) {
            ((void (*)(id, SEL, NotificationInfo *))[info.observer methodForSelector:info.selector])(info.observer, info.selector, info);
//            [info.observer performSelector:info.selector withObject:info];
        }
    }
}

- (void)removeObserver:(id)observer name:(NSString *)name {
    NSArray *arr = [[self.notificationInfo objectForKey:name] mutableCopy];
    NSMutableArray *tmp = [NSMutableArray arrayWithArray:arr];

    for (NotificationInfo *obj in arr) {
        if (obj.observer == observer) {
            [tmp removeObject:obj];

            if (tmp.count > 0) {
                [self.notificationInfo setValue:tmp forKey:name];
            } else {
                [self.notificationInfo removeObjectForKey:name];
            }
        }
    }
}

- (void)removeName:(NSString *)name {
    [self.notificationInfo removeObjectForKey:name];
}

- (NSMutableDictionary *)notificationInfo {
    if (!_notificationInfo) {
        _notificationInfo = [NSMutableDictionary dictionary];
    }
    return _notificationInfo;
}

@end
