//
//  KVTool.m
//  BodyIntellect1.2
//
//  Created by 知子花 on 16/1/15.
//  Copyright © 2016年 知子花. All rights reserved.
//

#import "KVTool.h"
#import <objc/runtime.h>

@implementation KVTool

+ (UIImage*)screenView:(UIView *)view{
    CGRect rect = view.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark - runtime利用字典对模型进行赋值，可以兼容对象属性与字典映射不成立的情况
+ (id)getModelWithModelClass:(Class)class dataDict:(NSDictionary *)dataDict keyDict:(NSDictionary *)keyDict {
    
    id model = [[class alloc] init];
    
    unsigned int count = 0;
    Ivar * ivars = class_copyIvarList(class, &count); // 取出所有的对象属性
    for (NSInteger i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char * ivarName = ivar_getName(ivar); // 取出对象属性名
        NSString * key = [[NSString stringWithUTF8String:ivarName] stringByReplacingOccurrencesOfString:@"_" withString:@""];// 由于取出的对象属性名头个字符是下划线，替换掉
        id object = [dataDict objectForKey:key]; // 取出数据字典中的值
        if (object) {
            // 如果有值，直接使用KVC赋值
            [model setValue:object forKey:key];
        }else {
            // 没有值，在映射字典中取出映射，没有传入映射字典则不做任何操作
            if (keyDict) {
                id keyObject = [keyDict objectForKey:key]; // 取出映射
                id valueObject = [dataDict objectForKey:keyObject]; // 根据映射取出数据字典中的值
                if (valueObject) {
                    // 有值，直接赋值，没有值则不做任何操作
                    [model setValue:valueObject forKey:key];
                }
            }
        }
    }
    return model;
}

+(NSInteger)getNetWorkStates {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"]subviews];
    NSInteger state = 0;
    int netType = 0;
    //获取到网络返回码
    for (NSInteger i = 0;i < children.count;i++) {
        id child = children[i];
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
            switch (netType) {
                case 0:
                    state = 0;
                    //无网模式
                    break;
                case 1:
                    state = 2;  //2G
                    break;
                case 2:
                    state = 3;  //3G
                    break;
                case 3:
                    state = 4;  //4G
                    break;
                case 5:
                {
                    state = 100;    //WIFI
                }
                    break;
                default:
                    break;
            }
            break;
        }
    }
    //根据状态选择
    if (netType == 0) {
        state = 0;
    }
    return state;
}

+ (void)flyOutWithView:(UIView *)view {
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.25f;
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = NO;
    animation.removedOnCompletion = NO;
    
    //缩放
    CABasicAnimation * scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = [NSNumber numberWithFloat:1];
    scale.toValue = [NSNumber numberWithFloat:0];
    scale.autoreverses = NO;
    scale.repeatCount = 1;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    scale.duration = 0.25f;
    
    CAAnimationGroup * groupAnimation = [CAAnimationGroup animation];
    groupAnimation.delegate = self;
    groupAnimation.repeatCount = 1;
    groupAnimation.duration = 0.25;
    groupAnimation.autoreverses = NO;
    groupAnimation.removedOnCompletion = NO;
    groupAnimation.fillMode = kCAFillModeForwards;
    groupAnimation.animations = @[animation, scale];
    
    [view.layer addAnimation:groupAnimation forKey:@"group"];
}

+ (void)flyInWithView:(UIView *)view {
    //淡入
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.25f;
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat:1.0f];
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = NO;
    animation.removedOnCompletion = NO;
    
    //放大
    CABasicAnimation * scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = [NSNumber numberWithFloat:0];
    scale.toValue = [NSNumber numberWithFloat:1];
    scale.autoreverses = NO;
    scale.repeatCount = 1;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    scale.duration = 0.25f;
    
    CAAnimationGroup * groupAnimation = [CAAnimationGroup animation];
    groupAnimation.repeatCount = 1;
    groupAnimation.duration = 0.25;
    groupAnimation.autoreverses = NO;
    groupAnimation.removedOnCompletion = NO;
    groupAnimation.fillMode = kCAFillModeForwards;
    groupAnimation.animations = @[animation, scale];
    
    [view.layer addAnimation:groupAnimation forKey:@"group1"];
}

#pragma mark - 根据大小获取一张对应大小的加载图片
static NSMutableDictionary * placeholderDict = nil;
+ (UIImage*)placeholderImageBySize:(CGSize)size {
    if (!placeholderDict) {
        placeholderDict = [NSMutableDictionary dictionary]; //只创建一次
    }
    //根据大小去字典中去对应的加载图，有，直接拿出来，不用重新创建
    NSValue * value = [NSValue valueWithCGSize:size];
    UIImage * returnImage = nil;
    UIImage * cacheImage = [placeholderDict objectForKey:value];
    if (cacheImage) {
        returnImage = cacheImage;
    }else {
        //创建图片
        returnImage = [self addImage:[self changeSizeForImage:[UIImage imageNamed:@"placeholder_icon-zhizihua"] size:CGSizeMake(size.width / 3, size.width / 3 / 230 * 119)] toImage:[UIImage imageWithColor:[UIColor colorWithHexCode:@"#f5eace"] width:size.width height:size.height]];
        [placeholderDict setObject:returnImage forKey:value];
    }
    return returnImage;
}

+ (UIImage*)addImage:(UIImage*)image1 toImage:(UIImage*)image2 {
    UIGraphicsBeginImageContext(image2.size);
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    [image1 drawInRect:CGRectMake(image2.size.width / 2 - (image1.size.width / 2), image2.size.height / 2 - image1.size.height / 2, image1.size.width, image1.size.height)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}
//改变
+ (UIImage*)changeSizeForImage:(UIImage*)image size:(CGSize)size {
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = CGPointZero;
    thumbnailRect.size.width  = size.width;
    thumbnailRect.size.height = size.height;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage ;
}

@end
