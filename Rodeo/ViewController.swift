//
//  ViewController.swift
//  Rodeo
//
//  Created by Admin on 15/04/18.
//  Copyright © 2018 AstroWorld. All rights reserved.
//

import UIKit
import ARNTransitionAnimator
import KDEAudioPlayer

var playerView: LineView? = nil

final class ViewController: UIViewController {
    
    @IBOutlet fileprivate(set) weak var containerView : UIView!
    @IBOutlet fileprivate(set) weak var tabBar : UITabBar!
    @IBOutlet fileprivate(set) weak var miniPlayerView : LineView!
    @IBOutlet fileprivate(set) weak var miniPlayerButton : UIButton!
    
    private var animator : ARNTransitionAnimator?
    fileprivate var modalVC : ModalViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        self.modalVC = storyboard.instantiateViewController(withIdentifier: "ModalViewController") as? ModalViewController
        self.modalVC.modalPresentationStyle = .overFullScreen
        
        let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.3)
        self.miniPlayerButton.setBackgroundImage(self.generateImageWithColor(color), for: .highlighted)
        playerView = miniPlayerView
        self.setupAnimator()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleStateChange(notification:)), name: NSNotification.Name.init("playerstate"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("ViewController viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("ViewController viewWillDisappear")
    }
    
    func setupAnimator() {
        let animation = MusicPlayerTransitionAnimation(rootVC: self, modalVC: self.modalVC)
        animation.completion = { [weak self] isPresenting in
            if isPresenting {
                guard let _self = self else { return }
                let modalGestureHandler = TransitionGestureHandler(targetVC: _self, direction: .bottom)
                modalGestureHandler.registerGesture(_self.modalVC.view)
                modalGestureHandler.panCompletionThreshold = 5.0
                _self.animator?.registerInteractiveTransitioning(.dismiss, gestureHandler: modalGestureHandler)
            } else {
                self?.setupAnimator()
            }
        }
        
        self.modalVC.transitioningDelegate = self.animator
    }
    
    @IBAction func tapMiniPlayerButton() {
        if MusicPlayerViewController.sharedPlayer.currentMusicItem == nil {
            return
        }
        self.modalVC.dismiss(animated: false, completion: nil)
        self.present(self.modalVC, animated: true, completion: nil)
    }
    
    fileprivate func generateImageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func handleStateChange(notification: Notification) {
        let object = notification.object as! (from: AudioPlayerState, to: AudioPlayerState)
        switch object.to {
        case .buffering:
            self.miniPlayerView.btnPausePlay.isHidden = true
            self.miniPlayerView.activityIndicator.isHidden = false
            self.miniPlayerView.activityIndicator.startAnimating()
        case .failed(let error):
            self.view.makeToast(error.localizedDescription)
        case .paused:
            self.miniPlayerView.btnPausePlay.isHidden = false
            self.miniPlayerView.activityIndicator.isHidden = true
            self.miniPlayerView.btnPausePlay.setImage(#imageLiteral(resourceName: "play-button"), for: .normal)
            self.miniPlayerView.activityIndicator.stopAnimating()
        case .playing:
            self.miniPlayerView.btnPausePlay.isHidden = false
            self.miniPlayerView.activityIndicator.isHidden = true
            self.miniPlayerView.btnPausePlay.setImage(#imageLiteral(resourceName: "pause-button"), for: .normal)
            self.miniPlayerView.activityIndicator.stopAnimating()
        case .stopped:
            self.miniPlayerView.btnPausePlay.isHidden = false
            self.miniPlayerView.activityIndicator.isHidden = true
            self.miniPlayerView.btnPausePlay.setImage(#imageLiteral(resourceName: "play-button"), for: .normal)
            self.miniPlayerView.activityIndicator.stopAnimating()
        case .waitingForConnection:
            self.miniPlayerView.btnPausePlay.isHidden = true
            self.miniPlayerView.activityIndicator.isHidden = false
            self.miniPlayerView.btnPausePlay.setImage(#imageLiteral(resourceName: "pause-button"), for: .normal)
            self.miniPlayerView.activityIndicator.startAnimating()
        }
    }
}


