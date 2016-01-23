//
//  Student.h
//  CoreDataProject
//
//  Created by 张树青 on 16/1/12.
//  Copyright (c) 2016年 zsq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Student : NSManagedObject

//根据coreData模型 StudentModel中 Student 生成同名的类 类中的属性 与Student中是一样的 如果Student属性类型是基本数据类型 生成模型时 转换为NSNumber类型
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * stuID;

@end
