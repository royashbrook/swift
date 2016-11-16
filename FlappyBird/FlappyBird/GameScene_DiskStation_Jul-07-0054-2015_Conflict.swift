//
//  GameScene.swift
//  FlippyKale
//
//  Created by Roy Ashbrook on 6/15/15.
//  Copyright (c) 2015 Roy Ashbrook. All rights reserved.
//

import SpriteKit
import AVFoundation

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
    var isGameOver      = true
    
    //fires when you touch the screen
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

        if self.view!.paused { //if the game is over
            
            //unpause view
            self.view!.paused = false
            
            //make background game not over color
            self.backgroundColor = UIColor.whiteColor()
            
            //reset score
            self.score = 0
            
            if (self.hero.parent == nil) {
                self.addChild(self.hero)
            }
        }else {
            self.hero.runAction(heroFlip)
        }
    }

    
    //runs whenever the screen is updated
    override func update(currentTime: CFTimeInterval) {
        
        //end game if hero not on screen
        if (!heroOnScreen()) {
            
            //pause view
            self.view!.paused = true
            
            //mark game over
            self.isGameOver = true
            
            //make background game over color
            self.backgroundColor = UIColor.grayColor()
            
            //reset hero position
            self.hero.position = CGPoint(x: self.frame.size.width * 0.40, y: self.frame.size.height * 0.5)
            self.hero.removeFromParent()
            
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
    /*
    func didBeginContact(contact: SKPhysicsContact) {
        endGame()
    }*/
    
    func setupEverything(){
                
        self.view?.paused = true
        self.physicsWorld.gravity           = CGVectorMake( 0.0, -4.5 )
        self.physicsWorld.contactDelegate   = self
        
        setupScoreLabel()
        setupHero()
        doSetup()
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
        var heroTexture = SKTexture(imageNamed: "Kale")
        self.hero = SKSpriteNode(texture: heroTexture)
        self.hero.setScale(0.5)
        self.hero.position = CGPoint(x: self.frame.size.width * 0.40, y: self.frame.size.height * 0.7)
        self.hero.physicsBody = SKPhysicsBody(circleOfRadius: self.hero.size.height/1.75)
        self.hero.physicsBody!.dynamic = true
        
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
    
    func doSetup() {
        
        //todo: add floor/ceiling/etc
        /*
        //ground
        //todo: fix the ground, it functions but isn't clean currently
        var GroundTexture = SKTexture(imageNamed: "Background")
        var sprite = SKSpriteNode(texture: GroundTexture)
        
        var ground = SKNode()
        ground.position = CGPointMake(0, GroundTexture.size().height)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, GroundTexture.size().height * 1.65))
        ground.physicsBody!.dynamic = false
        self.addChild(ground)
        */
        
        //pipes
        
        //create pipes
        let halfFlip:CGFloat = 3.14159265
        //rotatePipe = SKAction.rotateByAngle(halfFlip, duration: NSTimeInterval(0))
        let pipeUpTexture = SKTexture(imageNamed: "PipeUp")
        let pipeDownTexture = SKTexture(imageNamed: "PipeDown")
        
        //movement of pipes
        //todo: make it harder the longer you last
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * pipeUpTexture.size().width) * 1.25 //speed it up a little
        let movePipes = SKAction.moveByX(-distanceToMove, y: 0.0, duration: NSTimeInterval(0.01 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        let pipesMoveAndRemove = SKAction.sequence([movePipes,removePipes])
        
        //spawn pipes
        let spawn = SKAction.runBlock({() in self.spawnPipes(pipeUpTexture,pipeDownTexture: pipeDownTexture, pipesMoveAndRemove: pipesMoveAndRemove)})
        let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawn,delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
    }
    
    func spawnPipes(pipeUpTexture:SKTexture,pipeDownTexture:SKTexture, pipesMoveAndRemove:SKAction){
        
        
        //const
        let pipeGap = 170.0

        //todo: use the same image, just mirror it
        let pipePair = SKNode()
        pipePair.position = CGPointMake(self.frame.size.width + pipeUpTexture.size().width * 2, 0)
        pipePair.zPosition = -10
        
        let height = UInt32(self.frame.size.height/4)
        let y = arc4random() % height + height
        
        let pipeDown = SKSpriteNode(texture: pipeDownTexture)
        pipeDown.setScale(0.4)
        pipeDown.position = CGPointMake(0.0, CGFloat(y) + pipeDown.size.height + CGFloat(pipeGap))
        
        pipeDown.physicsBody = SKPhysicsBody(rectangleOfSize: pipeDown.size)
        pipeDown.physicsBody?.dynamic = false
        
        pipePair.addChild(pipeDown)
        
        let pipeUp = SKSpriteNode(texture: pipeUpTexture)
        pipeUp.setScale(0.4)
        pipeUp.position = CGPointMake(0.0, CGFloat(y))
        pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
        pipeUp.physicsBody?.dynamic = false
        
        pipePair.addChild(pipeUp)
        pipePair.runAction(pipesMoveAndRemove)
        
        self.addChild(pipePair)
    }

}
