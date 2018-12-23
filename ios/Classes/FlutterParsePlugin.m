#import "FlutterParsePlugin.h"
#import "IParse.h"
#import "IParseInstallation.h"

@implementation FlutterParsePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"flutter_parse"
                                                                binaryMessenger:[registrar messenger]];
    FlutterParsePlugin* instance = [[FlutterParsePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([kParseInitialize isEqualToString:call.method]) {
        [IParse initialize:call result:result];
        return;
    }
    
    if ([kParseInstallation isEqualToString:call.method]) {
        [IParseInstallation initialize:result];
        return;
    }
    
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
