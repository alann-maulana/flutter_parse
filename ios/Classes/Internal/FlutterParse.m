//
//  IParse.m
//  Bolts
//
//  Created by Alann Maulana on 20/12/18.
//

#import "FlutterParse.h"
#import <Parse/Parse.h>

static NSString *const kServer = @"server";
static NSString *const kApplicationId = @"applicationId";
static NSString *const kClientKey = @"clientKey";

@implementation FlutterParse

+ (void)initialize:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *server = call.arguments[kServer];
    NSString *applicationId = call.arguments[kApplicationId];
    NSString *clientKey = call.arguments[kClientKey];
    
    ParseClientConfiguration *config = [ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration>  _Nonnull configuration) {
        configuration.server = server;
        configuration.applicationId = applicationId;
        configuration.clientKey = clientKey;
        configuration.localDatastoreEnabled = YES;
    }];
    [Parse initializeWithConfiguration:config];
    result(@(YES));
}

@end
