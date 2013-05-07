//
//  TheBluetoochManager.h
//  MyBluetooth
//
//  Created by oudongjia on 13-4-11.
//  Copyright (c) 2013年 oudongjia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol TheBluetoochDelegate ;


@interface TheBluetoochManager : NSObject<GKPeerPickerControllerDelegate, GKSessionDelegate>
{
    /*GKSession对象用于表现两个蓝牙设备之间连接的一个会话，你也可以使用它在两个设备之间发送和接收数据。*/
    GKSession				*currentSession;
    GKPeerPickerController	*picker;
    
    id theDelegate;
    BOOL isConnet;
    
}

@property (nonatomic, retain) GKSession *currentSession;
@property (nonatomic, retain) GKPeerPickerController *picker;
@property (nonatomic,retain) id theDelegate;
@property (nonatomic) BOOL isConnet;

+ (TheBluetoochManager*) defaultUserManager;
-(void)connect;
-(void)disConnect;
-(void)setDelegate:(id)delegate;
-(void)sendData:(NSData*)ndata;
@end

@protocol TheBluetoochDelegate <NSObject>

-(void)bluetoothManager:(TheBluetoochManager*)manager peer:(NSString*)peerID didChangeState:(GKPeerConnectionState)state;

-(void)bluetoothManagerPeerPickerControllerDidCancel:(TheBluetoochManager*)manager ;

-(void)bluetoothManager:(TheBluetoochManager*)manager receiveData:(NSData*)data fromPeer:(NSString*)peer context:(void*)context;

@end
