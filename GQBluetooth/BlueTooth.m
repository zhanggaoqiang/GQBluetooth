//
//  BlueTooth.m
//  BleDemo
//
//  Created by 张高强 on 2017/11/7.
//  Copyright © 2017年 liuyanwei. All rights reserved.
//

#import "BlueTooth.h"



@implementation BlueTooth

+(instancetype)sharedInstance{
    BlueTooth *manager=nil;
    //    static dispatch_once_t onceToken;
    //    dispatch_once(&onceToken, ^{
    manager=[[BlueTooth alloc] init];
    manager.chaxun=@"";

   
    
    
    
    //    });
    return manager;
}


-(void)startConnect{
    _allDeviceList=[NSMutableArray arrayWithCapacity:100];
    
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
}

#pragma mark - CBCentralManagerDelegate
// 状态更新后触发
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:{
            NSLog(@"蓝牙关闭");
            [self openLanya];
            
        }
            break;
        case CBCentralManagerStatePoweredOn:
            break;
        case CBCentralManagerStateResetting:
            break;
        case CBCentralManagerStateUnauthorized:
            break;
        case CBCentralManagerStateUnknown:
            break;
        case CBCentralManagerStateUnsupported:
            break;
        default:
            break;
    }
    [central scanForPeripheralsWithServices:nil options:nil];
}


-(void)openLanya{
    if (self.delegate && [self.delegate respondsToSelector:@selector(openBluetooth)])
    {
        //控制器更新UI
        [self.delegate openBluetooth];
    }
    
}

- (void)delayMethod{
//    NSLog(@"delayMethodEnd");
//
//    _centralManager=nil;
//    [self.timer invalidate];
//
//    BOOL isbool=[_allDeviceList containsObject:@"ZIH0491300"];
//    if (!isbool) {
//        if ([self.delegate respondsToSelector:@selector(notFindDevice)]) {
//            [self.delegate notFindDevice];
//        }
//    }

}



// 扫描到外部设备后触发的代理方法//多次调用的
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI
{
    [_allDeviceList addObject:peripheral];
    
    NSString *msg = [NSString stringWithFormat:@"信号强度: %@, 外设: %@", RSSI, peripheral];
    NSLog(@"%@",msg);
    //ZIH0491300//
    
    if ([self.chaxun isEqualToString:@"chaxun"]){
        NSString *scanStr=[[NSUserDefaults standardUserDefaults] objectForKey:@"sevNumber"];
        NSString *lastFiveChartect=[scanStr substringFromIndex:scanStr.length-7];
        self.zih=[@"ZIH" stringByAppendingString:lastFiveChartect];
    }else{
    NSString *scanStr=[[NSUserDefaults standardUserDefaults] objectForKey:@"scanStr"];
    NSString *lastFiveChartect=[scanStr substringFromIndex:scanStr.length-7];
    self.zih=[@"ZIH" stringByAppendingString:lastFiveChartect];
    }
//    NSString *name=[@"ZIH" stringByAppendingString:lastFiveChartect];
    if ([peripheral.name isEqualToString:self.zih])
    {
        //连接外部设备
        self.peripheral = peripheral;
        [central connectPeripheral:peripheral options:nil];
        //停止搜索
        self.central=central;
        [central stopScan];
   
    }else {
//        if ([self.delegate respondsToSelector:@selector(notFindDevice)]) {
//            [self.delegate notFindDevice];
//        }
    }
}

//连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@",error.localizedDescription);
    if ([self.delegate respondsToSelector:@selector(connectFail)]) {
        [self.delegate connectFail];
    }
}


// 当中心端连接上外设时触发
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接上外设");
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"connect"];
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
    NSLog(@"设备断开重连");
    [self.centralManager connectPeripheral:self.peripheral options:nil];
    //    self.centralManager=nil;
    //当断开时做缺省数据处理
}


#pragma mark - CBPeripheralDelegate
// 外设端发现了服务时触发
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"%@",peripheral.services);
    if (error)
    {
        NSLog(@"%@",error.localizedDescription);
        return;
    }
    for (CBService *service in peripheral.services)
    {
        //只找有用的服务
        //        if ([service.UUID.description isEqualToString:@"服务UUID名称"])
        //        {
        [peripheral discoverCharacteristics:nil forService:service];
        //        }
    }
}


//从服务获取特征
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"%@",service.characteristics);
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        // -------- 读特征的处理 --------
        //        if ([characteristic.UUID.description isEqualToString: @"读特征名称"])
        //        {
        //            NSLog(@"处理读特征");
        //            [self.peripheral readValueForCharacteristic:characteristic];
        //        }
        //
        //        // -------- 写特征的处理 --------
        //        if ([characteristic.UUID.description isEqualToString: @"0003CDD2-0000-1000-8000-00805F9B0131"])
        //        {
        //            NSLog(@"处理写特征");
        //            //向外设发送0001命令
        if ([self.chaxun isEqualToString:@"chaxun"]) {
            NSData *data = [@"" dataUsingEncoding:NSUTF8StringEncoding];
            [self.peripheral writeValue:data forCharacteristic:characteristic type:0x04];
            self.characteristic = characteristic;
        }else{
            NSData *data = [@"&123&123&1&" dataUsingEncoding:NSUTF8StringEncoding];
            [self.peripheral writeValue:data forCharacteristic:characteristic type:0x04];
            self.characteristic = characteristic;
            
        }
       
        //        }
        //
        // -------- 订阅特征的处理 --------
        //        if ([characteristic.UUID.description isEqualToString: @"订阅特征名称"])
        //        {
        NSLog(@"处理了订阅特征");
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        //        }
    }
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



//收到数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error

{
    NSLog(@"收到的数据是%@",characteristic.value);
    NSString *results=[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"收到的数据是%@",results);
        if ([self.delegate respondsToSelector:@selector(receivedValue:)]) {
            [self.delegate receivedValue:results];
            
        }
    _centralManager=nil;

}


// 写特征CBCharacteristicWriteWithResponse的数据写入的结果回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"数据写入失败: %@", error);
        
    } else {
        NSLog(@"数据写入成功");
        [peripheral readValueForCharacteristic:characteristic];
    }
}

#pragma mark - VCMethod
//读数据
- (void)readFromPeripheral
{
    NSLog(@"读数据");
    [self.peripheral readValueForCharacteristic:self.characteristic];
}

//"&123&123&1&"
//写数据
- (void)writeToPeripheralWith:(NSString *)instruct
{
    //    NSLog(@"写数据");
    //
    //    NSData *data = [@"2631323326313233263126" dataUsingEncoding:NSUTF8StringEncoding];
    //    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
    ////    NSData *data = [[BlueTooth sharedTool] hexToBytes:instruct];
    ////    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
}

//监听数据
- (void)notifyPeripheral
{
    NSLog(@"监听数据");
    [self.peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
    //    NSString *dataFormat=@"";
    //    if ([dataFormat isEqualToString:@"返回数据格式有误"]) {
    //        NSLog(@"返回格式错误");
    //
    //    }
}





@end

