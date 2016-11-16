//
//  GameScene.swift
//  FlippyKale
//
//  Created by Roy Ashbrook on 6/15/15.
//  Copyright (c) 2015 Roy Ashbrook. All rights reserved.
//

//todo:
//  add increasing difficulty as time goes on
//  different avatars?
//  iads on bottom?
//  make iads only appear when they are populated
//  move knives down overall
//  add tweet/facebook support to pose highscore/screenshot
//  add background

import SpriteKit
import AVFoundation

struct PhysicsCategory {
    static let hero     :UInt32 = 1
    static let enemy    :UInt32 = 2
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
    var heroDeathSound:AVAudioPlayer!
    var scoreLabel:SKLabelNode!
    var highScoreLabel:SKLabelNode!
    var score = 0
    var highScore:Int!
    let jumpVector = CGVectorMake(0, 70.0)
    
    //fires when you touch the screen
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

        if self.view!.paused { //if the game is over
            
            //fix music
            ntMusicPlayer.stop()
            bgMusicPlayer.currentTime = 0
            bgMusicPlayer.play()
            
            //unpause view
            self.view!.paused = false
            
            //make background game not over color
            self.backgroundColor = UIColor.whiteColor()
            
            //reset score
            self.score = 0
            
            if (self.hero.parent == nil)
            {
                self.addChild(self.hero)
                self.hero.physicsBody!.applyImpulse(CGVectorMake(0, 80.0))
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
            scoreLabel.text = "Current: \(self.score)"
            if self.score > self.highScore {
                highScoreLabel.text = "High: \(self.score)"
            }
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
        
        //self.heroDeathSound.currentTime = 0.37
        self.heroDeathSound.play()
        
        //fix music
        bgMusicPlayer.stop()
        ntMusicPlayer.currentTime = 0
        ntMusicPlayer.play()
        
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
        
        //update stored high score
        if self.score > self.highScore {
            var highScoreDefault = NSUserDefaults.standardUserDefaults()
            highScoreDefault.setValue(self.score, forKey: "HighScore")
            self.highScore = self.score
        }

    }
    func didBeginContact(contact: SKPhysicsContact) {

        endGame()
    }
    
    func setupEverything(){
        self.view?.paused = true
        self.physicsWorld.gravity           = CGVectorMake( 0.0, -5.0 )
        self.physicsWorld.contactDelegate   = self

        setupIntroMusic()
        setupBackgroundMusic()
        setupHighScore()
        setupScoreLabel()
        setupHighScoreLabel()
        setupHero()
        setupEnemies()
    }
    var ntMusicPlayer:AVAudioPlayer!
    func setupIntroMusic() {
        var ntMusicUrl = NSBundle.mainBundle().URLForResource("intro", withExtension: "wav")
        ntMusicPlayer = AVAudioPlayer(contentsOfURL: ntMusicUrl, error: nil)
        ntMusicPlayer.volume = 0.25
        ntMusicPlayer.numberOfLoops = -1
        ntMusicPlayer.prepareToPlay()
        ntMusicPlayer.play()

    }
    var bgMusicPlayer:AVAudioPlayer!
    func setupBackgroundMusic(){
        var bgMusicURL = NSBundle.mainBundle().URLForResource("level", withExtension: "wav")
        bgMusicPlayer = AVAudioPlayer(contentsOfURL: bgMusicURL, error: nil)
        bgMusicPlayer.volume = 0.25
        bgMusicPlayer.numberOfLoops = -1
        bgMusicPlayer.prepareToPlay()
        //bgMusicPlayer.play()
    }
    func setupHighScore() {
        //saving high score
        var highScoreDefault = NSUserDefaults.standardUserDefaults()
        if highScoreDefault.valueForKey("HighScore") != nil {
            self.highScore = highScoreDefault.valueForKey("HighScore") as! Int
        } else {
            self.highScore = 0
        }
    }
    //create the score label
    func setupScoreLabel() {
        self.scoreLabel = SKLabelNode()
        self.scoreLabel.text         = "Current: " + String(self.score)
        self.scoreLabel.fontSize     = 20
        self.scoreLabel.fontColor    = UIColor.redColor()
        self.scoreLabel.fontName     = "Chalkduster"
        self.scoreLabel.position     = CGPointMake( CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + (CGRectGetMidY(self.frame) / 2) )
        self.addChild(self.scoreLabel)
    }
    //create the score label
    func setupHighScoreLabel() {
        self.highScoreLabel = SKLabelNode()
        self.highScoreLabel.text         = "High: " + String(self.highScore)
        self.highScoreLabel.fontSize     = 30
        self.highScoreLabel.fontColor    = UIColor.blackColor()
        self.highScoreLabel.zPosition    = -1
        self.highScoreLabel.fontName     = "Chalkduster"
        self.highScoreLabel.position     = CGPointMake( CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + (CGRectGetMidY(self.frame) / 1.5) )
        self.addChild(self.highScoreLabel)
    }
    //setup the "hero"
    func setupHero() {
        
        //hero sprite
        var heroTexture = SKTexture(imageNamed: "Hero")
        self.hero = SKSpriteNode(texture: heroTexture)
        self.hero.setScale(1)
        self.hero.position = CGPoint(x: self.frame.size.width * 0.40, y: self.frame.size.height * 0.4)
        
        //todo: add support for scaling... maybe?
        //polygon for physics body
        let offsetX = self.hero.frame.size.width * self.hero.anchorPoint.x
        let offsetY = self.hero.frame.size.height * self.hero.anchorPoint.y
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 8 - offsetX, 6 - offsetY);
        CGPathAddLineToPoint(path, nil, 31 - offsetX, 16 - offsetY);
        CGPathAddLineToPoint(path, nil, 44 - offsetX, 11 - offsetY);
        CGPathAddLineToPoint(path, nil, 57 - offsetX, 12 - offsetY);
        CGPathAddLineToPoint(path, nil, 75 - offsetX, 21 - offsetY);
        CGPathAddLineToPoint(path, nil, 83 - offsetX, 28 - offsetY);
        CGPathAddLineToPoint(path, nil, 85 - offsetX, 42 - offsetY);
        CGPathAddLineToPoint(path, nil, 78 - offsetX, 47 - offsetY);
        CGPathAddLineToPoint(path, nil, 78 - offsetX, 54 - offsetY);
        CGPathAddLineToPoint(path, nil, 68 - offsetX, 54 - offsetY);
        CGPathAddLineToPoint(path, nil, 64 - offsetX, 59 - offsetY);
        CGPathAddLineToPoint(path, nil, 66 - offsetX, 71 - offsetY);
        CGPathAddLineToPoint(path, nil, 61 - offsetX, 78 - offsetY);
        CGPathAddLineToPoint(path, nil, 52 - offsetX, 78 - offsetY);
        CGPathAddLineToPoint(path, nil, 43 - offsetX, 73 - offsetY);
        CGPathAddLineToPoint(path, nil, 37 - offsetX, 68 - offsetY);
        CGPathAddLineToPoint(path, nil, 27 - offsetX, 69 - offsetY);
        CGPathAddLineToPoint(path, nil, 25 - offsetX, 61 - offsetY);
        CGPathAddLineToPoint(path, nil, 26 - offsetX, 52 - offsetY);
        CGPathAddLineToPoint(path, nil, 26 - offsetX, 48 - offsetY);
        CGPathAddLineToPoint(path, nil, 22 - offsetX, 46 - offsetY);
        CGPathAddLineToPoint(path, nil, 23 - offsetX, 37 - offsetY);
        CGPathAddLineToPoint(path, nil, 17 - offsetX, 28 - offsetY);
        CGPathAddLineToPoint(path, nil, 4 - offsetX, 17 - offsetY);
        CGPathCloseSubpath(path)
        
        self.hero.physicsBody = SKPhysicsBody(polygonFromPath: path)//circleOfRadius: self.hero.size.height/2.5)
        self.hero.physicsBody!.dynamic = true
        self.hero.physicsBody?.categoryBitMask = PhysicsCategory.hero
        self.hero.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        
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
        flipActions.append(SKAction.runBlock({ self.hero.physicsBody!.applyImpulse(self.jumpVector) }));
        flipActions.append(flipAnimation);
        self.heroFlip = SKAction.group(flipActions);
        
        //hero death
        let deathSoundURL = NSBundle.mainBundle().URLForResource("snip", withExtension: "wav")
        self.heroDeathSound = AVAudioPlayer(contentsOfURL: deathSoundURL, error: nil)
        heroDeathSound.prepareToPlay()
    }
    
