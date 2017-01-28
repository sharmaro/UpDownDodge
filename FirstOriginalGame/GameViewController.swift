//
//  GameViewController.swift
//  FirstOriginalGame
//
//  Created by Rohan Sharma on 7/28/16.
//  Copyright (c) 2016 Opel. All rights reserved.
//

import SpriteKit
import GameKit
import GoogleMobileAds

class GameViewController: UIViewController, GADBannerViewDelegate {
    
    var googleBannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = GADRequest()
//        request.testDevices = ["f8820f602b220b396bbc2f769f7fe3d7"]
        
        googleBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerLandscape)
        googleBannerView.delegate = self
        googleBannerView.adUnitID = "ca-app-pub-5090642875042075/2528826742"
        googleBannerView.rootViewController = self
        googleBannerView.load(request)
        googleBannerView.frame = CGRect(x: 0, y: view.bounds.height - googleBannerView.frame.size.height, width: googleBannerView.frame.size.width, height: googleBannerView.frame.size.height)
        
        self.view.addSubview(googleBannerView!)
        
        authenticateLocalPlayer()
        
        MenuScene.musicOn = true
        MenuScene.soundOn = true
        MenuScene.setUpAudioPlayer()
        if MenuScene.musicOn {
            MenuScene.playBackgroundMusic()
        }
        
        SKTexture.preload(MenuScene.menuSceneTextures, withCompletionHandler: {self.startMenuScene()})
    }
    
    func startMenuScene() {
        if let scene = MenuScene(fileNamed:"MenuScene") {
            // Configure the view.
            let skView = self.view as! SKView
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFit
            
            skView.presentScene(scene)
        }
    }
    
    // Leaderboard function
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                self.present(viewController!, animated: true, completion: nil)
            }
            else {
            }
        }
    }
    
    //Sends highest score to leaderboard
    static func saveHighscore(_ gameScore: Int) {
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "com.Zin.UpDownDodge")
            scoreReporter.value = Int64(gameScore)
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: {error -> Void in
                if error != nil {
                }
            })
        }
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
