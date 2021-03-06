// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v1.0.16), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import <Foundation/Foundation.h>
@protocol FlutterBinaryMessenger;
@protocol FlutterMessageCodec;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

/// The codec used by UserDefaultsApi.
NSObject<FlutterMessageCodec> *UserDefaultsApiGetCodec(void);

@protocol UserDefaultsApi
- (void)removeKey:(NSString *)key error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setBoolKey:(NSString *)key
             value:(NSNumber *)value
             error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setDoubleKey:(NSString *)key
               value:(NSNumber *)value
               error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setValueKey:(NSString *)key value:(id)value error:(FlutterError *_Nullable *_Nonnull)error;
- (nullable NSDictionary<NSString *, id> *)getAllWithError:(FlutterError *_Nullable *_Nonnull)error;
- (void)clearWithError:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void UserDefaultsApiSetup(id<FlutterBinaryMessenger> binaryMessenger,
                                 NSObject<UserDefaultsApi> *_Nullable api);

NS_ASSUME_NONNULL_END
