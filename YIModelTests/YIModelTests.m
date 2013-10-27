//
//  YIModelTests.m
//  YIModelTests
//
//  Created by zengming on 10/27/13.
//
//

#import <XCTest/XCTest.h>

#import "YIModel.h"


@interface Book : YIModel

@property (nonatomic, strong)   NSString *          bookName;
@property (nonatomic, assign)   float               price;

@end

@implementation Book

+ (NSDictionary *)parseFormat
{
    return @{
             @"bookName"    : @"book_name",
             @"price"       : @"price",
             };
}

@end



@interface User : YIModel

@property (nonatomic, copy)     NSString *          name;
@property (nonatomic, assign)   int                 age;
@property (nonatomic, assign)   float               weight;
@property (nonatomic, assign)   BOOL                isMarried;
@property (nonatomic, strong)   NSNumber *          money;
@property (nonatomic, strong)   NSArray *           toolsArr;
@property (nonatomic, strong)   NSDictionary *      userInfoDic;
@property (nonatomic, strong)   User *              bestFriend;
@property (nonatomic, strong)   NSArray *           booksArr;       // @[ Book0, Book1 ]

@end

@implementation User

+ (NSDictionary *)parseFormat
{
    return @{
             @"name"            : @"name",
             @"age"             : @"age",
             @"weight"          : @"weight",
             @"isMarried"       : @"married",
             @"money"           : @"money",
             @"toolsArr"        : @"tools",
             @"userInfoDic"     : @"user_info",
             @"bestFriend"      : @[ @"best_friend", User.class ],
             @"booksArr"        : @[ @"books", @[ Book.class ] ],
             };
}

@end



@interface YIModelTests : XCTestCase

@property (nonatomic, strong) NSArray *jsonUsers;

@end

@implementation YIModelTests

- (void)setUp
{
    [super setUp];

    self.jsonUsers = @[
                       @{
                           @"name"      : @"xiaoming",
                           @"age"       : @26,
                           @"weight"    : @66.2,
                           @"married"   : @(YES),
                           @"money"     : @10000.999,
                           @"tools"     : @[ @"item1", @"item2", @3, @4.4],
                           @"user_info"  : @{ @"k1":@"v1", @"k2":@"v2"},
                           @"best_friend": @{
                                   @"name"      : @"xiaohong",
                                   @"age"       : @28,
                                   @"weight"    : @66.2,
                                   @"married"   : @(NO),
                                   @"money"     : @10000.999,
                                   @"tools"     : @[ @"item1", @"item2", @3, @4.4],
                                   @"user_info"  : @{ @"k1":@"v1", @"k2":@"v2"},
                                   @"best_friend": @"xiaoming",
                                   },
                           @"books"     : @[
                                   @{
                                       @"book_name" : @"追风筝的人",
                                       @"price" : @99,
                                       },
                                   @{
                                       @"book_name" : @"The Little Prince",
                                       @"price" : @10,
                                       },
                                   @{
                                       @"book_name" : @"Jobs",
                                       @"price" : @"50.5",
                                       }
                                   ],
                           @"spilth"    : @"sth.",
                           },
                       @{
                           @"name"      : @"error data",
                           @"age"       : @"26a",
                           @"weight"    : @66.2,
                           @"money"     : [NSNull new],
                           @"tools"     : @{ @"er" : @"r", @"o" : @"r" },
                           @"user_info"  : @[ @"err", @"or"],
                           @"best_friend": @[ @1, @2 ],
                           @"books"     : @[],
                           @"spilth"    : @"sth.",
                           },
                       ];
}

- (void)tearDown
{

    [super tearDown];
}

- (void)testExample
{
    NSArray *users = [User modelsFromArray:_jsonUsers];
    NSLog(@"%@...", users);
    
    for (User *u in users) {
        XCTAssertTrue([u isKindOfClass:[User class]], @"item class is User");
        for (Book *b in u.booksArr) {
             XCTAssertTrue([b isKindOfClass:[Book class]], @"user.booksArr class is Book");
        }
    }
}

@end
