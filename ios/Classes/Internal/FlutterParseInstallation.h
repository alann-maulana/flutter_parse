//
//  FlutterParseInstallation.h
//  flutter_parse
//
//  Created by Alann Maulana on 28/12/18.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kParseInstallation = @"installation";

@interface FlutterParseInstallation : NSObject

+ (void)initialize:(FlutterMethodCall*)call result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
