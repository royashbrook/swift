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
    
    //const
    let pipeGap = 170.0

    //var
    var kale = SKSpriteNode()
    var pipeUpTexture = SKTexture()
    var pipeDownTexture = SKTexture()
    var pipesMoveAndRemove = SKAction()


    //flip support
    var flip = SKAction()
    var scoreLabel      = SKLabelNode()
    var startLabel      = SKLabelNode()
    var score           = 0
    var isGameOver      = true
    

    //fires when we move to this view
    override func didMoveToView(view: SKView) {
        setupEverything()
        endGame()
        //now just wait for a touch
    }
    //fires when you touch the screen
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if self.isGameOver { //if the game is over
            // reset score
            self.score = 0
            scoreLabel.text = "0"
            self.startGame() // start the game
        } else {
            //flip!
            //for touch: AnyObject in touches { self.runAction(flip) }
            self.kale.runAction(flip)
            
            // update the score
            self.score++
            scoreLabel.text = String(score)
        }

    }
    func setupEverything(){
        self.view?.paused = true
        self.physicsWorld.gravity           = CGVectorMake( 0.0, -5.0 )
        self.physicsWorld.contactDelegate   = self
        
        setupStartLabel()
        setupScoreLabel()
        setupHero()
    }
    /*
    //runs whenever the screen is updated
    override func update(currentTime: CFTimeInterval) {
        
        //if the game isn't over
        if !self.isGameOver{
            

            
            //end game if hero not on screen
            if (kale.position.y < -kale.size.height/2.0 || kale.position.y > self.size.width+kale.size.height/2.0) {
                
                //pause view
                self.view?.paused = true
                
                //mark game over
                self.isGameOver = true
                
                //make background game over color
                self.backgroundColor = UIColor.grayColor()
                
                //reset hero position
                kale.position = CGPoint(x: self.frame.size.width * 0.40, y: self.frame.size.height * 0.7)
                
                //make score big and add it to screen
                scoreLabel.fontSize = 50
                self.addChild(scoreLabel)
                
                //add start button
                self.addChild(startLabel)
            }
        }
        
    }*/
    func startGame() {
        
        //mark game not over
        self.isGameOver = false
        
        //make background game not over color
        self.backgroundColor = UIColor.whiteColor()
        
        //make score small and add it to screen
        scoreLabel.text = "0" //reset score
        scoreLabel.fontSize = 30
        
        //self.addChild(pipes)
        
        //unpause view
        self.view?.paused = false
        
    }
    func endGame() {
        
        //pause view
        self.view?.paused = true
        
        //mark game over
        self.isGameOver = true
        
        //make background game over color
        self.backgroundColor = UIColor.grayColor()
        
        //reset hero position
        kale.position = CGPoint(x: self.frame.size.width * 0.40, y: self.frame.size.height * 0.7)
        
        //make score big and add it to screen
        scoreLabel.fontSize = 50
        self.addChild(scoreLabel)
        
        //add start button
        self.addChild(startLabel)
        
    }
    
    //helper
    func heroOnScreen() -> Bool{
        return (kale.position.y < -kale.size.height/2.0 || kale.position.y > self.size.width+kale.size.height/2.0)
    }
    /*func didBeginContact(contact: SKPhysicsContact) {
        endGame()
    }*/

    //create the startLabel/button
    func setupStartLabel() {
        let message = "Tap to start!"
        startLabel.text         = message
        startLabel.fontSize     = 30
        startLabel.fontColor    = UIColor.redColor()
        startLabel.fontName     = "Chalkduster"
        startLabel.position     = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + (CGRectGetMidY(self.frame) / 3) )
        self.addChild(startLabel)
    }
    //create the score label
    func setupScoreLabel() {
        let startingScore       = "0"
        scoreLabel.text         = startingScore
        scoreLabel.fontSize     = 30
        scoreLabel.fontColor    = UIColor.blackColor()
        startLabel.fontName     = "Chalkduster"
        scoreLabel.position     = CGPointMake( CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + (CGRectGetMidY(self.frame) / 2) )
        self.addChild(scoreLabel)
    }
    //setup the "hero"
    func setupHero() {
        
        //sprite
        var kaleTexture = SKTexture(imageNamed: "Kale")
        kale = SKSpriteNode(texture: kaleTexture)
        kale.setScale(0.5)
        kale.position = CGPoint(x: self.frame.size.width * 0.40, y: self.frame.size.height * 0.7)
        kale.physicsBody = SKPhysicsBody(circleOfRadius: kale.size.height/1.75)
        kale.physicsBody!.dynamic = true
        self.addChild(kale)

        
        //flip
        let flipTwice: CGFloat = -12.5663706 //let flipOnce: Int = -6.28318531 //in Radians vs Degrees
        let flipAnimation: SKAction = SKAction.rotateByAngle(flipTwice, duration: NSTimeInterval(0.5))
        let flipSoundFile: NSURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("flip", ofType: "wav")!)!
        let flipSoundPlayer: AVAudioPlayer = AVAudioPlayer(contentsOfURL: flipSoundFile, error: nil)
        flipSoundPlayer.prepareToPlay()

        flip = SKAction.runBlock({
            flipSoundPlayer.play()                                              //play sound
            self.kale.physicsBody?.velocity = CGVectorMake(0, 0)                //stop sprite
            self.kale.physicsBody?.applyImpulse(CGVectorMake(0,35))             //move sprite up
            self.kale.runAction(flipAnimation)                                  //rotate sprite
        })

    }
    
 


    
    /*
    func restart() {
        var s = GameScene(size: self.size)
        s.scaleMode = .AspectFill
        self.view?.presentScene(s)
    }
    // overrides for restart
    override init() {
        super.init()
    }
    
    required override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder?) {
        super.init(coder: aDecoder!)
    }
*/
    
    func doSetup() {
        self.setupStartLabel()
        
        
        
        
        //ground
        //todo: fix the ground, it functions but isn't clean currently
        var GroundTexture = SKTexture(imageNamed: "Background")
        var sprite = SKSpriteNode(texture: GroundTexture)
        
        var ground = SKNode()
        ground.position = CGPointMake(0, GroundTexture.size().height)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, GroundTexture.size().height * 1.65))
        ground.physicsBody!.dynamic = false
        self.addChild(ground)
        
        
        //pipes
        
        //create pipes
        let halfFlip:CGFloat = 3.14159265
        //rotatePipe = SKAction.rotateByAngle(halfFlip, duration: NSTimeInterval(0))
        pipeUpTexture = SKTexture(imageNamed: "PipeUp")
        pipeDownTexture = SKTexture(imageNamed: "PipeDown")
        
        //movement of pipes
        
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * pipeUpTexture.size().width) * 1.25 //speed it up a little
        let movePipes = SKAction.moveByX(-distanceToMove, y: 0.0, duration: NSTimeInterval(0.01 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        pipesMoveAndRemove = SKAction.sequence([movePipes,removePipes])
        
        //spawn pipes
        
        let spawn = SKAction.runBlock({() in self.spawnPipes()})
        let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawn,delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
    }
    
    func spawnPipes(){
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
