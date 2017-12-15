//
//  BlueTooth.m
//  BleDemo
//
//  Created by 张高强 on 2017/11/7.
//  Copyright © 2017年 liuyanwei. All rights reserved.
//

#import "BlueTooth.h"
@implementation BlueTooth

#define kServiceUUID        @"0003CDD0-0000-1000-8000-00805F9B0131" //服务的UUID
#define kWriteCharacteristicUUID @"0003CDD2-0000-1000-8000-00805F9B0131" //特征的UUID
#define kNotifyCharacteristicUUID @"0003CDD1-0000-1000-8000-00805F9B0131" //特征的UUID
 static id _instance;
/**
 创建单例对象
 @return 返回唯一实例
 */
+(instancetype)sharedInstance{
    @synchronized(self){
        if(_instance == nil){
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}
/**
 开始连接蓝牙
 */
-(void)startConnect{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickStart)])
    {
        //控制器更新UI
        [self.delegate didClickStart];
    }
    //初始化中心端,开始蓝牙模块
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    self.centralManager.delegate = self;
}

//断开连接
- (void)endConnect
{
    [self.centralManager cancelPeripheralConnection:self.peripheral];
       _centralManager=nil;
}
#pragma mark - CBCentralManagerDelegate
// 状态更新后触发
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStatePoweredOff:{
            NSLog(@"蓝牙关闭");
            //检测到蓝牙没打开需要通知代理控制器去执行相关提示操作
            if (self.delegate && [self.delegate respondsToSelector:@selector(openBluetooth)])
            {
                [self.delegate openBluetooth];
            };
        }
            break;
        case CBManagerStatePoweredOn:
            break;
        case CBManagerStateResetting:
            break;
        case CBManagerStateUnauthorized:
            break;
        case CBManagerStateUnknown:
            break;
        case CBManagerStateUnsupported:
            break;
        default:
            break;
    }
    [central scanForPeripheralsWithServices:nil options:nil];
}

// 扫描到外部设备后触发的代理方法//多次调用的
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI
{
    NSString *msg = [NSString stringWithFormat:@"信号强度: %@, 外设: %@", RSSI, peripheral];
    NSLog(@"%@",msg);
    //ZIH0491300//
//    NSLog(@"此时外设名字是%@",_peripheralName);
//    NSAssert(![_peripheralName isEqualToString:@""]||_peripheralName==nil, @"please init correct peripheralName");断言
        if ([peripheral.name isEqualToString:_peripheralName])
        {
            //连接外部设备
            self.peripheral = peripheral;
            [central connectPeripheral:peripheral options:nil];
            //停止搜索
            self.central=central;
            [central stopScan];
            
        }else{
            
        }
}
//连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"连接失败%@",error.localizedDescription);
    if ([self.delegate respondsToSelector:@selector(connectFail)]) {
        [self.delegate connectFail];
    }
}

// 当中心端连接上外设时触发
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接上外设");
    [central stopScan];
    if ([self.delegate respondsToSelector:@selector(BLEConnectSucceed)]) {
        [self.delegate BLEConnectSucceed];
    }
    self.peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

//如果连接上的两个设备突然断开了，程序里面会自动回调下面的方法
-   (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"已经断开蓝牙连接");
}
#pragma mark - CBPeripheralDelegate
// 外设端发现了服务时触发
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"%@",error.localizedDescription);
        return;
    }
    for (CBService *service in peripheral.services)
    {
        if ([service.UUID.UUIDString isEqualToString:kServiceUUID]) {
              [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

//从服务获取特征
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
   NSLog(@"%@",service.characteristics);
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        
        if ([characteristic.UUID.UUIDString isEqualToString:kWriteCharacteristicUUID]  ) {
             self.characteristic = characteristic;
        }
        if ([characteristic.UUID.UUIDString isEqualToString:kNotifyCharacteristicUUID]) {
            self.notifyCharteristic=characteristic;
        }
      
    }
}

#pragma mark 写数据后回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic  error:(NSError *)error {
    if (error) {
        NSLog(@"Error writing characteristic value: %@",
              [error localizedDescription]);
        return;
    }
    NSLog(@"写入%@成功",characteristic);
}


-(void)query{
    [self.peripheral setNotifyValue:YES forCharacteristic:self.notifyCharteristic];
}
/**
 打开蓝牙
 */
-(void)open{
    NSData *data = [@"&1&1&1&1" dataUsingEncoding:NSUTF8StringEncoding];
    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:0x04];
     [self.peripheral setNotifyValue:YES forCharacteristic:self.notifyCharteristic];
}

/**
 关闭蓝牙
 */
-(void)close{
    NSData *data = [@"&&&2&" dataUsingEncoding:NSUTF8StringEncoding];
    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:0x04];
     [self.peripheral setNotifyValue:YES forCharacteristic:self.notifyCharteristic];
}

//将十六进制的字符串转换成NSString则可使用如下方式:
+ (NSString *)convertHexStrToString:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        range.location += range.length;
        range.length = 2;
    }
    NSString *string = [[NSString alloc]initWithData:hexData encoding:NSUTF8StringEncoding];
    return string;
}

//收到数据,并且通知代理接受数据，并实现相关功能
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString *results=[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
   
        if ([self.delegate respondsToSelector:@selector(receivedValue:)]) {
            [self.delegate receivedValue:results];
        }
}

@end

