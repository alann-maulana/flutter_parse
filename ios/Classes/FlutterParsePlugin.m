#import "FlutterParsePlugin.h"
#import "FlutterParse.h"
#import "FlutterParseObject.h"
#import "FlutterParseUser.h"
#import "FlutterParseQuery.h"

@implementation FlutterParsePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"flutter_parse"
                                                                binaryMessenger:[registrar messenger]];
    FlutterParsePlugin* instance = [[FlutterParsePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    // Parse
    if ([kParseInitialize isEqualToString:call.method]) {
        [FlutterParse initialize:call result:result];
        return;
    } else
    // Parse Object
    if ([kParseObjectSaveInBackground isEqualToString:call.method]) {
        [FlutterParseObject saveAsync:call result:result eventually:NO];
    } else if ([kParseObjectSaveEventually isEqualToString:call.method]) {
        [FlutterParseObject saveAsync:call result:result eventually:YES];
    } else if ([kParseObjectDeleteInBackground isEqualToString:call.method]) {
        [FlutterParseObject deleteAsync:call result:result eventually:NO];
    } else if ([kParseObjectDeleteEventually isEqualToString:call.method]) {
        [FlutterParseObject deleteAsync:call result:result eventually:YES];
    } else if ([kParseObjectFetchInBackground isEqualToString:call.method]) {
        [FlutterParseObject fetchAsync:call result:result];
    } else
    // Parse User
    if ([kParseUserLogin isEqualToString:call.method]) {
        [FlutterParseUser login:call result:result];
    } else if ([kParseUserLogout isEqualToString:call.method]) {
        [FlutterParseUser logoutWithResult:result];
    } else if ([kParseUserRegister isEqualToString:call.method]) {
        [FlutterParseUser signup:call result:result];
    } else if ([kParseUserGetCurrentUser isEqualToString:call.method]) {
        [FlutterParseUser getCurrentUserWithResult:result];
    } else
    // Parse Query
    if ([kParseQueryInBackground isEqualToString:call.method]) {
        [FlutterParseQuery executeAsync:call result:result];
    }
    
    else {
        result(FlutterMethodNotImplemented);
    }
}

@end
