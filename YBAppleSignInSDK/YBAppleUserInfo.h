//
//  YBAppleUserInfo.h
//  lishuaPro
//
//  Created by ybgo on 2020/7/8.
//  Copyright © 2020 嘉联支付有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AuthenticationServices/AuthenticationServices.h>

NS_ASSUME_NONNULL_BEGIN

@interface YBAppleUserInfo : NSObject

/** ASAuthorizationAppleIDCredential */
@property (nonatomic, strong) id <ASAuthorizationCredential> credential API_AVAILABLE(ios(13.0));

/** An opaque user ID associated with the AppleID used for the sign in. This identifier will be stable across the 'developer team' */
@property (nonatomic, copy, nullable) NSString *userId;

/** The ID token will contain the following information: Issuer Identifier, Subject Identifier, Audience, Expiry Time and Issuance Time signed by Apple's identity service. */
@property (nonatomic, strong, nullable) NSString *identityToken;

/** code */
@property (nonatomic, strong, nullable) NSString *authorizationCode;

/** An optional email shared by the user, maybe hidden by users */
@property (nonatomic, copy, nullable) NSString *email;

/** An optional full name shared by the user.  This field is populated with a value that the user authorized. */
@property (nonatomic, strong, nullable) NSPersonNameComponents *fullName API_AVAILABLE(ios(9.0));

/** The user name of this credential */
@property (nonatomic, copy, nullable) NSString *userName;

/** The password of this credential. */
@property (nonatomic, copy, nullable) NSString *password;

@end

NS_ASSUME_NONNULL_END
