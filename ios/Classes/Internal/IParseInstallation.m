//
//  IParseInstallation.m
//  flutter_parse
//
//  Created by Alann Maulana on 20/12/18.
//

#import "IParseInstallation.h"
#import <Parse/Parse.h>

@implementation IParseInstallation

+ (void)initialize:(FlutterResult)result {
    PFInstallation *installation = [PFInstallation currentInstallation];

    [installation setObject:@"ios" forKey:@"deviceType"];
    [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!succeeded) {
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", error.code]
                                       message:error.localizedDescription
                                       details:error]);
        } else {
            result([NSNull null]);
        }
    }];
}

@end
