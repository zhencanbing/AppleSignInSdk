//
//  YBAppleKeychainTool.h
//  lishuaPro
//
//  Created by ybgo on 2020/7/8.
//  Copyright © 2020 嘉联支付有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YBAppleKeychainTool : NSObject

///  储存字符串到钥匙串
/// @param sValue <#sValue description#>
/// @param sKey <#sKey description#>
+ (void)saveKeychainValue:(NSString *)sValue key:(NSString *)sKey;

/// 从钥匙串 获取字符串
/// @param sKey <#sKey description#>
+ (NSString *)readKeychainValue:(NSString *)sKey;

/// 从钥匙串 删除字符串
/// @param sKey <#sKey description#>
+ (void)deleteKeychainValue:(NSString *)sKey;

@end

NS_ASSUME_NONNULL_END
