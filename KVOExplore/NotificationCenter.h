//
//  NotificationCenter.h
//  KVOExplore
//
//  Created by nucarf on 2020/11/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CallBack)(id argu);

@interface NotificationInfo : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) CallBack callBack;

@property (nonatomic, strong) id observer;
@property (nonatomic, strong) id infor;
@property (nonatomic, assign) SEL selector;

- (instancetype)initWithName:(NSString *)name observer:(id)observer selector:(SEL)selector;

@end

@interface NotificationCenter : NSObject

+ (instancetype)sharedInstanced;

- (void)addObserver:(id)observer selector:(SEL)selector name:(NSString *)name;

- (void)addObserver:(id)observer name:(NSString *)name callBlack:(void (^)(NotificationInfo *argu))callback;

- (void)postNotificationWithName:(NSString *)name object:(NSObject *)object;

- (void)removeObserver:(id)observer name:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
