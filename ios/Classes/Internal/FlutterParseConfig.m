//
//  FlutterParseConfig.m
//  flutter_parse
//
//  Created by Alann Maulana on 12/02/19.
//

#import "FlutterParseConfig.h"
#import <Parse/Parse.h>
#import "PFConfig_Private.h"
#import "FlutterParseUtils.h"
#import "FlutterParseEncoder.h"

@implementation FlutterParseConfig

+ (void) currentConfigWithResult:(FlutterResult)result {
    PFConfig *config = [PFConfig currentConfig];
    if (config) {
        NSError *error = nil;
        NSDictionary *dict = [[FlutterParseEncoder objectEncoder] encodeObject:[config parametersDictionary] error:&error];
        result([FlutterParseUtils stringFrom:dict]);
        return;
    }
    
    result(nil);
}

+ (void) fetchInBackgroundWithResult:(FlutterResult)result {
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig * _Nullable config, NSError * _Nullable error) {
        if (error) {
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", error.code] message:error.localizedDescription details:nil]);
            return;
        }
        
        NSError *e = nil;
        NSDictionary *dict = [[FlutterParseEncoder objectEncoder] encodeObject:[config parametersDictionary] error:&e];
        result([FlutterParseUtils stringFrom:dict]);
    }];
}

@end
