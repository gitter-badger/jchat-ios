/*
 *	| |    | |  \ \  / /  | |    | |   / _______|
 *	| |____| |   \ \/ /   | |____| |  / /
 *	| |____| |    \  /    | |____| |  | |   _____
 * 	| |    | |    /  \    | |    | |  | |  |____ |
 *  | |    | |   / /\ \   | |    | |  \ \______| |
 *  | |    | |  /_/  \_\  | |    | |   \_________|
 *
 * Copyright (c) 2011 ~ 2015 Shenzhen HXHG. All rights reserved.
 */

#ifndef JMessage_JMSGConstants____FILEEXTENSION___
#define JMessage_JMSGConstants____FILEEXTENSION___

#import <Foundation/Foundation.h>


/**
* 接口调用回调 block
*
* 大多数异步 API 都会以过个 block 回调。
* 如果调用出错，则 error 不为空，可根据 error.code 来获取错误码。该错误码 JMessage 相关文档里有详细的定义。
* 如果返回正常，则 error 为空。从 resultObject 去获取相应的返回。每个 API 的定义上都会有进一步的定义。
*/
typedef void (^JMSGCompletionHandler)(id resultObject, NSError *error);


/**
*
*/
typedef void (^JMSGSpecificFailHandler)();


/**
* 消息下载回调block
*/
typedef void (^JMSGonProgressUpdate)(float percent);


#endif
