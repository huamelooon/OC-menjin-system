//
//  Doors.m
//  OC-门禁系统
//
//  Created by qingyun on 16/4/18.
//  Copyright © 2016年 QingYun. All rights reserved.
//

#import "Doors.h"
#define managerP @"manager.plist"//管理员的文件
#define employeP @"employee.plist"//员工的文件

@interface Doors ()

@property(nonatomic,strong)NSFileManager *fm;
@property(nonatomic,strong)NSDictionary *fDic;//管理员的字典
@property(nonatomic,strong)NSMutableArray *fArray;//员工数组
@property(nonatomic,copy)NSString *emName,*emPass;//员工账号/密码
@end
@implementation Doors
#pragma mark - 文件管理器的懒加载
-(NSFileManager *)fm
{
    if (!_fm) {
        _fm=[NSFileManager defaultManager];
    }
    return _fm;
}
#pragma mark - 管理员的字典
-(NSDictionary *)fDic
{
    if (!_fDic)
    {
        _fDic=[NSDictionary dictionaryWithContentsOfFile:managerP];
    }
    return _fDic;
}
#pragma mark -员工数组
-(NSMutableArray *)fArray
{
    if (!_fArray)
    {
        _fArray=[NSMutableArray arrayWithContentsOfFile:employeP];
    }
    return _fArray;
}
#pragma mark - 外界访问的方法
-(void)showDoors
{
    //首先判断管理员的文件在不在
    if ([self.fm fileExistsAtPath:managerP])
    {
        //文件存在，门禁登录界面
        [self welcome];
    }
    else
    {
        //先去注册管理员
        [self managerRegister];
    }
}
#pragma mark - 门禁登陆界面
-(void)welcome
{
    printf("~~~~~XXXX门禁管理系统~~~~~\n");
    printf("~~~~~管理员登陆 1~~~~~\n");
    printf("~~~~~员工登陆 2~~~~~\n");
    printf("~~~~~访客登陆 3~~~~~\n");
    printf("~~~~~退出 0~~~~~\n");
    //进行输入操作
    [self input];
}
#pragma mark- 身份登录的输入
-(void)input{
    int num;
    scanf("%d",&num);
    switch (num) {
        case 1:
            //管理员登录
            [self managerLog];
            break;
        case 2:
            //员工
            [self employLog];
            break;
        case 3:
            //访客
            break;
        case 0:
            //退出
            exit(0);
            
        default:
            printf("输入有误...\n");
            [self welcome];
            break;
    }
}
#pragma mark - 员工登陆
-(void)employLog
{
    //1.先判断文件在不在
    if ([self.fm fileExistsAtPath:employeP]&&self.fArray.count>0)
    {
        //文件有内容
        char *name=malloc(30);
        printf("输入员工账号...\n");
        scanf("%s",name);
        char *pass=malloc(30);
        printf("输入员工密码...\n");
        scanf("%s",pass);
        //封装
        NSString *nameStr=[NSString stringWithUTF8String:name];
        BOOL flag=NO;
        //比较
        for (NSDictionary *dic in self.fArray)
        {
            if ([dic[@"name"] isEqualToString:nameStr] && [dic[@"pass"] isEqualToString:[NSString stringWithUTF8String:pass]])
            {
                flag=YES;
                printf("员工(%s)登陆成功...\n",name);
                //给全局员工账号 密码赋值
                self.emName=nameStr;
                self.emPass=dic[@"pass"];
                //员工操作界面
                [self employeeShow];
            }
        }
        if (!flag)
        {
            printf("员工账号不存在或密码有误...\n");
            [self employLog];
        }
    }
    else
    {
        printf("没有员工信息...\n");
        [self welcome];
    }
}
#pragma mark - 员工操作界面
-(void)employeeShow
{
    printf("~~~~~员工操作界面~~~~~\n");
    printf("~~~~~修改自身密码 1~~~~~\n");
    printf("~~~~~查看自身信息 2~~~~~\n");
    printf("~~~~~返回上一级 0~~~~~\n");
    printf("~~~~~~~~~~~~~~~~~~~~~\n");
    [self employeeInput];
}
-(void)employeeInput
{
    int num;
    scanf("%d",&num);
    switch (num)
    {
        case 1:
        {
            //修改自身密码
            [self updateEmployeeSelf];
            break;
        }
        case 2:
            //查看自身信息
            printf("当前信息:%s-%s\n",[self.emName UTF8String],[self.emPass UTF8String]);
            //再次显示员工操作界面
            [self employeeShow];
            break;
        case 0:
            [self welcome];
            break;
            
        default:
            printf("输入有误...\n");
            [self employeeShow];
            break;
    }
}
#pragma mark - 员工修改自身信息
-(void)updateEmployeeSelf
{
    //1.输入旧密码
    printf("输入旧密码...\n");
    char *pass=malloc(30);
    scanf("%s",pass);
    //2.与属性作比较
    if ([self.emPass isEqualToString:[NSString stringWithUTF8String:pass]])
    {
        //3.输入新密码
        printf("输入新密码...\n");
        char *pass2=malloc(30);
        scanf("%s",pass2);
        //4.确认新密码
        printf("确认新密码...\n");
        char *pass3=malloc(30);
        scanf("%s",pass3);
        if (strcmp(pass2, pass3)==0)
        {
            //5.将新的密码和账号再次封装写入文件--->为了在调用时能够从文件里读取！！！
            self.emPass=[NSString stringWithUTF8String:pass3];
            for (NSDictionary *dic in self.fArray)
            {
                if ([dic[@"name"] isEqualToString:self.emName])
                {
                    //修改数组中该员工所在的字典！
#if 0
                    [dic setValue:self.emPass forKey:@"pass"];
#else
//这段代码是修改bug的。
                    NSDictionary *dic2 = [[NSDictionary alloc] init];
                    dic2 = @{@"name":self.emName,@"pass":self.emPass};
                    [self.fArray removeObject:dic];
                    [self.fArray addObject:dic2];
                    
#endif
                    
                    [self.fArray writeToFile:employeP atomically:YES];
                    //6.修改成功，员工操作界面再次显示
                    printf("员工信息修改成功...\n");
                    [self employeeShow];
                    break;
                }
            }
        }
        else
        {
            printf("两次密码不一致...\n");
            [self updateEmployeeSelf];
        }
    }
    else
    {
        printf("旧密码输入有误...\n");
        [self updateEmployeeSelf];
    }
}
#pragma mark- 管理员的登录
-(void)managerLog
{
    printf("请输入管理员账号....\n");
    char *name=malloc(30);
    char *pass=malloc(30);
    scanf("%s",name);
    printf("请输入管理员密码...\n");
    scanf("%s",pass);
    //比较
    //1.封装为OC
    NSString *nameStr=[NSString stringWithUTF8String:name];
    NSString *passStr=[NSString stringWithUTF8String:pass];
    //1.获取文件内容
    if ([self.fDic[@"name"] isEqualToString:nameStr]&&[self.fDic[@"pass"] isEqualToString:passStr])
    {
        //1.登陆成功
        printf("管理员(%s)登陆成功...\n",name);
        //2.管理员相关操作
        [self managerShow];
    }
    else
    {
        printf("账号或密码有误，是否重新输入(y/n?)\n");
        char yn='\0';
        //先获取上一次回车
        getchar();
        scanf("%c",&yn);
        if (yn == 'y'||yn == 'Y')
        {
            [self managerLog];
        }
        else
        {
            [self welcome];
        }
    }
}
#pragma mark - 管理员的相关操作
-(void)managerShow
{
    printf("~~~~~管理员操作界面~~~~~\n");
    printf("~~~~~修改自身密码 1~~~~~\n");
    printf("~~~~~增加员工信息 2~~~~~\n");
    printf("~~~~~浏览员工信息 3~~~~~\n");
    printf("~~~~~修改员工信息 4~~~~~\n");
    printf("~~~~~删除员工信息 5~~~~~\n");
    printf("~~~~~返回上一级 0~~~~~\n");
    [self managerInput];
}
#pragma mark-管理员的输入
-(void)managerInput
{
    int num;
    scanf("%d",&num);
    switch (num) {
        case 1:
            //修改自身密码
            [self updateMagager];
            break;
        case 2:
            //增加员工
            [self addEmployee];
            break;
        case 3:
            //浏览员工
            [self scanEmployee];
            break;
        case 4:
            //修改员工
            [self updateEmployee];
            break;
        case 5:
            //删除员工
            [self deleEmployee];
            break;
        case 0:
            //返回上一级
            [self welcome];
            break;
        default:
            printf("输入有误...\n");
            [self managerShow];
            break;
    }
}
#pragma mark  - 删除员工
-(void)deleEmployee
{
    if ([self.fm fileExistsAtPath:employeP]&&self.fArray.count>0) //员工文件存在
    {
        //输入账号
        char *name=malloc(30);
        printf("输入员工账号...\n");
        scanf("%s",name);
        BOOL flag=NO;
        //判断输入的账号是否存在
        for (NSDictionary *dic in self.fArray)
        {
            if ([dic[@"name"] isEqualToString:[NSString stringWithUTF8String:name]])
            {
                flag=YES;
                //信息存在,删除
                [self.fArray removeObject:dic];
                //再次写入文件
                [self.fArray writeToFile:employeP atomically:YES];
                printf("员工(%s)删除成功...\n",name);
                break;
            }
        }
        if (!flag)
        {
           printf("该员工信息不存在，无法删除...\n");
        }
    }
    else
    {
        printf("没有员工信息...\n");
    }
    [self managerShow];
}
#pragma mark - 修改员工
-(void)updateEmployee
{
    if ([self.fm fileExistsAtPath:employeP]&&self.fArray.count>0) //员工文件存在
    {
        //输入账号
        char *name=malloc(30);
        printf("输入员工账号...\n");
        scanf("%s",name);
        BOOL flag=NO;
        //判断输入的账号是否存在
        for (NSDictionary *dic in self.fArray)
        {
            if ([dic[@"name"] isEqualToString:[NSString stringWithUTF8String:name]])
            {
                flag=YES;
                break;
            }
        }
        if (flag)
        {
            //信息存在，可以修改
            printf("员工信息存在，进行修改相关操作...\n");//自己完善
        }
        else
        {
            printf("该员工信息不存在，无法修改...\n");
        }
    }
    else
    {
        printf("没有员工信息...\n");
    }
    [self managerShow];
}
#pragma mark - 浏览员工
-(void)scanEmployee
{
    if (self.fArray.count>0)
    {
        //显示信息
        printf("~~~~~员工信息~~~~~\n");
        for (NSDictionary *dic in self.fArray)
        {
            printf("name:%s,pass:%s\n",[dic[@"name"] UTF8String],[dic[@"pass"] UTF8String]);
        }
        printf("~~~~~~~~end~~~~~~~\n");
    }
    [self managerShow];
}
#pragma mark - 增加员工
-(void)addEmployee
{
    char *name=malloc(30);
    printf("输入员工账号...\n");
    scanf("%s",name);
    BOOL flag=NO;
    if ([self.fm fileExistsAtPath:employeP]) //员工文件存在
    {
        //判断该账号是否已经加入文件
        for (NSDictionary *dic in self.fArray)
        {
            if ([dic[@"name"] isEqualToString:[NSString stringWithUTF8String:name]])
            {
                printf("该员工已经存在，添加失败...\n");
                flag=YES;
                break;
            }
        }
        if (flag==NO)
        {
            char *pass=malloc(30);
            printf("输入员工密码...\n");
            scanf("%s",pass);
            //封装为字典
            NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:name],@"name",[NSString stringWithUTF8String:pass],@"pass", nil];
            //将字典加入数组
            [self.fArray addObject:dic];
            //写入文件
            [self.fArray writeToFile:employeP atomically:YES];
            printf("员工录入成功...\n");
        }
    }
    else//员工文件不存在
    {
        char *pass=malloc(30);
        printf("输入员工密码...\n");
        scanf("%s",pass);
        //封装为字典
        NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:name],@"name",[NSString stringWithUTF8String:pass],@"pass", nil];
        //将字典加入数组
        self.fArray=[NSMutableArray array];//必须有内存，才能添加元素
        [self.fArray addObject:dic];
        //写入文件
        [self.fArray writeToFile:employeP atomically:YES];
        printf("员工录入成功...\n");
    }
    [self managerShow];
}
#pragma mark - 管理员修改自身密码
-(void)updateMagager
{
    printf("请输入旧密码...\n");
    char *pass=malloc(30);
    scanf("%s",pass);
    //进行比较
    if ([self.fDic[@"pass"] isEqualToString:[NSString stringWithUTF8String:pass]])
    {
        printf("请输入新密码...\n");
        char *pass2=malloc(30);
        char *pass3=malloc(30);
        scanf("%s",pass2);
        printf("请再次输入新密码...\n");
        scanf("%s",pass3);
        //比较两次密码
        char *name=(char *)[self.fDic[@"name"] UTF8String];
        [self writeManagerwithName:name andPass:pass2 andPass2:pass3 andisRegis:NO];
    }
    else
    {
        printf("旧密码错误，是否重新输入(y/n?)\n");
        [self updateMagager];//自己去调整！
    }
}
#pragma mark- 管理员的注册
-(void)managerRegister
{
    printf("请输入管理员注册账号....\n");
    char *name=malloc(30);
    char *pass=malloc(30);
    char *pass2=malloc(30);
    scanf("%s",name);
    printf("请输入管理员注册密码...\n");
    scanf("%s",pass);
    printf("请再次输入密码...\n");
    scanf("%s",pass2);
    //比较两次输入的密码
    [self writeManagerwithName:name andPass:pass andPass2:pass2 andisRegis:YES];
}
#pragma mark - 管理员的存储
-(void)writeManagerwithName:(char *)name andPass:(char *)pass andPass2:(char *)pass2 andisRegis:(BOOL)flag
{
    //1.将C的字符串转化为OC字符串，方便写入文件
    NSString *nameStr=[NSString stringWithUTF8String:name];
    NSString *passStr=[NSString stringWithUTF8String:pass];
    NSString *passStr2=[NSString stringWithUTF8String:pass2];
    if ([passStr isEqualToString:passStr2])
    {
        //可以写入文件
        //1.先封装为字典
        self.fDic=[NSDictionary dictionaryWithObjectsAndKeys:nameStr,@"name",passStr,@"pass", nil];
        //2.写入文件
        [self.fDic writeToFile:managerP atomically:YES];
        //3.反馈
        if (flag)
        {
            printf("管理员注册成功\n");
        }
        else
        {
            printf("管理员密码修改成功   \n");
           // NSLog(@"%@",[self.fm currentDirectoryPath]);
        }
        //4.显示登录界面
        [self welcome];
    }
    else
    {
        printf("两次密码不一致,是否重新输入(y/n?)\n");
        char yn='\0';
        //先获取上一次回车
        getchar();
        scanf("%c",&yn);
        if (yn == 'y'||yn == 'Y')
        {
            printf("请设置密码...\n");
            scanf("%s",pass);
            printf("再次输入密码...\n");
            scanf("%s",pass2);
            //比较密码是否一致
            [self writeManagerwithName:name andPass:pass andPass2:pass2 andisRegis:flag];
        }
        else
        {
            printf("退出系统...\n");
            exit(0);
        }
    }
}
@end
