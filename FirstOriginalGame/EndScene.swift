//
//  EndScene.swift
//  FirstOriginalGame
//
//  Created by Rohan Sharma on 8/28/16.
//  Copyright © 2016 Opel. All rights reserved.
//

import SpriteKit

class EndScene: SKScene, SKPhysicsContactDelegate{
    static let endSceneTextures = [SKTexture(imageNamed: "retryButton"), SKTexture(imageNamed: "homeButton"), SKTexture(imageNamed: "shareButton"), SKTexture(imageNamed: "strips")]
    
    var retryButton:SKSpriteNode!
    let retryButtonTexture = SKTexture(imageNamed: "retryButton")
    let rotateRetryButton = SKAction.rotate(byAngle: CGFloat(M_2_PI), duration: 0.5)
    
    var homeButton:SKSpriteNode!
    let homeButtonTexture = SKTexture(imageNamed: "homeButton")
    
    var shareButton:SKSpriteNode!
    let shareButtonTexture = SKTexture(imageNamed: "shareButton")
    let rotateShareButton = SKAction.rotate(byAngle: CGFloat(M_2_PI), duration: 0.35)
    
    var heightOfFrame:CGFloat!
    var widthOfFrame:CGFloat!
    
    // Name of game
    var nameLabelNodeUP:SKLabelNode!
    var nameLabelNodeDOWN:SKLabelNode!
    
    // Score
    var scoreNumberNode:SKLabelNode! // Score (number)
    var scoreLabelNode:SKLabelNode! // Score (title)
    var scoreStrip:SKSpriteNode! // Score (title) background
    let scoreStripTexture = SKTexture(imageNamed: "strips") // Texture for both score strips
    
    // Best Score
    var bestScoreNumberNode:SKLabelNode! // Best Score (number)
    var bestScoreLabelNode:SKLabelNode! // Best Score (title)
    var bestScoreStrip:SKSpriteNode! // Best Score (title) background
    // High score that doesn't change on app close
    static var highScore = 0
    var highScoreDefault:UserDefaults!
    
    // Button tap sound
    let playButtonTapSound = SKAction.playSoundFileNamed("buttonTapSound.m4a", waitForCompletion: true)
    
    // Colors
    let stripGray:SKColor = SKColor(red: 0.4824, green: 0.5529, blue: 0.5569, alpha: 1)
    let stripGold:SKColor = SKColor(red: 0.8784, green: 0.6275, blue: 0.1451, alpha: 1)

    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.black
        
        heightOfFrame = self.frame.size.height
        widthOfFrame = self.frame.size.width
        
        // Buttons
        
