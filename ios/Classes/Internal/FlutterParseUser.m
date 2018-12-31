//
//  FlutterParseUser.m
//  flutter_parse
//
//  Created by Alann Maulana on 29/12/18.
//

#import "FlutterParseUser.h"
#import <Parse/Parse.h>
#import "FlutterParseObject.h"
#import "FlutterParseUtils.h"
#import "PFObjectPrivate.h"
#import "FlutterParseEncoder.h"

@implementation FlutterParseUser

+ (void)returnUser:(PFUser*) user withResult:(FlutterResult) result {
    FlutterParseObject *object = [[FlutterParseObject alloc] initWithParseObject:user];
    NSArray *operationSetUUIDs = nil;
    NSError *error = nil;
    NSDictionary *resultDict = [object.parseObject RESTDictionaryWithObjectEncoder:[FlutterParseEncoder objectEncoder] operationSetUUIDs:&operationSetUUIDs error:&error];
    result([FlutterParseUtils stringFrom:resultDict]);
}

+ (void)getCurrentUserWithResult:(FlutterResult)result {
    PFUser *user = [PFUser currentUser];
    if (!user) {
        result([NSNull null]);
        return;
    }
    
    [self returnUser:user withResult:result];
}

+ (void)login:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary* dict = [FlutterParseUtils parsingParams:call.arguments];
    if (!dict) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", kPFErrorInvalidJSON] message:@"invalid parse object" details:nil]);
        return;
    }
    
    NSString *username = dict[@"username"];
    if (!username) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", kPFErrorUserPasswordMissing] message:@"missing username" details:nil]);
        return;
    }
    
    NSString *password = dict[@"password"];
    if (!password) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", kPFErrorUserPasswordMissing] message:@"missing password" details:nil]);
        return;
    }
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (error) {
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", error.code] message:error.localizedDescription details:nil]);
            return;
        }
        
        [self returnUser:user withResult:result];
    }];
}

+ (void)signup:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary* dict = [FlutterParseUtils parsingParams:call.arguments];
    if (!dict) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", kPFErrorInvalidJSON] message:@"invalid parse object" details:nil]);
        return;
    }
    
    NSString *username = dict[@"username"];
    if (!username) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", kPFErrorUserPasswordMissing] message:@"missing username" details:nil]);
        return;
    }
    
    NSString *password = dict[@"password"];
    if (!password) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", kPFErrorUserPasswordMissing] message:@"missing password" details:nil]);
        return;
    }
    
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    
    NSString *email = dict[@"email"];
    if (email) {
        user.email = email;
    }
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![key isEqualToString:@"username"] && ![key isEqualToString:@"password"] && ![key isEqualToString:@"email"]) {
            user[key] = [[PFDecoder objectDecoder] decodeObject:obj];
        }
    }];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", error.code] message:error.localizedDescription details:nil]);
            return;
        }
        
        [self returnUser:user withResult:result];
    }];
}

+ (void)logoutWithResult:(FlutterResult)result {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error) {
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", error.code] message:error.localizedDescription details:nil]);
        } else {
            result([NSNull null]);
        }
    }];
}

@end
