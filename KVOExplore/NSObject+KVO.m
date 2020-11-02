//
//  NSObject+KVO.m
//  KVOExplore
//
//  Created by nucarf on 2020/10/30.
//

#import "NSObject+KVO.h"
#import <objc/message.h>

static NSString *const kKVOPrefix = @"KVONotifying_";
static NSString *const kKVOAssiociateKey = @"kKVO_AssiociateKey";

@interface KVOInfo : NSObject

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) KVOBlock handleBlock;

@end

@implementation KVOInfo

- (instancetype)initWitObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath handleBlock:(KVOBlock)block {
    if (self = [super init]) {
        _observer = observer;
        _keyPath = keyPath;
        _handleBlock = block;
    }
    return self;
}

@end

@implementation NSObject (KVO)

//MARK: - C 函数
// - 从get方法获取set方法的名称 key ===>>> setKey:
static NSString * setterForGetter(NSString * getter) {
    if (getter.length <= 0) {
        return nil;
    }

    NSString *firstString = [[getter substringToIndex:1] uppercaseString];
    NSString *leaveString = [getter substringFromIndex:1];

    return [NSString stringWithFormat:@"set%@%@:", firstString, leaveString];
}

// - 从set方法获取getter方法的名称 set<Key>:===> key
static NSString * getterForSetter(NSString *setter)
{
    if (setter.length <= 0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
    }

    NSRange range = NSMakeRange(3, setter.length - 4);
    NSString *getter = [setter substringWithRange:range];
    NSString *firstString = [[getter substringToIndex:1] lowercaseString];
    return [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstString];
}

// 重点. 重写setter方法
static void kvo_setter(id self, SEL _cmd, id newValue)
{
    NSString *keyPath = getterForSetter(NSStringFromSelector(_cmd));
    id oldValue = [self valueForKey:keyPath];
    //  消息转发 : 转发给父类
    // 改变父类的值 --- 可以强制类型转换
    void (*kvo_msgSendSuper)(void *, SEL, id) = (void *)objc_msgSendSuper;
    // void /* struct objc_super *super, SEL op, ... */
    struct objc_super superStruct = {
        .receiver    = self,
        .super_class = class_getSuperclass(object_getClass(self)),
    };
    //objc_msgSendSuper(&superStruct,_cmd,newValue)
    kvo_msgSendSuper(&superStruct, _cmd, newValue);

    // 信息数据回调
    NSMutableArray *mArray = objc_getAssociatedObject(self, (__bridge const void *_Nonnull)(kKVOAssiociateKey));

    for (KVOInfo *info in mArray) {
        if ([info.keyPath isEqualToString:keyPath] && info.handleBlock) {
            info.handleBlock(info.observer, keyPath, oldValue, newValue);
        }
    }
}

// 重写class方法，为了与系统类对外保持一致
Class kvo_class(id self, SEL _cmd)
{
    return class_getSuperclass(object_getClass(self));
}

static void kvo_dealloc(id self, SEL _cmd)
{
    Class superClass = [self class];
    object_setClass(self, superClass);
}

