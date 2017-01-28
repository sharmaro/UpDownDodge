//
//  GameScene.swift
//  FirstOriginalGame
//
//  Created by Rohan Sharma on 7/28/16.
//  Copyright (c) 2016 Opel. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    // Height and width of frame for easy access
    var heightOfFrame = CGFloat()
    var widthOfFrame = CGFloat()
    
    // Array of textures
    static let gameSceneTextures = [SKTexture(imageNamed: "player"), SKTexture(imageNamed: "laserTopWhite"), SKTexture(imageNamed: "laserBottom"), SKTexture(imageNamed: "laser"),
                             SKTexture(imageNamed: "cityBackground"), SKTexture(imageNamed: "cityGround"), SKTexture(imageNamed: "cloudBackground")]
    
    // Player node
    var player:SKSpriteNode! // Exclamation point means that player will be defined later in the code
    let playerTexture = SKTexture(imageNamed: "player")
    
    // Laser texture, laser-top texture and laser-bottom texture
    let laserTopTexture = SKTexture(imageNamed: "laserTopWhite")
    let laserBottomTexture = SKTexture(imageNamed: "laserBottom")
    let laserTexture = SKTexture(imageNamed: "laser")
    
    // Mechanism that holds top/bottom laser mechanisms
    var laserMech:SKNode!
    
    // Moving lasers and laser mechanisms across screen
    var moveLasersAndRemove:SKAction!
    var laserPairTop:SKNode!
    var laserPairDown:SKNode!
    var moving:SKNode!
    
    // Moving player up and down forever
    var moveUpPlayer:SKAction!
    var moveDownPlayer:SKAction!
    
    // Oscillating large lasers once score is 15 or higher
    var oscillateLaserUp:SKAction!
    var oscillateLaserDown:SKAction!
    var oscillateLaserSequence:SKAction!
    
    // Moving small lasers across screen once score is 30 or higher
    var distanceLaserMovesAcrossScreen = CGFloat()
    var moveDownLaserAcrossScreen:SKAction!
    var moveUpLaserAcrossScreen:SKAction!
    var moveLaserAcrossScreenSequence:SKAction!
    
    // Backgrounds moving
    var cityBackground1:SKSpriteNode!
    var cityBackground2:SKSpriteNode!
    
    var cloudBackground1:SKSpriteNode!
    var cloudBackground2:SKSpriteNode!
    
    var groundBackground1:SKSpriteNode!
    var groundBackground2:SKSpriteNode!
    
    // Top and bottom walls/lasers with their textures
    var topWall:SKSpriteNode!
    var bottomWall:SKSpriteNode!
    let wallTexture = SKTexture(imageNamed: "laser")
    
    // Background textures
    let cityBackgroundTexture = SKTexture(imageNamed: "cityBackground")
    let groundBackgroundTexture = SKTexture(imageNamed: "cityGround")
    let cloudBackgroundTexture = SKTexture(imageNamed: "cloudBackground")
    
    // Checking
    var topLaserCheck = Bool()
    var isGoingUp = Bool()
    
    // Scoring
    var scoreNode:SKSpriteNode!
    var scoreLabelNode:SKLabelNode!
    static var score = NSInteger()
    
    // Sounds
    let playTapSound = SKAction.playSoundFileNamed("tapSound.m4a", waitForCompletion: true)
    let playCrashSound = SKAction.playSoundFileNamed("crashSound.m4a", waitForCompletion: true)
    let scoreSound = SKAction.playSoundFileNamed("scoreSound.m4a", waitForCompletion: true)
    
    // Colors of lasers and player
    let red:SKColor = SKColor(red:0.91, green:0.22, blue:0.22, alpha: 1)
    
    // Background colors
    let blueBg:SKColor = SKColor(red:0.36, green:0.52, blue:0.79, alpha: 1)
    
    let ballColor:SKColor = SKColor(red: 0.9882, green: 0.4275, blue: 0, alpha: 1)
    
    // Physics bitmasking
    let playerCategory: UInt32 = 1 << 0 // 1
    let worldCategory: UInt32 = 1 << 1 // 2
    let laserCategory: UInt32 = 1 << 2 // 4
    let scoreCategory: UInt32 = 1 << 3 // 8
    
    override func didMove(to view: SKView) {
        // Randomly spawning the first laser pair from top or bottom
        let upOrDown = Int(arc4random_uniform(2))
        
        if upOrDown == 0{
            topLaserCheck = true
        } else {
            topLaserCheck = false
        }
        
        // setup physics
        self.physicsWorld.contactDelegate = self
        
        heightOfFrame = CGFloat(self.frame.size.height)
        widthOfFrame = CGFloat(self.frame.size.width)
        
        // Background color of screen
        self.backgroundColor = blueBg
        
        // Node that holds all moving nodes
        moving = SKNode()
        self.addChild(moving)
        laserMech = SKNode()
        moving.addChild(laserMech)
        
        // Initializing the ceiling and floor
        topWall = SKSpriteNode(texture: wallTexture)
        bottomWall = SKSpriteNode(texture: wallTexture)
        
        // Initializing ceiling and floor
        initWalls(topWall)
        initWalls(bottomWall)
        
        // Positioning the walls so that it is right off the screen on the top and bottom
        topWall.position = CGPoint(x: widthOfFrame / 2, y: heightOfFrame + topWall.size.height / 2)
        bottomWall.position = CGPoint(x: widthOfFrame / 2, y: -(bottomWall.size.height / 2) + 50)
        
        self.addChild(topWall)
        self.addChild(bottomWall)
        
        // Setting up city background
        setUpCityBackground()
        
        // Setting up cloud background
        setUpCloudBackground()
        
        // Setting up ground background
        setUpGroundBackground()
        
        // Laser textures
        laserTopTexture.filteringMode = .nearest
        laserBottomTexture.filteringMode = .nearest
        laserTexture.filteringMode = .nearest
        
        // create the laser movement actions
        let distanceToMove = CGFloat(widthOfFrame + laserTopTexture.size().width)
        let moveLasers = SKAction.moveBy(x: -distanceToMove, y:0, duration:TimeInterval(widthOfFrame * 0.0039)) // Time (in seconds) for each object to reach left side of screen
        let removeLasers = SKAction.removeFromParent()
        moveLasersAndRemove = SKAction.sequence([moveLasers, removeLasers])
        
        // spawn the lasers
        let spawn = SKAction.run({() in self.spawnLasers()})
        let delay = SKAction.wait(forDuration: TimeInterval(2.2)) // Time (in seconds) for laser to wait before next one spawns
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
        self.run(spawnThenDelayForever)
        
        // Setting up player
        playerTexture.filteringMode = .nearest
        
        // Player moving up actions
        let distancePlayerMoves = CGFloat(5000.0)
        let speedPlayerMoves = CGFloat(1250.0)
        let durationPlayerTakes = CGFloat(distancePlayerMoves / speedPlayerMoves)
        isGoingUp = true
        moveUpPlayer = SKAction.moveBy(x: 0, y: distancePlayerMoves, duration: TimeInterval(durationPlayerTakes))
        moveDownPlayer = SKAction.moveBy(x: 0, y: -distancePlayerMoves, duration: TimeInterval(durationPlayerTakes))
        
        // Laser oscillating slightly after score >= 15 (Level 2)
        let distanceLaserMoves = CGFloat(arc4random_uniform(51) + 100)
        oscillateLaserUp = SKAction.moveBy(x: 0, y: distanceLaserMoves, duration: 1.5)
        oscillateLaserDown = SKAction.moveBy(x: 0, y: -distanceLaserMoves, duration: 1.5)
        oscillateLaserSequence = SKAction.sequence([oscillateLaserUp, oscillateLaserDown])
        
        // Laser moving across screen after score >= 30 (Level 3)
        distanceLaserMovesAcrossScreen = CGFloat(heightOfFrame)
        moveUpLaserAcrossScreen = SKAction.moveBy(x: 0, y: distanceLaserMovesAcrossScreen, duration: 1.4)
        moveDownLaserAcrossScreen = SKAction.moveBy(x: 0, y: -distanceLaserMovesAcrossScreen, duration: 1.4)
        
        // Player characteristics
        player = SKSpriteNode(texture: playerTexture)
        player.setScale(0.7)
        // 35% to the right and 50% to the top
        player.position = CGPoint(x: widthOfFrame * 0.35, y:heightOfFrame * 0.5)
        // Player moving up first
        player.run(moveUpPlayer)
        
        // Player physics
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.color = ballColor
        player.colorBlendFactor = 1
        
        // Category is what kind of physics body it is
        player.physicsBody?.categoryBitMask = playerCategory
        // Collision is what types of things code should be notified of when it collides
        player.physicsBody?.collisionBitMask = worldCategory | laserCategory
        // Contact is what types of sprites code should be notified of when it comes into contact
        player.physicsBody?.contactTestBitMask = worldCategory | laserCategory
        player.zPosition = 100
        self.addChild(player)
        
        // Initialize label and create a label which holds the score
        // Also intializng score node to hold both the lables
        scoreNode = SKSpriteNode()
        
        GameScene.score = 0
        scoreLabelNode = SKLabelNode(fontNamed:"DamascusLight")
        scoreLabelNode.fontSize += 95
        scoreLabelNode.position = CGPoint(x: widthOfFrame * 0.50, y: heightOfFrame * 0.78)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = String(GameScene.score)
        
        scoreNode.addChild(scoreLabelNode)
        self.addChild(scoreNode)
        
        let bottomCover = SKSpriteNode(texture: SKTexture(imageNamed: "laserBottom"))
        bottomCover.position = CGPoint(x: widthOfFrame / 2, y: 0)
        bottomCover.size.height = 100
        bottomCover.size.width = widthOfFrame
        bottomCover.color = .black
        bottomCover.colorBlendFactor = 1
        bottomCover.zPosition = 200
        self.addChild(bottomCover)        
    }
    
    // Creating top and bottom walls
    func initWalls(_ wall:SKSpriteNode){
        wall.setScale(2)
        wall.size.width = 5000
        wall.size.height = 1
        wall.color = UIColor.clear
        wall.colorBlendFactor = 1
        wall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.allowsRotation = false
        wall.physicsBody?.affectedByGravity = false
        wall.physicsBody?.usesPreciseCollisionDetection = true
    
        wall.physicsBody?.categoryBitMask = worldCategory
        wall.physicsBody?.contactTestBitMask = playerCategory
    }

    // Player moving up and down forever
    func movePlayerForever() {
        player.removeAllActions()
        
        if isGoingUp {
            player.run(moveDownPlayer)
            isGoingUp = false
        } else {
            player.run(moveUpPlayer)
            isGoingUp = true
        }
    }
    
    // Spawning and adding lasers to
    func spawnLasers() {
        // Creates top laser mech
        createTopLaserMechanism()
        // Creates bottom laser mech
        createBottomLaserMechanism()
        
        // Randomly spawning the first laser mechanism on the top or bottom
        // All other lasers will spawn in a pattern down/top
        if topLaserCheck && moving.speed > 0{
            laserMech.addChild(laserPairTop)
            topLaserCheck = false
        } else if moving.speed > 0 {
            laserMech.addChild(laserPairDown)
            topLaserCheck = true
        }
    }
    
    // Creating top laser mechanism
    func createTopLaserMechanism() {
        let heightOfLaserTop = CGFloat(2500)
        let widthOfLaser = CGFloat(50)
        // How much of the laser will be shown on screen
        var laserGap:CGFloat
        
        // Only allowing small lasers to spawn once score has reached 30
        if GameScene.score >= 30 {
            laserGap = CGFloat(arc4random_uniform(1051) + 500)
            // Only allowing oscillation for lasers between 1100 and 1550
        } else if GameScene.score > 5 && GameScene.score < 30{
            laserGap = CGFloat(arc4random_uniform(451) + 1100)
        } else {
            laserGap = CGFloat(arc4random_uniform(101) + 1000)
        }
        
        // Top laser mechanism
        laserPairTop = SKNode()
        laserPairTop.position = CGPoint(x: widthOfFrame + (laserTopTexture.size().width / 2), y: 0)
        laserPairTop.zPosition = -10
        
        // Top laser parts characteristics
        let laserTopHalfForTop = SKSpriteNode(texture: laserTopTexture)
        laserTopHalfForTop.setScale(1.3)
        laserTopHalfForTop.color = UIColor.black
        laserTopHalfForTop.colorBlendFactor = 1
        // Setting 6 pixels to right so it'll be in middle of laser
        laserTopHalfForTop.position = CGPoint(x: 6, y: heightOfFrame)
        laserPairTop.addChild(laserTopHalfForTop)
        
        let laserBottomHalfForTop = SKSpriteNode(texture: laserBottomTexture)
        laserBottomHalfForTop.setScale(5)
        laserBottomHalfForTop.position = CGPoint(x: 0, y: heightOfFrame - (laserTopHalfForTop.size.height / 2))
        laserBottomHalfForTop.zPosition = 1
        laserPairTop.addChild(laserBottomHalfForTop)
        
        // Actual laser on top
        let laserTop = SKSpriteNode(texture: laserTexture)
        laserTop.size.height = heightOfLaserTop
        laserTop.size.width = widthOfLaser
        laserTop.position = CGPoint(x: 0, y: heightOfFrame + (laserTop.size.height / 2) - laserGap)
        laserTop.zPosition = -1
        laserTop.color = red
        laserTop.colorBlendFactor = 1
        
        laserTop.physicsBody = SKPhysicsBody(rectangleOf: laserTop.size)
        laserTop.physicsBody?.isDynamic = false
        laserTop.physicsBody?.allowsRotation = false
        laserTop.physicsBody?.categoryBitMask = laserCategory
        laserTop.physicsBody?.contactTestBitMask = playerCategory
        
        // Oscillating lasers if gap is between [1100, 1400] once score has reached 15
        if laserGap >= 1100 && laserGap <= 1400 && GameScene.score >= 15{
            laserTop.run(SKAction.repeatForever(oscillateLaserSequence))
        }
        
        // Moving lasers across screen if gap is between [500, 850) once score has reached 30
        if laserGap >= 500 && laserGap < 1000 && GameScene.score >= 30{
            // Changing height of laser so it can move across screen
            laserTop.size.height = laserGap
            // Randomly deciding if laser spawns up or down
            let uOrD = arc4random_uniform(2)
            if uOrD == 0 {
                laserTop.position = CGPoint(x: 0, y: heightOfFrame)
                moveLaserAcrossScreenSequence = SKAction.sequence([moveDownLaserAcrossScreen, moveUpLaserAcrossScreen])
            } else {
                laserTop.position = CGPoint(x: 0, y: 0)
                moveLaserAcrossScreenSequence = SKAction.sequence([moveUpLaserAcrossScreen, moveDownLaserAcrossScreen])
            }
            // Changing laserTop physics because height changed
            laserTop.physicsBody = SKPhysicsBody(rectangleOf: laserTop.size)
            laserTop.physicsBody?.isDynamic = false
            laserTop.physicsBody?.allowsRotation = false
            laserTop.physicsBody?.categoryBitMask = laserCategory
            laserTop.physicsBody?.contactTestBitMask = playerCategory
            
            laserTop.run(SKAction.repeatForever(moveLaserAcrossScreenSequence))
        }
        laserPairTop.addChild(laserTop)
        
        // Contact node so score can be evaluated
        let contactNodeUp = SKNode()
        contactNodeUp.position = CGPoint(x: laserTop.size.width + player.size.width / 2, y: self.frame.midY)
        contactNodeUp.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: laserTop.size.width, height: heightOfFrame))
        contactNodeUp.physicsBody?.isDynamic = false
        // Categorize this node as a score
        contactNodeUp.physicsBody?.categoryBitMask = scoreCategory
        // Inform code when player comes into contact with this node
        contactNodeUp.physicsBody?.contactTestBitMask = playerCategory
        laserPairTop.addChild(contactNodeUp)
        
        laserPairTop.run(moveLasersAndRemove)
    }
    
    // Creating bottom laser mechanism
    func createBottomLaserMechanism(){
        let heightOfLaserBottom = CGFloat(2500)
        let widthOfLaser:CGFloat = CGFloat(50)
        // How much of the laser will be shown on screen
        var laserGap:CGFloat
        
        // Only allowing small lasers to spawn once score has reached 30
        if GameScene.score >= 30 {
            laserGap = CGFloat(arc4random_uniform(1051) + 500)
            // Only allowing oscillation for lasers between 1100 and 1550
        } else if GameScene.score > 5 && GameScene.score < 30{
            laserGap = CGFloat(arc4random_uniform(451) + 1100)
        } else {
            laserGap = CGFloat(arc4random_uniform(101) + 1000)
        }
        
        // Bottom laser mechanism
        laserPairDown = SKNode()
        laserPairDown.position = CGPoint(x: widthOfFrame + (laserTopTexture.size().width / 2), y: 50)
        laserPairDown.zPosition = 10
        
        // Bottom laser parts characteristics
        let laserTopHalfForBottom = SKSpriteNode(texture: laserTopTexture)
        laserTopHalfForBottom.setScale(1.3)
        // Setting 6 pixels to right so it'll be in middle of laser
        laserTopHalfForBottom.position = CGPoint(x: 6, y: 0)
        laserPairDown.addChild(laserTopHalfForBottom)
        
        let laserBottomHalfForBottom = SKSpriteNode(texture: laserBottomTexture)
        laserBottomHalfForBottom.setScale(5)
        laserBottomHalfForBottom.position = CGPoint(x: 0, y: laserTopHalfForBottom.size.height / 2)
        laserBottomHalfForBottom.zPosition = 1
        laserPairDown.addChild(laserBottomHalfForBottom)
        
        // Actual laser on bottom
        let laserDown = SKSpriteNode(texture: laserTexture)
        laserDown.size.height = heightOfLaserBottom
        laserDown.size.width = widthOfLaser
        laserDown.position = CGPoint(x: 0, y: -(laserDown.size.height / 2) + laserGap)
        laserDown.zPosition = -1
        laserDown.color = red
        laserDown.colorBlendFactor = 1
        
        laserDown.physicsBody = SKPhysicsBody(rectangleOf: laserDown.size)
        laserDown.physicsBody?.isDynamic = false
        laserDown.physicsBody?.allowsRotation = false
        laserDown.physicsBody?.categoryBitMask = laserCategory
        laserDown.physicsBody?.contactTestBitMask = playerCategory
        
        // Oscillating large lasers of size [1100, 1400] once score of 15 has been achieved
        if laserGap >= 1100 && laserGap <= 1400 && GameScene.score >= 15{
            laserDown.run(SKAction.repeatForever(oscillateLaserSequence))
        }
        
        // Moving small lasers of size [500, 850) across screen once score of 30 has been achieved
        if laserGap >= 500 && laserGap < 1000 && GameScene.score >= 30{
            // Changing laser height so it can move across screen
            laserDown.size.height = laserGap
            // Randomly deciding if laser spawns up or down
            let uOrD = arc4random_uniform(2)
            if uOrD == 0 {
                laserDown.position = CGPoint(x: 0, y: heightOfFrame)
                moveLaserAcrossScreenSequence = SKAction.sequence([moveDownLaserAcrossScreen, moveUpLaserAcrossScreen])
            } else {
                laserDown.position = CGPoint(x: 0, y: 0)
                moveLaserAcrossScreenSequence = SKAction.sequence([moveUpLaserAcrossScreen, moveDownLaserAcrossScreen])
            }
            // Changing laser physics because height changed
            laserDown.physicsBody = SKPhysicsBody(rectangleOf: laserDown.size)
            laserDown.physicsBody?.isDynamic = false
            laserDown.physicsBody?.allowsRotation = false
            laserDown.physicsBody?.categoryBitMask = laserCategory
            laserDown.physicsBody?.contactTestBitMask = playerCategory
            
            laserDown.run(SKAction.repeatForever(moveLaserAcrossScreenSequence))
        }
        laserPairDown.addChild(laserDown)
        
        // How to determine scoring area
        let contactNodeDown = SKNode()
        contactNodeDown.position = CGPoint(x: laserDown.size.width + player.size.width / 2, y: self.frame.midY)
        contactNodeDown.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: laserDown.size.width, height: heightOfFrame))
        contactNodeDown.physicsBody?.isDynamic = false
        contactNodeDown.physicsBody?.categoryBitMask = scoreCategory
        contactNodeDown.physicsBody?.contactTestBitMask = playerCategory
        laserPairDown.addChild(contactNodeDown)

        laserPairDown.run(moveLasersAndRemove)
    }
    
    func setUpCityBackground(){
        cityBackground1 = SKSpriteNode(texture: cityBackgroundTexture)
        cityBackground2 = SKSpriteNode(texture: cityBackgroundTexture)
        
        cityBackground1.size.width = widthOfFrame
        cityBackground1.size.height = heightOfFrame - 150
        cityBackground1.anchorPoint = CGPoint.zero
        cityBackground1.position = CGPoint(x: 0, y: 0)
        cityBackground1.zPosition = -30
        
        cityBackground2.size.width = widthOfFrame
        cityBackground2.size.height = heightOfFrame
        cityBackground2.anchorPoint = CGPoint.zero
        cityBackground2.position = CGPoint(x: cityBackground1.size.width - 1, y: 0)
        cityBackground2.zPosition = -30
        
        self.addChild(cityBackground1)
        self.addChild(cityBackground2)
    }
    
    func setUpCloudBackground(){
        cloudBackground1 = SKSpriteNode(texture: cloudBackgroundTexture)
        cloudBackground2 = SKSpriteNode(texture: cloudBackgroundTexture)
        
        cloudBackground1.size.width = widthOfFrame
        cloudBackground1.size.height = 550
        cloudBackground1.anchorPoint = CGPoint.zero
        cloudBackground1.position = CGPoint(x: 0, y: heightOfFrame * 0.76)
        cloudBackground1.zPosition = -40
        
        cloudBackground2.size.width = widthOfFrame
        cloudBackground2.size.height = 550
        cloudBackground2.anchorPoint = CGPoint.zero
        cloudBackground2.position = CGPoint(x: cloudBackground1.size.width - 1, y: heightOfFrame * 0.76)
        cloudBackground2.zPosition = -40
        
        self.addChild(cloudBackground1)
        self.addChild(cloudBackground2)
    }
    
    func setUpGroundBackground(){
        groundBackground1 = SKSpriteNode(texture: groundBackgroundTexture)
        groundBackground2 = SKSpriteNode(texture: groundBackgroundTexture)
        
        groundBackground1.size.width = widthOfFrame
        groundBackground1.size.height = 150
        groundBackground1.anchorPoint = CGPoint.zero
        groundBackground1.position = CGPoint(x: 0, y: 50)
        groundBackground1.zPosition = -20
        
        
        groundBackground2.size.width = widthOfFrame
        groundBackground2.size.height = 150
        groundBackground2.anchorPoint = CGPoint.zero
        groundBackground2.position = CGPoint(x: groundBackground1.size.width - 1, y: 50)
        groundBackground2.zPosition = -20
        
        self.addChild(groundBackground1)
        self.addChild(groundBackground2)
    }
    
    func explodeAndRemovePlayer(){
        let explosion:SKEmitterNode = SKEmitterNode(fileNamed: "BallExplosion")!
        explosion.position = player.position
        explosion.particleColor = player.color
        explosion.particleColorBlendFactor = 1
        explosion.particleColorSequence = nil
        
        player.removeFromParent()
        self.addChild(explosion)
    }
    
    // Shaking the camera on crash
    func shakeCamera(_ layer1:SKSpriteNode, layer2:SKSpriteNode, duration:Float) {
        let amplitudeX:Float = 10
        let amplitudeY:Float = 7
        let numberOfShakes = 2 / 0.04
        var actionsArray:[SKAction] = []
        
        for _ in 1...Int(numberOfShakes) {
            let moveX = Float(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2
            let moveY = Float(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2
            let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02)
            shakeAction.timingMode = SKActionTimingMode.easeOut
            actionsArray.append(shakeAction)
            actionsArray.append(shakeAction.reversed())
        }
        
        let actionSeq = SKAction.sequence(actionsArray)
        layer1.run(actionSeq)
        layer2.run(actionSeq)
    }
    
    func startEndScene() {
        let sceneTransitionFromMenuToGame:SKTransition = SKTransition.fade(withDuration: 0.8)
        let gameScene:SKScene = EndScene(size: self.size)
        
        // Only allowing the player to restart after half 0.8 seconds have passed after crash
        self.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(0.8)), SKAction.run({self.view?.presentScene(gameScene, transition: sceneTransitionFromMenuToGame)})]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        if moving.speed > 0  {
            movePlayerForever()
            if MenuScene.soundOn {
                self.run(playTapSound)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        // City
        
        // Moving the background to the left edge of the screen slowly only if player hasn't crashed
        if moving.speed > 0 && cityBackground1 != nil && cityBackground2 != nil{
            cityBackground1.position = CGPoint(x: cityBackground1.position.x - 0.7, y: cityBackground1.position.y)
            cityBackground2.position = CGPoint(x: cityBackground2.position.x - 0.7, y: cityBackground2.position.y)
            
            // Moving first background to right edge of screen when its position reaches off left edge of the screen
            if cityBackground1.position.x < -cityBackground1.size.width{
                cityBackground1.position = CGPoint(x: cityBackground2.position.x + cityBackground2.size.width - 1, y: cityBackground1.position.y)
            }
            
            // Moving second background to right edge of screen when its position reaches off left edge of the screen
            if cityBackground2.position.x < -cityBackground2.size.width{
                cityBackground2.position = CGPoint(x: cityBackground1.position.x + cityBackground1.size.width - 1, y: cityBackground2.position.y)
            }
        }
        
        // Clouds
        
        // Moving cloud background to the left edge of the screen slower than the city background only if player hasn't crashed
        if moving.speed > 0 && cloudBackground1 != nil && cloudBackground2 != nil{
            cloudBackground1.position = CGPoint(x: cloudBackground1.position.x - 0.4, y: cloudBackground1.position.y)
            cloudBackground2.position = CGPoint(x: cloudBackground2.position.x - 0.4, y: cloudBackground2.position.y)
            
            // Moving cloud background1 to right edge of screen when its position reaches off left edge of the screen
            if cloudBackground1.position.x < -cloudBackground1.size.width{
                cloudBackground1.position = CGPoint(x: cloudBackground2.position.x + cloudBackground2.size.width - 1, y: cloudBackground1.position.y)
            }
            
            // Moving cloud background2 to right edge of screen when its position reaches off left edge of the screen
            if cloudBackground2.position.x < -cloudBackground2.size.width{
                cloudBackground2.position = CGPoint(x: cloudBackground1.position.x + cloudBackground1.size.width - 1, y: cloudBackground2.position.y)
            }
        }
        
        // Ground
        
        // Moving ground background to the left edge of the screen faster than the city background only if player hasn't crashed
        if moving.speed > 0 && groundBackground1 != nil && groundBackground2 != nil{
            groundBackground1.position = CGPoint(x: groundBackground1.position.x - 5.5, y: groundBackground1.position.y)
            groundBackground2.position = CGPoint(x: groundBackground2.position.x - 5.5, y: groundBackground2.position.y)
            
            // Moving ground background1 to right edge of screen when its position reaches off left edge of the screen
            if groundBackground1.position.x < -groundBackground1.size.width {
                groundBackground1.position = CGPoint(x: groundBackground2.position.x + groundBackground2.size.width - 1, y: groundBackground1.position.y)
            }
            
            // Moving ground background2 to right edge of screen when its position reaches off left edge of the screen
            if groundBackground2.position.x < -groundBackground2.size.width {
                groundBackground2.position = CGPoint(x: groundBackground1.position.x + groundBackground1.size.width - 1, y: groundBackground2.position.y)
            }
        }
    }
    
    // When player comes in contact with world/scoring area/laser
    func didBegin(_ contact: SKPhysicsContact) {
        if moving.speed > 0 {
            if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
                // Player has contact with score entity
                GameScene.score += 1
                scoreLabelNode.text = String(GameScene.score)
                
                if MenuScene.soundOn {
                    self.run(scoreSound)
                }
                
                // Add a little visual feedback for the score increment
                scoreLabelNode.run(SKAction.sequence([SKAction.scale(to: 1.5, duration:TimeInterval(0.1)), SKAction.scale(to: 1, duration:TimeInterval(0.1))]))
            } else {
                moving.speed = 0
                
                player.physicsBody?.collisionBitMask = worldCategory
                player.removeAllActions()
                
                // Causes the player to explode into small bits and removes the ball from the scene
                explodeAndRemovePlayer()
                
                // Put an invisible shape that covers the screen
                // Used for making the flash
                let flashShape = SKShapeNode()
                flashShape.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: widthOfFrame, height: heightOfFrame), cornerRadius: 0).cgPath
                flashShape.position = CGPoint(x: 0, y: 0)
                flashShape.fillColor = UIColor.white
                flashShape.strokeColor = UIColor.white
                flashShape.alpha = 0
                flashShape.zPosition = 100
                self.addChild(flashShape)
                
                let alphaOne = SKAction.run({flashShape.alpha = 1})
                let fadeOutAction = SKAction.fadeOut(withDuration: 0.85)
                let fadeOutSequence = SKAction.sequence([alphaOne, fadeOutAction])
                
                flashShape.run(fadeOutSequence)
                
                if MenuScene.soundOn {
                    self.run(playCrashSound)
                }
                
                // Shaking camera once player has crashed
                shakeCamera(cityBackground1, layer2: cityBackground2, duration: 2)
                shakeCamera(cloudBackground1, layer2: cloudBackground2, duration: 2)
                shakeCamera(groundBackground1, layer2: groundBackground2, duration: 2)
                shakeCamera(scoreNode, layer2: scoreNode, duration: 2)
                
                SKTexture.preload(EndScene.endSceneTextures, withCompletionHandler: {self.startEndScene()})
            }
        }
    }
}
