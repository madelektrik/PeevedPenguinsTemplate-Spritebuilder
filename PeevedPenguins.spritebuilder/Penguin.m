//
//  Penguin.m
//  PeevedPenguins
//
//  Created by Nikola Mijanovik on 6/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Penguin.h"

@implementation Penguin
//- (id)init {
//    self = [super init];
//    
//    if (self) {
//        CCLOG(@"Penguin created");
//    }
//    
//    return self;
//}

-(void)onEnter
{
    [super onEnter];
    
    self.physicsBody.force = ccp(0.5,0.5);
}
@end