    //todo: add more knife sprites
    func setupEnemies() {
        
        //create pipes
        let halfFlip:CGFloat = 3.14159265
        let knifeTexture = SKTexture(imageNamed: "Knife")
        
        //movement of pipes
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * knifeTexture.size().width) * 1.25
        let moveKnives = SKAction.moveByX(-distanceToMove, y: 0.0, duration: NSTimeInterval(0.005 * distanceToMove))
        let removeKnives = SKAction.removeFromParent()
        let knivesMoveAndRemove = SKAction.sequence([moveKnives,removeKnives])
        
        //spawn pipes
        let spawn = SKAction.runBlock({
            
            let gap = Int.random(160...300)
            
            let pair = SKNodePair()
            pair.position = CGPointMake(self.frame.size.width + knifeTexture.size().width * 2,0)
            pair.zPosition = -10
            
            let height = Int(self.frame.size.height/4)
            let min = -height
            let max = Int(Double(height) * 1.5)
            let y = Int.random(min...max)
            
            let topKnife = SKSpriteNode(texture: knifeTexture)
            topKnife.setScale(0.75)
            let offsetX = topKnife.frame.size.width * topKnife.anchorPoint.x
            let offsetY = topKnife.frame.size.height * topKnife.anchorPoint.y
            let path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, 75 - offsetX, 600 - offsetY); //top right corner
            CGPathAddLineToPoint(path, nil, 65 - offsetX, 10 - offsetY); //move to bottom right corner
            CGPathAddLineToPoint(path, nil, 45 - offsetX, 30 - offsetY); //mvoe to point of knife
            CGPathAddLineToPoint(path, nil, 25 - offsetX, 75 - offsetY); //down the blade
            CGPathAddLineToPoint(path, nil, 20 - offsetX, 150 - offsetY); //down the blade
            CGPathAddLineToPoint(path, nil, 15 - offsetX, 300 - offsetY); //down the blade
            CGPathAddLineToPoint(path, nil, 5 - offsetX, 400 - offsetY);//down the blade
            CGPathAddLineToPoint(path, nil, 35 - offsetX, 600 - offsetY); //back to bottom
            CGPathCloseSubpath(path)
            topKnife.physicsBody = SKPhysicsBody(polygonFromPath: path)//rectangleOfSize: pipeDown.size)
            topKnife.physicsBody?.dynamic = false
            topKnife.physicsBody?.categoryBitMask = PhysicsCategory.enemy
            topKnife.physicsBody?.contactTestBitMask = PhysicsCategory.hero
            let bottomKnife = topKnife.copy() as! SKSpriteNode

            topKnife.position = CGPointMake(0.0, CGFloat(y) + topKnife.size.height + CGFloat(gap))
            bottomKnife.position = CGPointMake(0.0, CGFloat(y))
            bottomKnife.yScale = bottomKnife.yScale * -1 //mirror image
            
            pair.addChild(topKnife)
            pair.addChild(bottomKnife)
            pair.runAction(knivesMoveAndRemove)
            self.addChild(pair)
        })
        let delay = SKAction.waitForDuration(NSTimeInterval(3.0))
        let spawnThenDelay = SKAction.sequence([spawn,delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
    }
}

extension Int
{
    static func random(range: Range<Int> ) -> Int
    {
        var offset = 0
        
        if range.startIndex < 0   // allow negative ranges
        {
            offset = abs(range.startIndex)
        }
        
        let mini = UInt32(range.startIndex + offset)
        let maxi = UInt32(range.endIndex   + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}
