//
//  HJModel.h
//  Baixing
//
//  Created by zengming on 13-8-20.
//
//  继承自 HJModel，获取如下能力
//      json->object mapping
//      NSCoding

#import <Foundation/Foundation.h>

@interface YIModel : NSObject <NSCoding, NSCopying>

/**
 *  生成对象实例
 *
 *  @return 相应类型实例
 */
+ (instancetype)buildInstance;

/**
 *  !!!子类须重写此方法!!! 提供 json->object 的解析规则
 *
 *  @return NSDictionary 表达的对应解析关系
 */
+ (NSDictionary*)parseFormat;

/**
 *  json->object
 *
 *  @param dic json, 非 NSDictionary 类型时返回 nil
 *  @return 对应类型的 Object, 可能为 nil
 */
+ (instancetype)modelFromDictionary:(NSDictionary*)dic;

/**
 *  json(array)->object(array)
 *
 *  array 中每一项必须为 Dictionary, 否则解析时跳过
 *
 *  @param array json(array) 非 array 类型时返回 nil
 *  @return 对应类型的 Object array , 可能为 empty array, nil
 */
+ (NSArray*)modelsFromArray:(NSArray*)array;

@end