        // Retry button
        retryButton = SKSpriteNode(texture: retryButtonTexture)
        retryButton.size.width = 370
        retryButton.size.height = 370
        retryButton.position = CGPoint(x: widthOfFrame * 0.5, y: heightOfFrame * 0.25)
        retryButton.run(SKAction.repeatForever(rotateRetryButton.reversed()))
        retryButton.run(SKAction.repeatForever(SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.65), SKAction.scale(to: 1, duration: 0.65)])))
        
        // Home button
        homeButton = SKSpriteNode(texture: homeButtonTexture)
        homeButton.size.width = 230
        homeButton.size.height = 230
        homeButton.position = CGPoint(x: homeButton.size.width / 2 + 20, y: heightOfFrame - (homeButton.size.height / 2) - 20)
        
        // Share button
        shareButton = SKSpriteNode(texture: shareButtonTexture)
        shareButton.size.width = 230
        shareButton.size.height = 230
        shareButton.position = CGPoint(x: widthOfFrame - (shareButton.size.width / 2) - 20, y: heightOfFrame - (shareButton.size.height / 2) - 20)
        shareButton.run(SKAction.repeatForever(rotateShareButton))
        
        // Name of game
        
        nameLabelNodeUP = SKLabelNode(fontNamed:"AvenirNextCondensed-DemiBold")
        nameLabelNodeUP.fontSize += 180
        nameLabelNodeUP.position = CGPoint(x: widthOfFrame / 2, y: heightOfFrame - (nameLabelNodeUP.fontSize / 1.33))
        nameLabelNodeUP.text = "UP"
        nameLabelNodeUP.fontColor = UIColor.white
        nameLabelNodeUP.zPosition = 100
        
        nameLabelNodeDOWN = SKLabelNode(fontNamed:"AvenirNextCondensed-DemiBold")
        nameLabelNodeDOWN.fontSize += 180
        nameLabelNodeDOWN.position = CGPoint(x: widthOfFrame / 2, y: nameLabelNodeUP.position.y - nameLabelNodeUP.fontSize)
        nameLabelNodeDOWN.text = "DOWN"
        nameLabelNodeDOWN.fontColor = UIColor.white
        nameLabelNodeDOWN.zPosition = 100
        
        // Score
        
        scoreNumberNode = SKLabelNode(fontNamed:"DamascusLight")
        scoreNumberNode.fontSize += 150
        scoreNumberNode.position = CGPoint(x: widthOfFrame * 0.5, y: heightOfFrame * 0.62)
        scoreNumberNode.zPosition = 100
        scoreNumberNode.text = String(GameScene.score)
        
        scoreLabelNode = SKLabelNode(fontNamed:"Copperplate")
        scoreLabelNode.fontSize += 90
        scoreLabelNode.position = CGPoint(x: widthOfFrame * 0.5, y: heightOfFrame * 0.72)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = String("SCORE")
        
        scoreStrip = SKSpriteNode(texture: scoreStripTexture)
        scoreStrip.size.width = widthOfFrame * 1.5
        scoreStrip.size.height = 100
        scoreStrip.position = CGPoint(x: widthOfFrame * 0.5, y: heightOfFrame * 0.72 + 36)
        scoreStrip.color = stripGray
        scoreStrip.colorBlendFactor = 1
        
        // Best Score
        
        // NSUserDefaults stuff
        highScoreDefault = UserDefaults.standard
        if highScoreDefault.value(forKey: "highScore") != nil {
            // Keeping the high score after game ended
            EndScene.highScore = highScoreDefault.value(forKey: "highScore") as! NSInteger
        }
        
        // Updating the high score
        if GameScene.score > EndScene.highScore {
            EndScene.highScore = GameScene.score
            GameViewController.saveHighscore(EndScene.highScore)
        }
        
        // Changing the high score and synchronizing so high score is not forgotten
        highScoreDefault.setValue(EndScene.highScore, forKey: "highScore")
        highScoreDefault.synchronize()
        
        bestScoreNumberNode = SKLabelNode(fontNamed: "DamascusLight")
        bestScoreNumberNode.fontSize += 150
        bestScoreNumberNode.position = CGPoint(x: widthOfFrame * 0.5, y: heightOfFrame * 0.44)
        bestScoreNumberNode.zPosition = 100
        bestScoreNumberNode.text = String(EndScene.highScore)
        
        bestScoreLabelNode = SKLabelNode(fontNamed: "Copperplate")
        bestScoreLabelNode.fontSize += 90
        bestScoreLabelNode.position = CGPoint(x: widthOfFrame * 0.5, y: heightOfFrame * 0.54)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.text = String("BEST SCORE")
        
        bestScoreStrip = SKSpriteNode(texture: scoreStripTexture)
        bestScoreStrip.size.width = widthOfFrame * 1.5
        bestScoreStrip.size.height = 100
        bestScoreStrip.position = CGPoint(x: widthOfFrame * 0.5, y: heightOfFrame * 0.54 + 36)
        bestScoreStrip.color = stripGold
        bestScoreStrip.colorBlendFactor = 1
        
        // Adding all children nodes
        self.addChild(retryButton)
        self.addChild(homeButton)
        self.addChild(shareButton)
        
        self.addChild(nameLabelNodeUP)
        self.addChild(nameLabelNodeDOWN)
        
        self.addChild(scoreNumberNode)
        self.addChild(scoreLabelNode)
        self.addChild(scoreStrip)
        
        self.addChild(bestScoreNumberNode)
        self.addChild(bestScoreLabelNode)
        self.addChild(bestScoreStrip)        
    }

    func startMenuScene() {
        let sceneMoveFromEndToMenu:SKTransition = SKTransition.fade(withDuration: 1)
        let menuScene:SKScene = MenuScene(size: self.size)
        self.view?.presentScene(menuScene, transition: sceneMoveFromEndToMenu)
    }
    
    func startGameScene() {
        let sceneMoveFromEndToGame:SKTransition = SKTransition.fade(withDuration: 0.7)
        let gameScene:SKScene = GameScene(size: self.size)
        self.view?.presentScene(gameScene, transition: sceneMoveFromEndToGame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Looping through all touches in event
        for touch: AnyObject in touches {
            // Getting location of touch
            let location = touch.location(in: self)
            // Checking if touch is in the same location as the playButton
            if retryButton.contains(location) {
                retryButton.alpha = 0.5
            }
            
            if homeButton.contains(location) {
                homeButton.alpha = 0.5
            }
            
            if shareButton.contains(location){
                shareButton.alpha = 0.5
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Looping through all touches in event
        for touch: AnyObject in touches {
            // Getting location of touch
            let location = touch.location(in: self)
            // Checking if touch is in the same location as the playButton
            if retryButton.contains(location) {
                retryButton.alpha = 1
                
                if MenuScene.soundOn {
                    self.run(playButtonTapSound)
                }
                startGameScene()
            }
            
            if homeButton.contains(location) {
                homeButton.alpha = 1
                
                if MenuScene.soundOn {
                    self.run(playButtonTapSound)
                }
                
                startMenuScene()
            }
            
            if shareButton.contains(location) {
                shareButton.alpha = 1
                
                if MenuScene.soundOn {
                    self.run(playButtonTapSound)
                }
                
                // ALLOW THEM TO SHARE SCORE TO DIFFERENT SOCIAL MEDIA OUTLETS
                let textToShare = "Try beating my highscore of \(EndScene.highScore) on #UpDownDodge!"

                let objectsToShare = [textToShare]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
                activityVC.popoverPresentationController?.sourceView = self.view
                
                let currentViewController:UIViewController = UIApplication.shared.keyWindow!.rootViewController!
                currentViewController.present(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Looping through all touches in event
        for touch: AnyObject in touches {
            // Getting location of touch
            let location = touch.location(in: self)
            // Checking if touch is not in the same location as the playButton
            // Meaning the touch was taken off of the button
            if !(retryButton.contains(location)) {
                retryButton.alpha = 1
            }
            
            if !(homeButton.contains(location)) {
                homeButton.alpha = 1
            }
            
            if !(shareButton.contains(location)) {
                shareButton.alpha = 1
            }
        }
    }
}
