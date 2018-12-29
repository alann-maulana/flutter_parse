//
//  FlutterInstallation.m
//  flutter_parse
//
//  Created by Alann Maulana on 28/12/18.
//

#import "FlutterParseInstallation.h"
#import <Parse/Parse.h>

@implementation FlutterParseInstallation

+ (void)initialize:(FlutterMethodCall*)call result:(FlutterResult)result {
    PFInstallation *installation = [PFInstallation currentInstallation];
    
    if (installation) {
        [installation saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", error.code] message:error.localizedDescription details:nil]);
            } else {
                result(@(YES));
            }
        }];
    }
}

@end
