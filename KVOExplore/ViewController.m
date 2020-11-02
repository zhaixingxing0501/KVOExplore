//
//  ViewController.m
//  KVOExplore
//
//  Created by nucarf on 2020/10/30.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "Person.h"

#define NSLog(fmt, ...) fprintf(stderr, "%s\n", [[NSString stringWithFormat:fmt, ## __VA_ARGS__] UTF8String])

@interface ViewController ()

@property (nonatomic, strong) Person *person;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.person = [Person new];
    //context:(nullable void *) void * 类型 用NULL
//    [self.person addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];

    self.person.name = @"+";
    self.person.totalData = 100;
    self.person.writeData = 0;

    [self.person addObserver:self forKeyPath:@"dataArray" options:NSKeyValueObservingOptionNew context:NULL];

    [self.person addObserver:self forKeyPath:@"downloadProgress" options:NSKeyValueObservingOptionNew context:NULL];

    self.person.dataArray = [NSMutableArray array];
    [[self.person mutableArrayValueForKey:@"dataArray"] addObject:@"1"];

//    [self.person kvo_addObserver:self forKeyPath:@"name" block:^(id _Nonnull observer, NSString *_Nonnull keyPath, id _Nonnull oldValue, id _Nonnull newValue) {
//        NSLog(@"新值:%@\n", newValue);
//    }];
}

- (IBAction)modifiedValue:(UIButton *)sender {
    self.person.name = [NSString stringWithFormat:@"%@+", self.person.name];

    [[self.person mutableArrayValueForKey:@"dataArray"] addObject:@"1"];
    self.person.totalData += 1;
    self.person.writeData += 1;
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"监听方法:%@", change);
    
    NSLog(@"%@, %@", self.person.dataArray, self.person.downloadProgress);
}

- (IBAction)removeObserve:(UIButton *)sender {
    [self.person removeObserver:self forKeyPath:@"name"];
    NSLog(@"观察者移除成功");
}

- (void)dealloc {
    [self.person removeObserver:self forKeyPath:@"name"];
}

@end
