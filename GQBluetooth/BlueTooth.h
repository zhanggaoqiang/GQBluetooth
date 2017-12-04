//
//  BlueTooth.h
//  BleDemo
//
//  Created by 张高强 on 2017/11/7.
//  Copyright © 2017年 liuyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>
@protocol BlueToothDelegate<NSObject>

@optional
//点击链接按钮
-(void)didClickStart;
//连接成功
- (void)BLEConnectSucceed;
//收到的数据
- (void)receivedValue:(NSString *)data;
//打开蓝牙提示
-(void)openBluetooth;

//连接蓝牙失败
-(void)connectFail;

-(void)notFindDevice;




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
@property(nonatomic,copy)NSString *chaxun;

@property(nonatomic,strong)NSMutableArray *allDeviceList;
@property(nonatomic,strong)CBCentralManager *central;
@property(nonatomic,copy)NSString *zih;
//初始化
+ (instancetype)sharedInstance;
//开始连接
- (void)startConnect;
//断开连接
- (void)endConnect;
//读数据
- (void)readFromPeripheral;
//写数据
- (void)writeToPeripheralWith:(NSString *)name;
//监听数据
- (void)notifyPeripheral;




@end
