//
//  ViewController.m
//  CoreDataProject
//
//  Created by 张树青 on 16/1/12.
//  Copyright (c) 2016年 zsq. All rights reserved.
//


//当前 工程 实现 通过coreData 将数据存入数据库 再将数据中的数据转换为模型

/**
 1.需要在工程中创建一个coreData模型 (文件后缀名 .xcdataModel)
 //假设有一个模型 Student 属性 name age ID
 
 2.根据coreData模型 创建出一个模型类 (OC的模型类对象用于存储数据的 继承于NSManagedObejct 并不是直接继承与NSObject )可以直接通过coreData 将数据库中的记录转换为该模型的对象 并且将对应的值赋值给对象的属性
 注意: Xcode7 以后 模型类生成四个文件 模型类以及模型类的类别拓展 实现的功能与使用 跟Xcode7之前是一致的 
 
 3.将coreData与数据库关联 进行App与数据库的交互
 (1)导入coreData头文件<CoreData/CoreData.h> 与模型类头文件(Student.h)
 (2)NSManagedObjectContext 其对象 是管理App与数据库交互的 是被管理对象的上下文 如果App希望与数据库进行交互  必须有一个NSManagedObjectContext的对象作为中间的桥梁 
 (3)通过代码将CoreDataModel生成的模型类 与数据库关联 做好数据交互的准备
 
 */
#import "ViewController.h"
#import <CoreData/CoreData.h>//coreData支持框架
#import "Student.h"//生成的模型 用于数据的存储


@interface ViewController ()

@property (nonatomic, strong) NSManagedObjectContext *context;
//(2)用于App与数据库交互的 可以提供增删改查
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self prepareAppAndDataBase];
}

#pragma mark -- App与数据交互的准备工作
//(3)
- (void)prepareAppAndDataBase{
    //1.获取coreDataModel的路径 (StudentModel.xcdatamodeld)
    NSString *path = [[NSBundle mainBundle] pathForResource:@"StudentModel" ofType:@"momd"];
    //注意: coreDataModel 虽然现实在工程下的文件后缀名是.xcdatamodeld 但是在读取路径时 使用的是momd格式 系统规定的 切记不要写错
    
    //2.根据路径找到coreDataModel 生成一个被管理对象模型 被管理对象模型需要交给context 由context来管理
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    
    //3.将模型的数据存入数据库 需要一个持久化存储协调器 协调器可以操作被管理对模型与数据库关联
    /*例如  coreDataModel : Student Person 分别对应两个模型
      将coreDataModel 转换为NSManagedObjectModel对象 这个对象包含了Student 和Person 可以与数据库交互
     通过协调器将NSManagedObjectModel的对象 与某一个数据库关联起来 
     通过context就可以将模型与数据库进行交互
    */
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    //4.关联数据库
    //(1)创建一个数据库
    //拼接数据库地址 在对应的路径下生成数据库
    NSString *dataBasePath = [NSString stringWithFormat:@"%@/Documents/Students.db", NSHomeDirectory()];
    NSLog(@"%@", dataBasePath);
    
    NSError *error = nil;
    //一个仓库 提供一个数据存储的空间 在生产仓库的时候 就是创建了数据库 并且能够将仓库返回
    
    //strore 在这里 暂时没有用
    //有用的是coordinator 调用的方法 可以产生数据库
    NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dataBasePath] options:nil error:&error];
    //第一个参数: 关联的数据库类型 NSSQLiteStoreType 表示SQLite数据库
    //第二个参数: 给个默认值nil
    //第三个参数: 数据库的路径
    //第四个参数: 仓库的相关设置 给个默认值nil
    //第五个参数: 保存关联错误的error对象地址
    
    //判断是否关联成功
    if (error){
        NSLog(@"关联失败");
        NSLog(@"%@", error.localizedDescription);
    } else{
        NSLog(@"关联成功");
    }
    
    //5.把仓库交给context管理
    //(1)初始化context
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    /**
    NSConfinementConcurrencyType     保留原来coreData设置 (以下两种中任意一种都有可能)
    NSPrivateQueueConcurrencyType    GCD队列 防止主线程阻塞
    NSMainQueueConcurrencyType       NSOperationQueue 下的MainQueue 主队列 有可能造成主线程的阻塞
     造成阻塞的原因: 数据的存储 读取等操作会放到主线程中来实现  假设读取的时间比较长 操作的动作持续比较久 后面的请求需要等待 类似于同步请求中的假死 造成阻塞
     */
    //(2)将设置好的协调器 关联到context上
    _context.persistentStoreCoordinator = coordinator;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 添加数据
