import Foundation


class MainScene: CCScene {
    
    func playPressed() {        
        let scene = CCBReader.loadAsScene("PlayScene");
        CCDirector.sharedDirector().replaceScene(scene, withTransition: CCTransition.init(crossFadeWithDuration: 0.5));
    }
}