//
//  TheBluetoochManager.m
//  MyBluetooth
//
//  Created by oudongjia on 13-4-11.
//  Copyright (c) 2013年 oudongjia. All rights reserved.
//

#import "TheBluetoochManager.h"

@implementation TheBluetoochManager

@synthesize currentSession;
@synthesize picker;
@synthesize theDelegate;
@synthesize isConnet;

static TheBluetoochManager* kDefaultManager = nil;

+ (TheBluetoochManager*) defaultUserManager
{
	if (kDefaultManager == nil) {
		kDefaultManager = [[TheBluetoochManager alloc] init];
	}
	
	return kDefaultManager;
}

- (id)init
{
	if (self = [super init]) {

        isConnet = NO;
        picker = [[GKPeerPickerController alloc] init];
        picker.delegate = self;
        picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
        
        currentSession = [[GKSession alloc] initWithSessionID:@"DJ" displayName:nil sessionMode:GKSessionModePeer];
        currentSession.delegate = self;
	}
	return self;
}

- (void)dealloc
{
     isConnet = NO;
    currentSession.delegate = nil;
    [currentSession release];
    
    picker.delegate = nil;
	[self.picker release];
	[super dealloc];
}

-(void)connect
{
    [picker show];
    
}
-(void)disConnect
{
    [self.currentSession disconnectFromAllPeers];
     isConnet = NO;
}

-(void)setDelegate:(id)delegate
{
    theDelegate = delegate;
    
}
-(void)sendData:(NSData*)ndata
{
    [currentSession sendDataToAllPeers :ndata withDataMode:GKSendDataReliable error:nil];
}

- (GKSession *) peerPickerController:(GKPeerPickerController *)picker
			sessionForConnectionType:(GKPeerPickerConnectionType)type {

    return currentSession;
}

//方法功能：判断数据传输状态
-(void)session:(GKSession*)session peer:(NSString*)peerID didChangeState:(GKPeerConnectionState)state
{
    

    
	switch (state) {
		case GKPeerStateConnected:
			[self.currentSession setDataReceiveHandler :self withContext:nil];
             isConnet = YES;
			break;
		case GKPeerStateDisconnected:
             isConnet = NO;

			break;
	}
    
    if (self.theDelegate && [self.theDelegate respondsToSelector:@selector(bluetoothManager:peer:didChangeState:)]) {
        [self.theDelegate bluetoothManager:self peer:peerID didChangeState:state];
    }
}



- (void)peerPickerController:(GKPeerPickerController *)picker didConnectToPeer:(NSString *)peerID {
    printf("连接成功！\n");
    // stateStr.text = @"未连接";
     isConnet = YES;
    
}


- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
    printf("连接尝试被取消 \n");
     isConnet = NO;
    
    if(self.theDelegate && [self.theDelegate respondsToSelector:@selector(bluetoothManagerPeerPickerControllerDidCancel:)])
    {
        [self.theDelegate bluetoothManagerPeerPickerControllerDidCancel:self];
    }
    
    
    //stateStr.text = @"未连接";
}

//方法功能：连接失败
-(void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString*)peerID toSession:(GKSession *)session{
    NSLog(@"peerID = %@,SessionID= %@,diplayName = %@",peerID,session.sessionID,session.displayName);
	self.currentSession=session;
	session.delegate=self;
	[session setDataReceiveHandler:self withContext:nil];
	[self.picker dismiss];

	
}

//方法功能：接受数据
-(void)receiveData:(NSData*)data fromPeer:(NSString*)peer inSession:(GKSession*)session context:(void*)context
{
    // Read the bytes in data and perform an application-specific action, then free the NSData object
    
    
    if (self.theDelegate && [self.theDelegate respondsToSelector:@selector(bluetoothManager:receiveData:fromPeer:context:)]) {
        [self.theDelegate bluetoothManager:self receiveData:data fromPeer:peer context:context];
    }
    

	
	
	
}

@end
