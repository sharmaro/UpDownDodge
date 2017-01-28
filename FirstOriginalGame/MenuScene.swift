//
//  MainMenu.swift
//  FirstOriginalGame
//
//  Created by Rohan Sharma on 8/19/16.
//  Copyright © 2016 Opel. All rights reserved.
//

import SpriteKit
import AVFoundation
import GameKit

class MenuScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate{
    var widthOfFrame:CGFloat!
    var heightOfFrame:CGFloat!
    
    // Array of textures
    static let menuSceneTextures = [SKTexture(imageNamed: "player"), SKTexture(imageNamed: "playButton"), SKTexture(imageNamed: "musicToggleButton"),
                                    SKTexture(imageNamed: "soundToggleButtonOn"), SKTexture(imageNamed: "soundToggleButtonOff"), SKTexture(imageNamed: "cityGround"),
                                    SKTexture(imageNamed: "cloudBackground"), SKTexture(imageNamed: "leaderBoardButton"), SKTexture(imageNamed: "likeButton")]
    
    let animatedPlayerTexture = SKTexture(imageNamed: "player")
    
    var animatedPlayerLeft:SKSpriteNode!
    var animatedPlayerRight:SKSpriteNode!
    var animatedPlayerUp:SKSpriteNode!
    var animatedPlayerCenter:SKSpriteNode!
    var animatedPlayerCenter2:SKSpriteNode!
    var heightOfPlayer:CGFloat!
    
    // Play button
    var playButton:SKSpriteNode!
    let playButtonTexture = SKTexture(imageNamed: "playButton")
    
    // Music toggle button
    var musicToggleButton:SKSpriteNode!
    let musicToggleButtonTexture = SKTexture(imageNamed: "musicToggleButton")
    static var musicOn = Bool()
    
    // Sound toggle button
    var soundToggleButton:SKSpriteNode!
    let soundToggleButtonOn = SKTexture(imageNamed: "soundToggleButtonOn")
    let soundToggleButtonOff = SKTexture(imageNamed: "soundToggleButtonOff")
    static var soundOn = Bool()
    
    // Like app in app store button
    var likeButton:SKSpriteNode!
    let likeButtonTexture = SKTexture(imageNamed: "likeButton")
    
    // Leaderboard button
    var leaderBoardButton:SKSpriteNode!
    let leaderBoardButtonTexture = SKTexture(imageNamed: "leaderBoardButton")
    
    let rotateButton = SKAction.rotate(byAngle: CGFloat(M_2_PI), duration: 0.35)
    
    var distancePlayerMovesUpDown:CGFloat!
    var moveUpAction:SKAction!
    var moveDownAction:SKAction!
    var moveUpAndDownActionSequence:SKAction!
    
    var distancePlayerMovesLeftRight:CGFloat!
    var moveLeftAction:SKAction!
    var moveRightAction:SKAction!
    var moveLeftRightActionSequence:SKAction!
    
    // Helps move the title up and down
    var titleMotion:SKNode!
    
    // Name of game
    var nameLabelNodeUP:SKLabelNode!
    var nameLabelNodeDOWN:SKLabelNode!
    
    // Background music
    static var backgroundMusicPlayer = AVAudioPlayer()
    let playButtonTapSound = SKAction.playSoundFileNamed("buttonTapSound.m4a", waitForCompletion: true)
    
    // Colors
    let ballRed:SKColor = SKColor(red:0.84, green:0.18, blue:0.11, alpha:1)
    let ballCyan:SKColor = SKColor(red:0.04, green:0.85, blue:0.95, alpha:1)
    let ballMagenta:SKColor = SKColor(red:0.67, green:0.04, blue:0.41, alpha:1)
    let ballOrange:SKColor = SKColor(red: 1, green: 0.4784, blue: 0.3529, alpha: 1)
    let ballGray:SKColor = SKColor(red: 0.4824, green: 0.5529, blue: 0.5569, alpha: 1)
    let ballGreen:SKColor = SKColor(red: 0.5569, green: 0.8627, blue: 0.6157, alpha: 1)
    
