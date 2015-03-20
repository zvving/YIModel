The project was Deprecated!   
Please use the better project that is [JsonModel](https://github.com/icanzilb/JSONModel).

YIModel
=======

A simple way to mapping JSON to NSObject(s).

![YIModel](https://raw.github.com/i0xbean/YIModel/master/Screenshots/YIModel.jpg)

# Feature
- Transform JSON to Model Instance in 1 line code;
- Property compatible with BOOL, int, float;
- Serializable, implemented `NSCoding`;
- Can clone, like `[oneObject copy]`, implemented `NSCopy`;

# Demo
### JSON   
```
{						// one User
	name: xiaoming,
	age: 26,
	best_friend: {		// other User
		name: xiaohong,
		age: 27,
	},
	books:[				// two Books
		{
			book_name: The Little Prince,
			price: 10
		},
		{
			book_name: Jobs,
			price: 50.5
		}	
	],
}
```
### Subclass

```
@interface User : YIModel			// Subclass from YIModel

@property (nonatomic, copy)     NSString *          name;
@property (nonatomic, assign)   int                 ageI;
@property (nonatomic, strong)   User *              bestFriend;
@property (nonatomic, strong)   NSArray *           booksArr;

@end

@implementation User

+ (NSDictionary *)parseFormat		// implemente it.
{
    return @{
             @"name"            : @"name",
             @"ageI"            : @"age",
             @"bestFriend"      : @[ @"best_friend", User.class ],
             @"booksArr"        : @[ @"books", @[ Book.class ] ],
             };
}

@end
```   

### Just Use It.   
```
User *user = [User modelFromDictionary:jsonUser];	// transform in 1 line.
// user.name 				=> @"xiaoming"
// user.bestFriend.name 	=> @"xiaohong"

Book *b0 = user.booksArr.firstObject;
// b0.name 					=> @"The Little Prince"
```

# One More Thing

### Implemented `NSCoding`&`NSCopy` yet
```
NSData *serializedUser [NSKeyedArchiver archivedDataWithRootObject:user];
// ok!

User *cloneUser = [user copy];
// ok!
```


# Others
- [JTObjectMapping](https://github.com/jamztang/JTObjectMapping)
- [NSObject-ObjectMap](https://github.com/uacaps/NSObject-ObjectMap)
- [RestKit](https://github.com/RestKit/RestKit)
