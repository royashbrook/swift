//
//  GameScene.swift
//  FlippyKale
//
//  Created by Roy Ashbrook on 6/15/15.
//  Copyright (c) 2015 Roy Ashbrook. All rights reserved.
//

import SpriteKit
import AVFoundation

struct PhysicsCategory {
    static let hero     :UInt32 = 1
    static let enemy    :UInt32 = 2
    //static let pipeUp   :UInt32 = 3
}
class SKNodePair: SKNode{
    
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //fires when we move to this view
    override func didMoveToView(view: SKView) {
        setupEverything()
        //now just wait for a touch
    }
    
    var hero:SKSpriteNode!
    var heroFlip:SKAction!
    var scoreLabel:SKLabelNode!
    var score           = 0
    
    //fires when you touch the screen
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

        if self.view!.paused { //if the game is over
            
            //unpause view
            self.view!.paused = false
            
            //make background game not over color
            self.backgroundColor = UIColor.whiteColor()
            
            //reset score
            self.score = 0
            
            if (self.hero.parent == nil)
            {
                self.addChild(self.hero)
                self.hero.physicsBody!.applyImpulse(CGVectorMake(0, 40))
            }
        }else {
            self.hero.runAction(heroFlip)
        }
    }

    
    //runs whenever the screen is updated
    override func update(currentTime: CFTimeInterval) {
        
        //end game if hero not on screen
        if (!heroOnScreen()) {
            endGame()
        }
        else {
            // update the score
            self.score++
            scoreLabel.text = String(score)
        }
        
    }
    
    //helper
    func heroOnScreen() -> Bool{
        var aboveBottom = self.hero.position.y > -self.hero.size.height/2.0
        var belowTop = self.hero.position.y < (self.size.height + self.hero.size.height/2.0) - 50
        var onScreen = aboveBottom && belowTop
        return onScreen
    }
    func endGame() {
        //pause view
        self.view!.paused = true
        
        //make background game over color
        self.backgroundColor = UIColor.grayColor()
        
        //reset hero position
        self.hero.position = CGPoint(x: self.frame.size.width * 0.40, y: self.frame.size.height * 0.4)
        self.hero.removeFromParent()
        for child in self.children {
            if let node = child as? SKNodePair {
                child.removeFromParent()
            }
        }
    }
    func didBeginContact(contact: SKPhysicsContact) {
        println("contact")//endGame()
    }
    
    func setupEverything(){
                
        self.view?.paused = true
        self.physicsWorld.gravity           = CGVectorMake( 0.0, -4.5 )
        self.physicsWorld.contactDelegate   = self
        
        setupScoreLabel()
        setupHero()
        setupEnemies()
    }
    
    //create the score label
    func setupScoreLabel() {
        self.scoreLabel = SKLabelNode()
        self.scoreLabel.text         = String(self.score)
        self.scoreLabel.fontSize     = 30
        self.scoreLabel.fontColor    = UIColor.blackColor()
        self.scoreLabel.fontName     = "Chalkduster"
        self.scoreLabel.position     = CGPointMake( CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + (CGRectGetMidY(self.frame) / 2) )
        self.addChild(self.scoreLabel)
    }
    //setup the "hero"
    func setupHero() {
        
        //hero sprite
        var heroTexture = SKTexture(imageNamed: "Hero")
        self.hero = SKSpriteNode(texture: heroTexture)
        self.hero.setScale(0.5)
        self.hero.position = CGPoint(x: self.frame.size.width * 0.40, y: self.frame.size.height * 0.4)
        self.hero.physicsBody = SKPhysicsBody(circleOfRadius: self.hero.size.height/1.75)
        self.hero.physicsBody!.dynamic = true
        self.hero.physicsBody?.categoryBitMask = PhysicsCategory.hero
        self.hero.physicsBody?.collisionBitMask = PhysicsCategory.enemy
        
        //hero flip
        let flipTwice: CGFloat = -12.5663706 //let flipOnce: Int = -6.28318531 //in Radians vs Degrees
        let flipAnimation: SKAction = SKAction.rotateByAngle(flipTwice, duration: NSTimeInterval(0.5))
        let flipSoundFile: NSURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("flip", ofType: "wav")!)!
        let flipSoundPlayer: AVAudioPlayer = AVAudioPlayer(contentsOfURL: flipSoundFile, error: nil)
        flipSoundPlayer.volume = 0.5
        flipSoundPlayer.prepareToPlay()

        var flipActions = Array<SKAction>();
        flipActions.append(SKAction.runBlock({ flipSoundPlayer.play() }));
        flipActions.append(SKAction.runBlock({ self.hero.physicsBody!.velocity = CGVectorMake(0, 0) }));
        flipActions.append(SKAction.runBlock({ self.hero.physicsBody!.applyImpulse(CGVectorMake(0,35)) }));
        flipActions.append(flipAnimation);
        self.heroFlip = SKAction.group(flipActions);
    }
    
    func setupEnemies() {
        
        //create pipes
        let halfFlip:CGFloat = 3.14159265
        //rotatePipe = SKAction.rotateByAngle(halfFlip, duration: NSTimeInterval(0))
        let pipeTexture = SKTexture(imageNamed: "Knife")
        //let pipeDownTexture = SKTexture(imageNamed: "PipeDown")
        
        //movement of pipes
        //todo: make it harder the longer you last
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * pipeTexture.size().width) * 1.35 //speed it up a little
        let movePipes = SKAction.moveByX(-distanceToMove, y: 0.0, duration: NSTimeInterval(0.01 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        let pipesMoveAndRemove = SKAction.sequence([movePipes,removePipes])
        
        //spawn pipes
        let spawn = SKAction.runBlock({() in self.spawnPipes(pipeTexture,pipesMoveAndRemove: pipesMoveAndRemove)})
        let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawn,delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
    }
    
    func spawnPipes(pipeTexture:SKTexture,pipesMoveAndRemove:SKAction){
        
        //const
        let pipeGap = 170.0

        //todo: use the same image, just mirror it
        let pipePair = SKNodePair()
        pipePair.position = CGPointMake(self.frame.size.width + pipeTexture.size().width * 2,0)
        pipePair.zPosition = -10
        
        let height = UInt32(self.frame.size.height/4)
        let y = (arc4random() % height + height ) - 170
        
        let pipeDown = SKSpriteNode(texture: pipeTexture)
        pipeDown.setScale(0.6)
        pipeDown.position = CGPointMake(0.0, CGFloat(y) + pipeDown.size.height + CGFloat(pipeGap))
        
        pipeDown.physicsBody = SKPhysicsBody(rectangleOfSize: pipeDown.size)
        pipeDown.physicsBody?.dynamic = false
        pipeDown.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        pipeDown.physicsBody?.collisionBitMask = PhysicsCategory.hero
        
        pipePair.addChild(pipeDown)
        
        let pipeUp = SKSpriteNode(texture: pipeTexture)//pipeDown.copy()
        pipeUp.setScale(0.6)
        pipeUp.position = CGPointMake(0.0, CGFloat(y))
        pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
        pipeUp.physicsBody?.dynamic = false
        pipeUp.yScale = pipeUp.yScale * -1 //mirror image
        pipeUp.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        pipeUp.physicsBody?.collisionBitMask = PhysicsCategory.hero
        
        pipePair.addChild(pipeUp)
        pipePair.runAction(pipesMoveAndRemove)
        
        self.addChild(pipePair)
    }

}