    let textDark:SKColor = SKColor(red: 1, green: 0.3412, blue: 0.1333, alpha: 1)
    let textLight:SKColor = SKColor(red: 1, green: 0.5412, blue: 0.3961, alpha: 1)
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.black
        
        widthOfFrame = self.frame.size.width
        heightOfFrame = self.frame.size.height
        
        
        // Moving vertically up and down
        
        // Bottom left of screen
        animatedPlayerLeft = SKSpriteNode(texture: animatedPlayerTexture)
        animatedPlayerLeft.setScale(0.7)
        heightOfPlayer = animatedPlayerLeft.size.height
        animatedPlayerLeft.position = CGPoint(x: heightOfPlayer / 2 + 7, y: heightOfPlayer / 2)
        animatedPlayerLeft.color = ballRed
        animatedPlayerLeft.colorBlendFactor = 1
        
        // Top right of screen
        animatedPlayerRight = SKSpriteNode(texture: animatedPlayerTexture)
        animatedPlayerRight.setScale(0.7)
        animatedPlayerRight.position = CGPoint(x: widthOfFrame - (heightOfPlayer / 2), y: heightOfFrame - (heightOfPlayer / 2))
        animatedPlayerRight.color = ballMagenta
        animatedPlayerRight.colorBlendFactor = 1
        
        // Moving horizontally left and right
        
        // Top left of screen
        animatedPlayerUp = SKSpriteNode(texture: animatedPlayerTexture)
        animatedPlayerUp.setScale(0.7)
        animatedPlayerUp.position = CGPoint(x: heightOfPlayer / 2 + 7, y: heightOfFrame - (heightOfPlayer / 2))
        animatedPlayerUp.color = ballGray
        animatedPlayerUp.colorBlendFactor = 1
        
        // Moving in a cirlcle at center of screen
        animatedPlayerCenter = SKSpriteNode(texture: animatedPlayerTexture)
        animatedPlayerCenter.position = CGPoint(x: widthOfFrame / 2, y: heightOfFrame * 0.45)
        animatedPlayerCenter.setScale(0.7)
        animatedPlayerCenter.color = ballOrange
        animatedPlayerCenter.colorBlendFactor = 1
        animatedPlayerCenter.zPosition = 10
        
        animatedPlayerCenter2 = SKSpriteNode(texture: animatedPlayerTexture)
        animatedPlayerCenter2.position = CGPoint(x: widthOfFrame / 2, y: heightOfFrame * 0.45)
        animatedPlayerCenter2.setScale(0.70)
        animatedPlayerCenter2.color = ballGreen
        animatedPlayerCenter2.colorBlendFactor = 1
        animatedPlayerCenter2.zPosition = 10
        
        // Node to hold title and play button
        titleMotion = SKNode()
        self.addChild(titleMotion)
        
        // Name of game
        nameLabelNodeUP = SKLabelNode(fontNamed:"AvenirNextCondensed-DemiBold")
        nameLabelNodeUP.fontSize += 270
        nameLabelNodeUP.position = CGPoint(x: widthOfFrame / 2, y: heightOfFrame * 0.8)
        nameLabelNodeUP.text = "UP"
        nameLabelNodeUP.fontColor = UIColor.white
        nameLabelNodeUP.zPosition = 100
        
        nameLabelNodeDOWN = SKLabelNode(fontNamed:"AvenirNextCondensed-DemiBold")
        nameLabelNodeDOWN.fontSize += 270
        nameLabelNodeDOWN.position = CGPoint(x: widthOfFrame / 2, y: nameLabelNodeUP.position.y - 270)
        nameLabelNodeDOWN.text = "DOWN"
        nameLabelNodeDOWN.fontColor = UIColor.white
        nameLabelNodeDOWN.zPosition = 100
        