//MARK: - 自定义KVO
- (void)kvo_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(KVOBlock)block {
    //1. 验证setter是否存在
    [self judgeSetterMethodFromKeyPath:keyPath];
    //2. 动态生成之类
    Class newClass = [self createChildClassWithKeyPath:keyPath];
    //3. 修改isa指向 KVONotifying_XX
    object_setClass(self, newClass);

    //4. 保存信息
    KVOInfo *info = [[KVOInfo alloc] initWitObserver:observer forKeyPath:keyPath handleBlock:block];
    NSMutableArray *mArray = objc_getAssociatedObject(self, (__bridge const void *_Nonnull)(kKVOAssiociateKey));
    if (!mArray) {
        mArray = [NSMutableArray arrayWithCapacity:1];
        objc_setAssociatedObject(self, (__bridge const void *_Nonnull)(kKVOAssiociateKey), mArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [mArray addObject:info];
}

//2. 动态生成子类
- (Class)createChildClassWithKeyPath:(NSString *)keyPath {
    NSString *oldClassName = NSStringFromClass([self class]);
    NSString *newClassName = [NSString stringWithFormat:@"%@%@", kKVOPrefix, oldClassName];
    Class newClass = NSClassFromString(newClassName);
    if (newClass) return newClass;
    //2.1 申请类
    newClass = objc_allocateClassPair([self class], newClassName.UTF8String, 0);
    //2.2 注册
    objc_registerClassPair(newClass);
    //2.3 添加方法 属性 -ivar -ro

    // 2.3.1 : 添加class : class的指向是Person
    SEL classSEL = NSSelectorFromString(@"class");
    Method classMethod = class_getInstanceMethod([self class], classSEL);
    const char *classTypes = method_getTypeEncoding(classMethod);
    class_addMethod(newClass, classSEL, (IMP)kvo_class, classTypes);
    // 2.3.2 : 添加setter
    SEL setterSEL = NSSelectorFromString(setterForGetter(keyPath));
    Method setterMethod = class_getInstanceMethod([self class], setterSEL);
    const char *setterTypes = method_getTypeEncoding(setterMethod);
    class_addMethod(newClass, setterSEL, (IMP)kvo_setter, setterTypes);
    // 2.3.3 : 添加dealloc
    SEL deallocSEL = NSSelectorFromString(@"dealloc");
    Method deallocMethod = class_getInstanceMethod([self class], deallocSEL);
    const char *deallocTypes = method_getTypeEncoding(deallocMethod);
    class_addMethod(newClass, deallocSEL, (IMP)kvo_dealloc, deallocTypes);

    return newClass;
}

//1. 判断setter方法是否存在
- (void)judgeSetterMethodFromKeyPath:(NSString *)keyPath {
    Class superClass = object_getClass(self);

    NSString *setterMethodName = setterForGetter(keyPath);
    SEL setterSEL = NSSelectorFromString(setterMethodName);
    Method setterMethod = class_getInstanceMethod(superClass, setterSEL);

    if (!setterMethod) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"没有%@的set方法", keyPath] userInfo:nil];
    }
}

- (void)kvo_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    NSMutableArray *observerArr = objc_getAssociatedObject(self, (__bridge const void *_Nonnull)(kKVOAssiociateKey));
    if (observerArr.count <= 0) {
        return;
    }

    for (KVOInfo *info in observerArr) {
        if ([info.keyPath isEqualToString:keyPath]) {
            [observerArr removeObject:info];
            objc_setAssociatedObject(self, (__bridge const void *_Nonnull)(kKVOAssiociateKey), observerArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            break;
        }
    }

    if (observerArr.count <= 0) {
        // 指回给父类
        Class superClass = [self class];
        object_setClass(self, superClass);
    }
}

//MARK: - 自动销毁机制
+ (BOOL)kvo_hookOrigInstanceMenthod:(SEL)oriSEL newInstanceMenthod:(SEL)swizzledSEL {
    Class cls = self;
    Method oriMethod = class_getInstanceMethod(cls, oriSEL);
    Method swiMethod = class_getInstanceMethod(cls, swizzledSEL);

    if (!swiMethod) {
        return NO;
    }
    if (!oriMethod) {
        class_addMethod(cls, oriSEL, method_getImplementation(swiMethod), method_getTypeEncoding(swiMethod));
        method_setImplementation(swiMethod, imp_implementationWithBlock(^(id self, SEL _cmd) { }));
    }

    BOOL didAddMethod = class_addMethod(cls, oriSEL, method_getImplementation(swiMethod), method_getTypeEncoding(swiMethod));
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSEL, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, swiMethod);
    }
    return YES;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self kvo_hookOrigInstanceMenthod:NSSelectorFromString(@"dealloc") newInstanceMenthod:@selector(myDealloc)];
    });
}

- (void)myDealloc {
    Class superClass = [self class];
    object_setClass(self, superClass);
    [self myDealloc];
}

@end
