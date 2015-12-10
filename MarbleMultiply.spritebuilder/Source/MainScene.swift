import Foundation


class MainScene: CCNode {
    
    func playPressed() {        
        let scene = CCBReader.loadAsScene("PlayScene");
        CCDirector.sharedDirector().replaceScene(scene, withTransition: CCTransition.init(crossFadeWithDuration: 0.5));
    }
}