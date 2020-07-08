//
//  YBAppleSignInManager.h
//  lishuaPro
//
//  Created by ybgo on 2020/7/8.
//  Copyright © 2020 嘉联支付有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YBAppleUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YBAppleSignInManager : NSObject

+ (instancetype)shareInstance;

/// 检查登录状态
- (void)checkAppleSignInState API_AVAILABLE(ios(13.0));

/// 检查登录状态 返回当前状态
/// @param completion <#completion description#>
- (void)checkAppleSignInStateCompletion:(void(^)(ASAuthorizationAppleIDProviderCredentialState credentialState))completion  API_AVAILABLE(ios(13.0));

/// 苹果登录
/// @param windowAnchor <#windowAnchor description#>
/// @param success <#success description#>
/// @param failure <#failure description#>
- (void)signInWithAppleByWindowAnchor:(ASPresentationAnchor)windowAnchor
                              success:(void(^)(YBAppleUserInfo *userInfo))success
                              failure:(void(^)(NSError *error))failure API_AVAILABLE(ios(13.0));

/// perform Existing Account Setup Flows, prompts the user if an existing iCloud Keychain credential or Apple ID credential is found
- (void)performExistingAccountSetupFlows API_AVAILABLE(ios(13.0));

@end

NS_ASSUME_NONNULL_END