- (IBAction)addClick:(id)sender {
    //向数据库中添加数据 通过对应的模型 (Student模型类的对象)
    
    //(1)创建Student的对象 用于存储需要添加的数据
    Student *elean = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:_context];
    //创建的方式 通过NSEntityDescription实体类的类方法 创建的
    //第一个参数: 表示生产的对象 是哪一个模型类的 写类名字符即可
    //第二个参数: App与数据库交互 谁是管理者 _context
    //方法的返回值: 就是@"Student"类的实例化对象 里面带有name stuID age属性
    
    //(2)将数据赋值给属性
    elean.name = @"Elean";
    elean.age = @(18);
    elean.stuID = @(1001);
    
    //(3)将数据添加到数据库
    NSError *error = nil;
    BOOL isOk = [_context save:&error];
    //判断操作成功的条件: 1.isOK 2.error
    //只要是通过实例类的方法 创建出对象 当context执行 save方法 系统会自动将对象的属性 写入数据库
    if (isOk) {
        NSLog(@"添加数据成功");
    } else {
        NSLog(@"添加数据失败");
    }
}
#pragma mark -- 删除数据
- (IBAction)deleteClick:(id)sender {
    //删除数据 需要先把符合删除条件的所有数据获取 调用delete方法 删除 再调用save方法将操作结果保存 否则即使是执行了delete方法 数据库中的数据依然没有改变
    //把学生名中包含'e'这个字符的学生信息都删除
    
    //1.先获取所有符合条件的数据
    //(1)设置查询条件
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"%K like %@", @"name", @"*e*"];
    //注意: 包含语句时 *号 应该作为拼接的字符串放在后边拼接进去 不能直接写在前面.
    //将名字中包含e的所有学生信息返回
    
    //name like *e* 查询那么属性的值 包含e
    
    //(2)将查询结果返回
    NSArray *array = [_context executeFetchRequest:request error:nil];
    
    //2.将满足条件的数据删除
    for (Student *stu in array) {
        [_context deleteObject:stu];
        //删除
    }
    //[_context deletedObjects:[NSSet setWithArray:array]];
    
    BOOL isOK = [_context save:nil];
    //强调: 如果对数据库总的信息做出修改 比如删除 添加 更新 都一定要在操作 的最后一个加上save 把操作的结果保存
    
    if (isOK) {
        NSLog(@"删除成功");
    } else {
        NSLog(@"删除失败");
    }
}
#pragma mark -- 修改数据
- (IBAction)updateClick:(id)sender {
    //修改也是先将满足条件的数据获取 修改之后再保存
    
    //1.查询
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    request.predicate = [NSPredicate predicateWithFormat:@"%K < 20", @"age"];
    
    NSError *error = nil;
    NSArray *array = [_context executeFetchRequest:request error:&error];
    
    //2.修改
    for (Student *stu  in array) {
        stu.age = @(20);
        //将年龄增加一岁
    }
    BOOL isOK = [_context save:nil];
    if (isOK) {
        NSLog(@"数据修改成功");
    } else {
        NSLog(@"数据修改失败");
    }
    
}
#pragma mark -- 查询数据
- (IBAction)queryClick:(id)sender {
    //查询 需要借助一个类 NSFetchRequest 通过该类的对象进行查询
    //1.创建NSFetchRequest的实例化对象
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Student"];
    //需要设置查询到 是哪一个实例 (模型类)
    
    //2.设置查询条件
    request.predicate = [NSPredicate predicateWithFormat:@"%K=1001", @"stuID"];
    //%K 字段名
    
    //3.通过context将查询的结果返回
    NSError *error = nil;
    NSArray *array = [_context executeFetchRequest:request error:&error];
    if (error){
        NSLog(@"查询失败");
        NSLog(@"%@", error.localizedDescription);
    } else{
        NSLog(@"查询成功");
    }

    
    //4.将array中的数据 遍历打印
    //request中设置查询的是哪一种模型 array中存放飞就是模型的对象
    for (Student *stu in array) {
        NSLog(@"\nstuID: %@\nname: %@\nage: %@", stu.stuID, stu.name, stu.age);
    }
}
@end
