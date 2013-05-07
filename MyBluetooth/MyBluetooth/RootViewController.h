//
//  RootViewController.h
//  MyBluetooth
//
//  Created by oudongjia on 13-4-10.
//  Copyright (c) 2013年 oudongjia. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <GameKit/GameKit.h>
#import "TheBluetoochManager.h"
@interface RootViewController : UIViewController<TheBluetoochDelegate,UITextFieldDelegate>
{
    

        /*GKSession对象用于表现两个蓝牙设备之间连接的一个会话，你也可以使用它在两个设备之间发送和接收数据。*/
//    GKSession				*currentSession;
//    GKPeerPickerController	*picker;
    UIButton*connect;
    UIButton*disconnect;
    UIButton *sendMessage;
    UILabel*bluetoothState;

    
    UITextField *textField;
    
    
    TheBluetoochManager *theBluetooch;
    BOOL isConnect;
    
    
}

//@property (nonatomic, retain) GKSession *currentSession;
//@property (nonatomic, retain) GKPeerPickerController *picker;

@property(nonatomic,retain)    UIButton*connect;
@property(nonatomic,retain)    UIButton*disconnect;
@property(nonatomic,retain)    UIButton *sendMessage;
@property(nonatomic,retain)    UILabel*bluetoothState;

@property(nonatomic,retain)    UITextField *textField;

@property(nonatomic,retain)TheBluetoochManager *theBluetooch;

@end
