//
//  IParseInstallation.h
//  flutter_parse
//
//  Created by Alann Maulana on 20/12/18.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kParseInstallation = @"installation";

@interface IParseInstallation : NSObject

+ (void)initialize:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
