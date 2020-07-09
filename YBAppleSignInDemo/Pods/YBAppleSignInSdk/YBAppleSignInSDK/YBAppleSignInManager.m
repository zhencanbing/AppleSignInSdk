//
//  YBAppleSignInManager.m
//  lishuaPro
//
//  Created by ybgo on 2020/7/8.
//  Copyright © 2020 嘉联支付有限公司. All rights reserved.
//

#import "YBAppleSignInManager.h"
#import "YBAppleKeychainTool.h"

static NSString *kAppleSignInUserIdentity = @"kAppleSignInUserIdentity";

@interface YBAppleSignInManager ()<ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding>

@property (nonatomic, strong) ASPresentationAnchor windowAnchor;

@property (nonatomic, copy) void(^appleSignInSuccessBlock)(YBAppleUserInfo *userInfo);

@property (nonatomic, copy) void(^appleSignInFailureBlock)(NSError *error);

@property (nonatomic, copy) void(^appleSignInStatusChangedBlock)(ASAuthorizationAppleIDProviderCredentialState credentialState);

@end

@implementation YBAppleSignInManager

+ (instancetype)shareInstance {
    
    static YBAppleSignInManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        if (@available(iOS 13.0, *)) {
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(checkAppleSignInState)
                                                         name:ASAuthorizationAppleIDProviderCredentialRevokedNotification
                                                       object:nil];
        }
    }
    return self;
}

- (void)dealloc {
    
    if (@available(iOS 13.0, *)) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:ASAuthorizationAppleIDProviderCredentialRevokedNotification
                                                      object:nil];
    }
    
}


- (void)checkAppleSignInState API_AVAILABLE(ios(13.0)) {
    
    if (@available(iOS 13.0, *)) {
        
        if (self.appleSignInStatusChangedBlock) {
            [self checkAppleSignInStateCompletion:self.appleSignInStatusChangedBlock];
        }
    }
    
}

- (void)checkAppleSignInStateCompletion:(void(^)(ASAuthorizationAppleIDProviderCredentialState credentialState))completion  API_AVAILABLE(ios(13.0)) {
    
    if (@available(iOS 13.0, *)) {
        NSString *userId = [YBAppleKeychainTool readKeychainValue:kAppleSignInUserIdentity];
        if (userId != nil && userId.length > 0) {
            
            ASAuthorizationAppleIDProvider *provider = [[ASAuthorizationAppleIDProvider alloc] init];
            [provider getCredentialStateForUserID:userId completion:^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError * _Nullable error) {
                
                if (completion) {
                    completion(credentialState);
                }
            }];
        }
    }
    
}

- (void)signInWithAppleByWindowAnchor:(ASPresentationAnchor)windowAnchor
                              success:(void(^)(YBAppleUserInfo *userInfo))success
                              failure:(void(^)(NSError *error))failure API_AVAILABLE(ios(13.0)) {
    
    self.windowAnchor = windowAnchor;
    self.appleSignInSuccessBlock = success;
    self.appleSignInFailureBlock = failure;
    
    if (@available(iOS 13.0, *)) {
        
        ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];
        ASAuthorizationAppleIDRequest *request = appleIDProvider.createRequest;
        request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
        ASAuthorizationController *controller = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
        controller.delegate = self;
        controller.presentationContextProvider = self;
        [controller performRequests];
    }
    
}

- (void)performExistingAccountSetupFlows API_AVAILABLE(ios(13.0)) {
    
    ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];
    ASAuthorizationAppleIDRequest *request = appleIDProvider.createRequest;
    [request setRequestedScopes:@[ASAuthorizationScopeFullName,ASAuthorizationScopeEmail]];

    ASAuthorizationPasswordProvider *appleIDPasswordProvider = [ASAuthorizationPasswordProvider new];
    ASAuthorizationPasswordRequest *passwordRequest = appleIDPasswordProvider.createRequest;

    NSArray *resquests = [NSArray arrayWithObjects:request, passwordRequest, nil];
    ASAuthorizationController *controller = [[ASAuthorizationController alloc] initWithAuthorizationRequests:resquests];
    controller.delegate = self;
    controller.presentationContextProvider = self;
    [controller performRequests];
}

#pragma mark - ASAuthorizationControllerDelegate
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)) {
    
    NSLog(@"授权完成：authorization：%@\n controller:%@\n", authorization, controller);
    
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        // 用户登录使用ASAuthorizationAppleIDCredential
        ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
    
        NSString *userId            = appleIDCredential.user;
        // 使用过授权的，可能获取不到以下两个参数
        NSPersonNameComponents *fullName = appleIDCredential.fullName;
        NSString *email           = appleIDCredential.email;
        
        NSData *identityToken     = appleIDCredential.identityToken;
        NSData *authorizationCode = appleIDCredential.authorizationCode;
        // 服务器验证需要使用的参数
        NSString *identityTokenStr = [[NSString alloc] initWithData:identityToken encoding:NSUTF8StringEncoding];
        NSString *authorizationCodeStr = [[NSString alloc] initWithData:authorizationCode encoding:NSUTF8StringEncoding];
        
        YBAppleUserInfo *userInfo = [[YBAppleUserInfo alloc] init];
        userInfo.credential        = appleIDCredential;
        userInfo.userId            = userId;
        userInfo.identityToken     = identityTokenStr;
        userInfo.authorizationCode = authorizationCodeStr;
        userInfo.email             = email;
        userInfo.fullName          = fullName;
        
        [YBAppleKeychainTool saveKeychainValue:userId key:kAppleSignInUserIdentity];
        
        if (self.appleSignInSuccessBlock) {
            self.appleSignInSuccessBlock(userInfo);
        }
        
        NSLog(@"identityToken:\n%@\nauthorizationCode:\n%@", identityTokenStr, authorizationCodeStr);
        
    } else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {
        
        // 这个获取的是iCloud记录的账号密码，需要输入框支持iOS 12 记录账号密码的新特性，如果不支持，可以忽略
        // Sign in using an existing iCloud Keychain credential.
        // 用户登录使用现有的密码凭证
        ASPasswordCredential *passwordCredential = authorization.credential;
        // 密码凭证对象的用户标识 用户的唯一标识
        NSString *userName = passwordCredential.user;
        // 密码凭证对象的密码
        NSString *password = passwordCredential.password;
        
        YBAppleUserInfo *userInfo = [[YBAppleUserInfo alloc] init];
        userInfo.credential = passwordCredential;
        userInfo.userName   = userName;
        userInfo.password   = password;
        
        if (self.appleSignInSuccessBlock) {
            self.appleSignInSuccessBlock(userInfo);
        }
        
    } else {
        
        NSLog(@"授权信息均不符");
        
        NSError *error = [NSError errorWithDomain:@"com.apple.AuthenticationServices.AuthorizationError" code:ASAuthorizationErrorUnknown userInfo:@{}];
        if (self.appleSignInFailureBlock) {
            self.appleSignInFailureBlock(error);
        }
    }
}
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)) {
    
    NSLog(@"Handle error：%@", error);
    
    if (self.appleSignInFailureBlock) {
        self.appleSignInFailureBlock(error);
    }
}

#pragma mark - ASAuthorizationControllerPresentationContextProviding
//告诉代理应该在哪个window 展示内容给用户
- (nonnull ASPresentationAnchor)presentationAnchorForAuthorizationController:(nonnull ASAuthorizationController *)controller  API_AVAILABLE(ios(13.0)){
    
    return self.windowAnchor;
}

@end
