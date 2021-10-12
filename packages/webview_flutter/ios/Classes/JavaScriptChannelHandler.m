// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "JavaScriptChannelHandler.h"

@implementation FLTJavaScriptChannel {
  FlutterMethodChannel* _methodChannel;
  NSString* _javaScriptChannelName;
}

- (instancetype)initWithMethodChannel:(FlutterMethodChannel*)methodChannel
                javaScriptChannelName:(NSString*)javaScriptChannelName {
  self = [super init];
  NSAssert(methodChannel != nil, @"methodChannel must not be null.");
  NSAssert(javaScriptChannelName != nil, @"javaScriptChannelName must not be null.");
  if (self) {
    _methodChannel = methodChannel;
    _javaScriptChannelName = javaScriptChannelName;
  }
  return self;
}

- (void)userContentController:(WKUserContentController*)userContentController
      didReceiveScriptMessage:(WKScriptMessage*)message {
  NSAssert(_methodChannel != nil, @"Can't send a message to an unitialized JavaScript channel.");
  NSAssert(_javaScriptChannelName != nil,
           @"Can't send a message to an unitialized JavaScript channel.");
  NSDictionary* arguments = @{
    @"channel" : _javaScriptChannelName,
    @"message" : [self changeToJsonString:message.body]
  };
  [_methodChannel invokeMethod:@"javascriptChannelMessage" arguments:arguments];
}


- (NSString *)changeToJsonString:(id)body{
    if ([body isKindOfClass:[NSString class]]){
        return body;
    }else if ([body isKindOfClass:[NSDictionary class]]){
        return [self convertToJsonData:body];
    }
    return @"";
}

-(NSString *)convertToJsonData:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

@end
