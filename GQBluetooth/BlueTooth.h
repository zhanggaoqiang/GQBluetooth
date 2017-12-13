//
//  BlueTooth.h
//  BleDemo
//
//  Created by 张高强 on 2017/11/7.
//  Copyright © 2017年 liuyanwei. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
/**
 枚举定义蓝牙所有指令状态
 */
typedef NS_ENUM(NSUInteger,CommandState){
    CommandStateOpen = 0,//打开蓝牙
    CommandStateClose,  //关闭蓝牙
    CommandStateQuery   //查询蓝牙状态
};


@protocol BlueToothDelegate<NSObject>

@optional
//点击开始连接蓝牙按钮
-(void)didClickStart;
//连接成功
- (void)BLEConnectSucceed;
//收到的数据
- (void)receivedValue:(NSString *)data;
//打开蓝牙提示
-(void)openBluetooth;
//连接蓝牙失败
-(void)connectFail;

@end
@interface BlueTooth : NSObject<CBPeripheralDelegate,CBCentralManagerDelegate>

//代理
@property (nonatomic, weak) id<BlueToothDelegate> delegate;
//中心
@property (nonatomic,strong) CBCentralManager *centralManager;
//外设
@property (nonatomic,strong) CBPeripheral *peripheral;
//特征
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property(nonatomic,strong)CBCentralManager *central;//中心设备管理
@property(nonatomic,copy)NSString *peripheralName;//传入的需要连接的外设
@property(nonatomic,assign)CommandState command;//外设具体指令状态


//初始化
+ (instancetype)sharedInstance;
//开始连接
- (void)startConnect;
//断开连接
- (void)endConnect;

@end
