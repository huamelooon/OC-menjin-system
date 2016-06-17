 //
//  main.m
//  OC-门禁系统
//
//  Created by qingyun on 16/4/18.
//  Copyright © 2016年 QingYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Doors.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Doors *door=[Doors new];
        [door showDoors];
//        //使用文件管理器打印当前路径
//        NSFileManager *fm = [NSFileManager defaultManager];
//        NSString *path = [fm currentDirectoryPath];
        
        
    }
    return 0;
}
