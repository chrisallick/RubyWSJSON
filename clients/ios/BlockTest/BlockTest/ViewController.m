//
//  ViewController.m
//  BlockTest
//
//  Created by chrisallick on 5/20/13.
//  Copyright (c) 2013 chrisallick. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableDictionary *events = [[NSMutableDictionary alloc] init];

    [events setObject:[^{
        NSLog(@"void block in dictionary no params");
    } copy] forKey:@"boom"];
    
    [events setObject:[^(NSString *msg){
        NSLog(@"void block in dictionary with string param: %@", msg);
    } copy] forKey:@"boom2"];
    
    void (^myStringBlock)() = ^(NSString *msg) {
        NSLog(@"void block that takes string: %@", msg);
    };
    
    void (^myVoidBlock)() = ^{
        NSLog(@"void block with no params");
    };
    
    [self execute:@"awesome" withVoidBlock:^{
        NSLog(@"not passing pointer to block");
    }];
    
    [self execute:@"cool!" withVoidBlock:myVoidBlock];
    [self execute:@"cool!" withStringBlock:myStringBlock];
    
    
    NSString *e = @"boom";
    NSString *m = @"cool!";
    
    [self execute:m withVoidBlock:[events objectForKey:e]];
    [self execute:@"cool!" withStringBlock:[events objectForKey:@"boom2"]];
}

-(void)execute:(NSString *)msg withVoidBlock:(void (^)(void))block {
    block();
}

-(void)execute:(NSString *)msg withStringBlock:(void (^)(NSString *))block {
    block(msg);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
