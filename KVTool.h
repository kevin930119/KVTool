//
//  KVTool.h
//  BodyIntellect1.2
//
//  Created by 知子花 on 16/1/15.
//  Copyright © 2016年 知子花. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KVTool : NSObject

#pragma mark - runtime利用字典对模型进行赋值，可以兼容对象属性与字典映射不成立的情况
+ (id)getModelWithModelClass:(Class)modelClass dataDict:(NSDictionary*)dataDict keyDict:(NSDictionary*)keyDict;
#pragma mark - 截屏
+ (UIImage*)screenView:(UIView *)view;

+(NSInteger)getNetWorkStates;

#pragma mark - 提示框弹出消失的动画
+ (void)flyInWithView:(UIView*)view;

+ (void)flyOutWithView:(UIView*)view;
#pragma mark - 根据大小获取一张加载时的图片
+ (UIImage*)placeholderImageBySize:(CGSize)size;

@end
