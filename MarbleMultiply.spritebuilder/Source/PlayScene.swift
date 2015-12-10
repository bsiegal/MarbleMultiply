import Foundation


class PlayScene: CCNode {
    /*
        Components added through SpriteBuilder
    */
    weak var _problemLbl: CCLabelTTF! //weak because it may become nil; ! means an implicitly unwrapped optional (!)
    weak var _answerLbl: CCLabelTTF!
    weak var _physicsNode: CCPhysicsNode!
    weak var _magic: CCParticleExplosion!
    
    /*
        Int variables for the problem and answer
    */
    var _answer: Int = 0
    var _factor1: Int = 0
    var _factor2: Int = 0
    
    /*
        Array to hold the marbles representing the problem
    */
    var _marbles = [CCNode]()
    
    /*
        When scene is loaded
    */
    func didLoadFromCCB() {
        _answerLbl.string = "0";
        newProblem()
    }
    
    /*
        The marbles sprite frames are 0 to 4, but do not use the last color chosen
        @param donotDup is a String of the last spriteFrame name used
        @return String the new spriteFrame
    */
    func randomMarbleColorSpriteFrame(donotDup: String) -> String {
        let num = arc4random_uniform(5)
        let ret = "sprites/marble_\(num).png";
        if (donotDup == ret) {
            return randomMarbleColorSpriteFrame(donotDup);
        }
        return ret;
    }
    
    /*
        Generate a new problem and show the string and marbles that represent the problem
    */
    func newProblem() {
        
        _factor1 = Int(arc4random_uniform(10)) + 1
        _factor2 = Int(arc4random_uniform(10)) + 1
        _answer = _factor1 * _factor2
        
        _problemLbl.string = "\(_factor1) x \(_factor2) = "
        
        /*
            Add _factor2 rows of _factor1 marbles
            Each row is the same color
        */
        var lastSpriteFrame:String = "sprites/marble.png";
        
        for (var j: Int = 1; j <= _factor2; j++) {

            let spriteFrame = randomMarbleColorSpriteFrame(lastSpriteFrame);
            lastSpriteFrame = spriteFrame;
            
            for (var i: Int = 1; i <= _factor1; i++) {
                let node: CCNode = CCBReader.load("Marble");
                let marble: CCSprite = node as! CCSprite //Cast as a CCSprite
                
                marble.spriteFrame = CCSpriteFrame(imageNamed: spriteFrame);
                marble.scale = 0.5;
                
                marble.position = CGPoint.init(
                    x: CGFloat((marble.contentSize.width * CGFloat(marble.scale)) * CGFloat(i)),
                    y: (CCDirector.sharedDirector().viewSize().height - 40 - CGFloat(marble.contentSize.height * CGFloat(marble.scale) * CGFloat(j)))
                );
                
                _physicsNode.addChild(marble);
                
                _marbles.append(marble);
            }
        }
        
    }
    
    /*
        SpriteBuilder button pressed events
    */
    
    func enterPressed() {
        NSLog("enterPressed")
        _problemLbl.string = "\(_factor1) x \(_factor2) = \(_answer)"
        
        if (_answer == Int(_answerLbl.string)) {

            answerCorrect()
            
        } else {
            
            answerWrong()

        }
        
        /*
            Show a new problem after a delay
        */
        let seconds = 2.5
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self._magic.visible = false;
            
            self._marbles.removeAll()

            self.newProblem()
            
        })

        
    }
    
    func clearPressed() {
        NSLog("clearPressed")
        _answerLbl.string = "";
    }
    
    func numberPressed(sender:CCButton) {
        NSLog("numberPressed")
        /*
         * If there is a single 0 instead of appending replace
         */
        if (_answerLbl.string == "0" || _answerLbl.string == ":)" || _answerLbl.string == ":O") {
            _answerLbl.string = sender.title
        } else {
            _answerLbl.string = _answerLbl.string + sender.title
        }
    }
    
    /*
        When answer is correct, let the marbles fall into the beaker by turning on gravity.
        Show some magic then hide it after a delay.
    */
    func answerCorrect() {
        
        _answerLbl.string = ":)"
        
        _magic.visible = true;
        
        for marble in _marbles {
            marble.physicsBody.affectedByGravity = true
        }
        
        //hide the magic
        let seconds = 0.5
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self._magic.visible = false;
            
        })

    }
    

    /*
        When answer is wrong, remove all the marbles
        Show the burst to make them look like they blew up
    */
    func answerWrong() {
        
        _answerLbl.string = ":O"
        
        /*
            Show a burst in the center of the beaker
        */
        let burst1 = CCBReader.load("Burst")
        burst1.position = CGPoint.init(x: 164, y: 76)
        addChild(burst1)

        /*
            Show a burst in the center of the problem
        */
        let burst2 = CCBReader.load("Burst")
        
        burst2.position = CGPoint.init(
            x: CGFloat(_factor1 / 2 * 20 + 10),
            y: CCDirector.sharedDirector().viewSize().height - CGFloat(40 + 20 * _factor2 / 2)
        )
        addChild(burst2)
        
        /*
            Remove all the marbles after a slight delay
        */
        let dispatchTimeMarbles = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTimeMarbles, dispatch_get_main_queue(), {
            
            /*
                Get all the children of the physicsNode
            */
            for child in self._physicsNode.children {
                
                /*
                    If a child has a dynamic (non static) physics body, it must be a marble,
                    dissolve it, then really remove it
                */
                let physBod: CCPhysicsBody = child.physicsBody;
                if (physBod.type == CCPhysicsBodyType.Dynamic) {
                    
                    let rotate = CCActionRotateBy(duration: 0.5, angle: 360.0);
                    child.runAction(rotate);
                    
                    let dissolve = CCActionFadeOut(duration: 0.5)
                    let remove = CCActionRemove()
                    let sequence = CCActionSequence(array: [dissolve, remove])
                    child.runAction(sequence)
                    
                }
            }
        })
        

        /*
            remove all bursts from parent
        */
        let dispatchTimeBurst = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
        
        dispatch_after(dispatchTimeBurst, dispatch_get_main_queue(), {
            burst1.removeFromParentAndCleanup(true);
            burst2.removeFromParentAndCleanup(true);
        })

    }

    /*
        This is how to override a function (without the override keyword we'd get a compile error)
    */
    override func update(delta: CCTime) {
        for child in _physicsNode.children {

            /*
                If a child as rolled off the screen, may as well remove it
            */
            let pos: CGPoint = child.position;
            if (pos.x < -10 || pos.x > CCDirector.sharedDirector().viewSize().width + 10) {
                child.removeFromParentAndCleanup(true);
                NSLog("removed");
            }
        }
    }
}
