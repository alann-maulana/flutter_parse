//
//  FlutterParseConfig.h
//  flutter_parse
//
//  Created by Alann Maulana on 12/02/19.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

static const NSString* kParseConfigGetCurrent = @"configGetCurrent";
static const NSString* kParseConfigGetInBackground = @"configFetchInBackground";

@class PFConfig;
@interface FlutterParseConfig : NSObject

+ (void) currentConfigWithResult:(FlutterResult)result;
+ (void) fetchInBackgroundWithResult:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