        let distanceToMoveTitle = heightOfFrame - nameLabelNodeUP.position.y - nameLabelNodeUP.fontSize
        let moveUpTitle = SKAction.moveTo(y: distanceToMoveTitle, duration: 1.2)
        let moveDownTitle = SKAction.moveTo(y: -distanceToMoveTitle, duration: 1.2)
        let moveTitleSequence = SKAction.sequence([moveUpTitle, moveDownTitle])
        
        // Buttons
        
        // Play button
        playButton = SKSpriteNode(texture: playButtonTexture)
        playButton.size.width = 500
        playButton.size.height = 500
        playButton.position = CGPoint(x: widthOfFrame / 2, y: heightOfFrame * 0.45)
        
        // Music Toggle Button
        musicToggleButton = SKSpriteNode(texture: musicToggleButtonTexture)
        musicToggleButton.position = CGPoint(x: widthOfFrame * 0.13, y: heightOfFrame * 0.15)
        musicToggleButton.size.width = 250
        musicToggleButton.size.height = 250
        
        // Sound Toggle button
        soundToggleButton = SKSpriteNode(texture: soundToggleButtonOn)
        soundToggleButton.position = CGPoint(x: widthOfFrame * 0.88, y: heightOfFrame * 0.15)
        soundToggleButton.size.width = 250
        soundToggleButton.size.height = 250
        
        // Leader board button
        leaderBoardButton = SKSpriteNode(texture: leaderBoardButtonTexture)
        leaderBoardButton.position = CGPoint(x: widthOfFrame * 0.38, y: heightOfFrame * 0.15)
        leaderBoardButton.size.width = 250
        leaderBoardButton.size.height = 250
        leaderBoardButton.run(SKAction.repeatForever(rotateButton.reversed()))
        
        // Like button
        likeButton = SKSpriteNode(texture: likeButtonTexture)
        likeButton.position = CGPoint(x: widthOfFrame * 0.63, y: heightOfFrame * 0.15)
        likeButton.size.width = 250
        likeButton.size.height = 250
        likeButton.run(SKAction.repeatForever(rotateButton))
        
        // Setting up actions for players moving up and down
        distancePlayerMovesUpDown = CGFloat(heightOfFrame - heightOfPlayer)
        moveUpAction = SKAction.moveBy(x: 0, y: distancePlayerMovesUpDown, duration: 3)
        moveDownAction = SKAction.moveBy(x: 0, y: -distancePlayerMovesUpDown, duration: 3)
        
        // Setting up actions for players moving left and right
        distancePlayerMovesLeftRight = widthOfFrame - heightOfPlayer
        moveLeftAction = SKAction.moveBy(x: -distancePlayerMovesLeftRight, y: 0, duration: 3)
        moveRightAction = SKAction.moveBy(x: distancePlayerMovesLeftRight, y: 0, duration: 3)
        
        addActionPlayerLeft(animatedPlayerLeft)
        addActionPlayerRight(animatedPlayerRight)
        addActionPlayerUp(animatedPlayerUp)
        // Passing in player and circle diameter
        addActionPlayerCircularMotion(animatedPlayerCenter, circleDiameter: playButton.size.width - 28, cw: true)
        addActionPlayerCircularMotion(animatedPlayerCenter2, circleDiameter: playButton.size.width - 28, cw: false)
        
        self.addChild(animatedPlayerLeft)
        self.addChild(animatedPlayerRight)
        self.addChild(animatedPlayerUp)
        self.addChild(animatedPlayerCenter)
        self.addChild(animatedPlayerCenter2)
        
        self.addChild(musicToggleButton)
        self.addChild(soundToggleButton)
        self.addChild(playButton)
        self.addChild(leaderBoardButton)
        self.addChild(likeButton)
        
        titleMotion.addChild(nameLabelNodeUP)
        titleMotion.addChild(nameLabelNodeDOWN)
        titleMotion.run(SKAction.repeatForever(moveTitleSequence))
        
