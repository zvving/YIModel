//
//  YIJSONModel
//  Baixing
//
//  Created by zengming on 13-8-20.
//
//

#import "YIModel.h"
#import <objc/runtime.h>
#import "NSObject+Properties.h"

@implementation YIModel

+ (instancetype)buildInstance {
    return [[[self class] alloc] init];
}

+ (NSDictionary*)parseFormat;
{
    @throw @"please implement it in subClass!";
    return nil;
}

+ (instancetype)modelFromDictionary:(NSDictionary*)dic;
{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    id modelInstance = [self buildInstance];

    NSDictionary *parseMap = [self parseFormat];
    [parseMap enumerateKeysAndObjectsUsingBlock:^(id modelKey, id map, BOOL *stop) {
        // obj 这个 key 是 stirng，并在 dic 中存在
        if ([map isKindOfClass:[NSString class]]) {
            id value = [dic valueForKeyPath:map];
            if (value) {
                [modelInstance setValue:value forKeyPath:modelKey];
            }
        } else if ([map isKindOfClass:[NSArray class]]) {
            NSArray *mapArray = map;
            NSString *jsonKey = mapArray[0];
            if ([dic objectForKey:jsonKey] == nil) {
                return;
            }
            id subJson = [dic valueForKeyPath:jsonKey];

            if ([mapArray[1] isKindOfClass:[NSArray class]]) {
                Class modelClass = [mapArray[1] lastObject];
                NSArray *tempModels = [modelClass modelsFromArray:subJson];
                [modelInstance setValue:tempModels forKeyPath:modelKey];
            } else {
                Class modelClass = mapArray[1];
                YIModel *tempModel = [modelClass modelFromDictionary:subJson];
                [modelInstance setValue:tempModel forKeyPath:modelKey];
            }
        }
    }];

    return modelInstance;
}

+ (NSArray*)modelsFromArray:(NSArray*)array;
{
    if ([array isKindOfClass:[NSArray class]] == NO) {
        return nil;
    }

    NSMutableArray *models = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dic in array) {
        id model = [[self class] modelFromDictionary:dic];
        if (model) {
            [models addObject:model];
        }
    }

    return models;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSArray *properties = [self propertyNames];
    NSObject *obj = nil;
    for (NSString* property in properties) {
        obj = [self valueForKey:property];
        [aCoder encodeObject:obj forKey:property];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    NSArray *properties = [self propertyNames];
    NSObject *obj = nil;
    for (NSString* propertyStr in properties) {
        obj = [aDecoder decodeObjectForKey:propertyStr];
        [self setValue:obj forKey:propertyStr];
    }
    return self;
}

#pragma mark - overwrite

/**
 *  KVO，Model 层面做数据兼容
 *  把 Json.value 数据都转成对应 Object.key 的数据类型
 *
 *  @param value
 *  @param key
 */
- (void)setValue:(id)value forKey:(NSString *)key {

    // value 区分处理 ===========================
    //排除恶心的 params 被赋值 NSNull 情况
    if ([value isKindOfClass:[NSNull class]]) {
        value = nil;
    }

    // key 区分处理 ===========================
    // 确保 value 类型与 model.key 的类型一致
    const char *type = [self typeOfPropertyNamed:key];
    if (strcmp(type, "T@\"NSString\"") == 0) {
        value = [value description];
    } else if (strcmp(type, "T@\"NSArray\"") == 0) {
        if ([value isKindOfClass:[NSArray class]] == NO) {
            value = nil;
        }
    } else if (strcmp(type, "T@\"NSDictionary\"") == 0) {
        if ([value isKindOfClass:[NSDictionary class]] == NO) {
            value = nil;
        }
    } else if (strcmp(type, "Tc") == 0) { //使之正常解析 BOOL
        value = value ?: @(0);
        if ([value isKindOfClass:[NSNumber class]] == NO) {
            value = @([[value description] intValue]);
        }
    } else if (strcmp(type, "Ti") == 0) { //使之正常解析 int
        if ([value isKindOfClass:[NSNumber class]] == NO) {
            value = @([[value description] intValue]);
        }
    } else if (strcmp(type, "Tf") == 0) { //使之正常解析 float
        if ([value isKindOfClass:[NSNumber class]] == NO) {
            value = @([[value description] floatValue]);
        }
    } else if (strcmp(type, "Td") == 0) { //使之正常解析 double
        if ([value isKindOfClass:[NSNumber class]] == NO) {
            value = @([[value description] doubleValue]);
        }
    }

    [super setValue:value forKey:key];
}

/**
 *  @return 更可读的 description
 */
- (NSString *)description {
    NSMutableString *desc = [NSMutableString stringWithFormat:@"<%@> desc ===== begin:\n", self.class];

    NSArray *showKeys = [[[self class] parseFormat] allKeys];

    NSString *valueDesc = nil;
    for (NSString* key in showKeys) {
        if (key.length == 0) {  // fix key: @""
            continue;
        }
        id value = [self valueForKeyPath:key] ?: @"<nil>";
        valueDesc = [value description];
        NSMutableString *tmp = [valueDesc mutableCopy];
        NSRange r;
        r.location = 0;
        r.length = valueDesc.length;
        if ([value isKindOfClass:[YIModel class]]) {
            [tmp replaceOccurrencesOfString:@"\n" withString:@"\n\t\t| "
                                    options:0
                                      range:r];
            valueDesc = tmp;
            [desc appendFormat:@"\t%@\t\t:\t<%@>\n\t\t| %@\n",
             key, [value class], valueDesc];
        } else {
            [tmp replaceOccurrencesOfString:@"\n" withString:@" "
                                    options:0
                                      range:r];
            [tmp replaceOccurrencesOfString:@"\t" withString:@" "
                                    options:0
                                      range:r];
            valueDesc = tmp;
            if (valueDesc.length > 100) {
                valueDesc = [NSString stringWithFormat:@"%@...",
                             [valueDesc substringToIndex:100]];
            }
            [desc appendFormat:@"\t%@\t\t:\t<%@> %@\n",
             key, [value class], valueDesc];
        }

    }

    [desc appendFormat:@"<%@> desc ===== end:\n", self.class];

    return desc;
}


- (id)copyWithZone:(NSZone *)zone
{
    id result = [[self class] allocWithZone:zone];

    NSArray *properties = [self propertyNames];
    NSObject *obj = nil;
    for (NSString* property in properties) {
        obj = [self valueForKey:property];
        if (obj) {
            [result setValue:obj forKey:property];
        }

    }
    return result;
}

@end
