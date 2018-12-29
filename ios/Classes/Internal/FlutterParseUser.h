//
//  FlutterParseUser.h
//  flutter_parse
//
//  Created by Alann Maulana on 29/12/18.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

static const NSString* kParseUserGetCurrentUser = @"getCurrentUser";
static const NSString* kParseUserLogin = @"login";
static const NSString* kParseUserLogout = @"logout";
static const NSString* kParseUserRegister = @"register";

@interface FlutterParseUser : NSObject

+ (void)getCurrentUserWithResult:(FlutterResult)result;
+ (void)login:(FlutterMethodCall*)call result:(FlutterResult)result;
+ (void)signup:(FlutterMethodCall*)call result:(FlutterResult)result;
+ (void)logoutWithResult:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
