//
//  Gamplay.m
//  PeevedPenguins
//
//  Created by Nikola Mijanovik on 6/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gamplay.h"
#import "Penguin.h"
static const float MIN_SPEED = 5.f;

@implementation Gamplay
{
    CCPhysicsNode *_physicsNode;
    CCNode *_catapultArm;
    CCNode *_levelNode;
    CCButton * _retryButton;
    CCNode * _contentNode;
    CCNode * _pullbackNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    Penguin *_currentPenguin;
    CCPhysicsJoint *_penguinCatapultJoint;
    CCAction *_followPenguin;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    _physicsNode.debugDraw = TRUE;
    _physicsNode.collisionDelegate = self;
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];

}

- (void)launchPenguin {
    
    // loads the Penguin.ccb we have set up in Spritebuilder
    _currentPenguin =(Penguin*)[CCBReader load:@"Penguin"];
    // position the penguin at the bowl of the catapult
    _currentPenguin.position = ccpAdd(_catapultArm.position, ccp(50,100));
    _currentPenguin.physicsBody.force = ccp(100,100);
    // add the penguin to the physicsNode of this scene (because it has physics enabled)
    [_physicsNode addChild:_currentPenguin];
    
    // manually create & apply a force to launch the penguin
    CGPoint launchDirection = ccp(1, 0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [_currentPenguin.physicsBody applyForce:force];
    
    // ensure followed object is in visible are when starting
    self.position = ccp(0, 0);
    _followPenguin = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
    [_contentNode runAction:_followPenguin];
}

- (void)retry {
    // reload this level
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gamplay"]];
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    // start catapult dragging when a touch inside of the catapult arm occurs
    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation))
    {
        
        // move the mouseJointNode to the touch position
        _mouseJointNode.position = touchLocation;
        
        // setup a spring joint between the mouseJointNode and the catapultArm
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0, 0) anchorB:ccp(34, 138) restLength:0.0f stiffness:3000.f damping:150.f];
        
    }
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    // whenever touches move, update the position of the mouseJointNode to the touch position
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

- (void)releaseCatapult {
    if (_mouseJoint != nil)
    {
        // releases the joint and lets the catapult snap back
        _currentPenguin.launched = TRUE;
        [self launchPenguin];
        [_mouseJoint invalidate];
        _mouseJoint = nil;
    }
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    // when touches end, meaning the user releases their finger, release the catapult
    [self releaseCatapult];
}

-(void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    // when touches are cancelled, meaning the user drags their finger off the screen or onto something else, release the catapult
    [self releaseCatapult];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    CCLOG(@"Something collided with a seal!");
}

- (void)update:(CCTime)delta
{
     if (_currentPenguin.launched) {
         
        // if speed is below minimum speed, assume this attempt is over
        if (ccpLength(_currentPenguin.physicsBody.velocity) < MIN_SPEED){
            [self nextAttempt];
            return;
        }
        
        int xMin = _currentPenguin.boundingBox.origin.x;
        
        if (xMin < self.boundingBox.origin.x) {
            [self nextAttempt];
            return;
        }
        
        int xMax = xMin + _currentPenguin.boundingBox.size.width;
        
        if (xMax > (self.boundingBox.origin.x + self.boundingBox.size.width)) {
            [self nextAttempt];
            return;
        }
     }
}

- (void)nextAttempt {
    _currentPenguin = nil;
    [_contentNode stopAction:_followPenguin];
    _followPenguin=nil;
    
    CCActionMoveTo *actionMoveTo = [CCActionMoveTo actionWithDuration:2.0f position:ccp(0, 0)];
    [_contentNode runAction:actionMoveTo];
}

@end
