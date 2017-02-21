//
//  Macros.h
//  LJTrack
//
//  Created by LiJie on 16/6/14.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#ifndef Macros_h
#define Macros_h


#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define AppDelegateInstance	 ([UIApplication sharedApplication].delegate)

//动态获取设备高度
#define IPHONE_HEIGHT [UIScreen mainScreen].bounds.size.height
//动态获取设备宽度
#define IPHONE_WIDTH [UIScreen mainScreen].bounds.size.width

//设置颜色
#define RandomColor [UIColor colorWithRed:arc4random()%256/255.0f green:arc4random()%256/255.0f blue:arc4random()%256/255.0f alpha:1]

#define kRGBColor(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kSystemColor kRGBColor(193, 0, 32, 1)
#define kFontColor   kRGBColor(253, 253, 253, 1)


//屏幕比例
#define VIEW_RATE ([UIScreen mainScreen].bounds.size.width/320.0)

#define IFISNULL(v)             ([v isEqualToString:@""] || v==nil || v==NULL)
#define IFISSTRNIL(v)           (v = (v != nil) ? v : @"")
#define IFISNumber(v)           (v==nil || v==NULL ? @(0) : v)


#ifdef DEBUG
#define DLog( s, ... ) NSLog( @"<%@: (%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
//#define NSLog(...)
#define DLog( s, ... )
#endif

#endif /* Macros_h */