        // Changing alphas of toggle buttons once player crashes and comes back to
        // main menu
        // If they left the sound toggle button off then the alpha should remain the same once
        // they crash and come back to the main menu
        // Same for the music toggle button
        changeAlphasOfToggleButtons()        
    }
    
    func addActionPlayerLeft(_ player: SKSpriteNode){
        moveUpAndDownActionSequence = SKAction.sequence([moveUpAction, moveDownAction])
        player.run(SKAction.repeatForever(moveUpAndDownActionSequence))
    }
    
    func addActionPlayerRight(_ player: SKSpriteNode){
        moveUpAndDownActionSequence = SKAction.sequence([moveDownAction, moveUpAction])
        player.run(SKAction.repeatForever(moveUpAndDownActionSequence))
    }
    
    func addActionPlayerUp(_ player: SKSpriteNode){
        moveLeftRightActionSequence = SKAction.sequence([moveRightAction, moveLeftAction])
        player.run(SKAction.repeatForever(moveLeftRightActionSequence))
    }
    
    func addActionPlayerDown(_ player: SKSpriteNode){
        moveLeftRightActionSequence = SKAction.sequence([moveLeftAction, moveRightAction])
        player.run(SKAction.repeatForever(moveLeftRightActionSequence))
    }
    
    func addActionPlayerCircularMotion(_ player: SKSpriteNode, circleDiameter: CGFloat, cw: Bool){
        // Circle path's diameter
        let circleDiameter = CGFloat(circleDiameter)
        
        // Center of path based on sprite's initial position
        let pathCenterPoint = CGPoint(
            x: player.position.x - circleDiameter / 2,
            y: player.position.y - circleDiameter / 2
        )
        
        // Create path sprite will travel along
        let circlePath = CGPath(ellipseIn: CGRect(origin: pathCenterPoint, size: CGSize(width: circleDiameter, height: circleDiameter)), transform: nil)
        
        // Create a followPath action for sprite
        let followCirclePath = SKAction.follow(circlePath, asOffset: false, orientToPath: true, duration: 3)
        
        // Make sprite run this action forever
        if cw {
            player.run(SKAction.repeatForever(followCirclePath.reversed()))
        } else {
            player.run(SKAction.repeatForever(followCirclePath))
        }
    }
    
    static func setUpAudioPlayer() {
        let url = Bundle.main.url(forResource: "UpDown_BG_Music.m4a", withExtension: nil)
        guard let newURL = url else {
            return
        }
        do {
            MenuScene.backgroundMusicPlayer = try AVAudioPlayer(contentsOf: newURL)
            MenuScene.backgroundMusicPlayer.numberOfLoops = -1
            MenuScene.backgroundMusicPlayer.prepareToPlay()
            MenuScene.backgroundMusicPlayer.volume = 0.5
        } catch _ as NSError {
        }
        
    }
    
    static func playBackgroundMusic() {
        MenuScene.backgroundMusicPlayer.play()
    }
    
    func changeAlphasOfToggleButtons() {
        if MenuScene.musicOn {
            MenuScene.musicOn = true
            musicToggleButton.alpha = 1
        } else {
            MenuScene.musicOn = false
            musicToggleButton.alpha = 0.5
        }
        
        if MenuScene.soundOn {
            MenuScene.soundOn = true
            soundToggleButton.alpha = 1
        } else {
            MenuScene.soundOn = false
            soundToggleButton.alpha = 0.5
            soundToggleButton.texture = soundToggleButtonOff
        }
    }
    
    func startGameScene() {
        let sceneMoveFromMenuToGame:SKTransition = SKTransition.fade(withDuration: 0.7)
        let gameScene:SKScene = GameScene(size: self.size)
        self.view?.presentScene(gameScene, transition: sceneMoveFromMenuToGame)
    }
    
    //Shows leaderboard
    func showLeaderBoard() {
        let viewControllerVar = self.view?.window?.rootViewController
        let gKGCViewController = GKGameCenterViewController()
        
        gKGCViewController.gameCenterDelegate = self
        viewControllerVar?.present(gKGCViewController, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Looping through all touches in event
        for touch: AnyObject in touches {
            // Getting location of touch
            let location = touch.location(in: self)
            // Checking if touch is in the same location as the playButton
            if playButton.contains(location) {
                playButton.alpha = 0.5
            }
            
            // Changing alpha of music button on initial touch
            if musicToggleButton.contains(location){
                if MenuScene.musicOn {
                    musicToggleButton.alpha = 0.5
                } else {
                    musicToggleButton.alpha = 1
                }
            }
            
            // Changing alpha of sound button on initial touch
            if soundToggleButton.contains(location){
                if MenuScene.soundOn {
                    soundToggleButton.alpha = 0.5
                } else {
                    soundToggleButton.alpha = 1
                }
            }
            
            if leaderBoardButton.contains(location){
                leaderBoardButton.alpha = 0.5
            }
            
            if likeButton.contains(location){
                likeButton.alpha = 0.5
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Looping through all touches in event
        for touch: AnyObject in touches {
            // Getting location of touch
            let location = touch.location(in: self)
            // Checking if touch is in the same location as the playButton
            if playButton.contains(location) {
                playButton.alpha = 1
                
                if MenuScene.soundOn {
                    self.run(playButtonTapSound)
                }
                
                SKTexture.preload(GameScene.gameSceneTextures, withCompletionHandler: {self.startGameScene()})
            }
            
            // Turning music on or off
            if musicToggleButton.contains(location){
                if MenuScene.musicOn {
                    MenuScene.musicOn = false
                    musicToggleButton.alpha = 0.5
                    
                    if MenuScene.soundOn {
                        self.run(playButtonTapSound)
                    }
                    
                    if MenuScene.backgroundMusicPlayer.isPlaying {
                       MenuScene.backgroundMusicPlayer.pause()
                    }
                } else {
                    MenuScene.musicOn = true
                    musicToggleButton.alpha = 1
                    
                    if MenuScene.soundOn {
                        self.run(playButtonTapSound)
                    }
                    
                    if !(MenuScene.backgroundMusicPlayer.isPlaying) {
                        MenuScene.backgroundMusicPlayer.play()
                    }
                }
            }
            
            // Turning sound on or off
            if soundToggleButton.contains((location)){
                if MenuScene.soundOn {
                    MenuScene.soundOn = false
                    
                    self.run(playButtonTapSound)
                    
                    soundToggleButton.alpha = 0.5
                    soundToggleButton.texture = soundToggleButtonOff
                } else {
                    MenuScene.soundOn = true
                    soundToggleButton.alpha = 1
                    soundToggleButton.texture = soundToggleButtonOn
                }
            }
            
            if leaderBoardButton.contains(location){
                leaderBoardButton.alpha = 1
                
                if MenuScene.soundOn {
                    self.run(playButtonTapSound)
                }
                
                showLeaderBoard()
            }
            
            if likeButton.contains(location){
                likeButton.alpha = 1
                
                if MenuScene.soundOn {
                    self.run(playButtonTapSound)
                }
                
                UIApplication.shared.open(NSURL(string : "itms-apps://itunes.apple.com/app/id1156759952")! as URL)
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
            if !(playButton.contains(location)) {
                playButton.alpha = 1
            }
            
            if !(musicToggleButton.contains(location)) {
                if MenuScene.musicOn {
                    musicToggleButton.alpha = 1
                } else {
                    musicToggleButton.alpha = 0.5
                }
            
            }
            
            if !(soundToggleButton.contains(location)){
                if MenuScene.soundOn {
                    soundToggleButton.alpha = 1
                } else {
                    soundToggleButton.alpha = 0.5
                }
            }
            
            if !(leaderBoardButton.contains(location)){
                leaderBoardButton.alpha = 1
            }
            
            if !(likeButton.contains(location)){
                likeButton.alpha = 1
            }
        }
    }
}
