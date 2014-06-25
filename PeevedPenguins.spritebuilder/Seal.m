//
//  Seal.m
//  PeevedPenguins
//
//  Created by Nikola Mijanovik on 6/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Seal.h"

@implementation Seal
- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"seal";
}
@end
