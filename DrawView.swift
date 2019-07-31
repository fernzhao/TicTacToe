//feifei zhao
//101047476
import UIKit

class DrawView: UIView {
    //public funtion

    func clear(){
        _ =  paths.removeAll()
        setNeedsDisplay()
        resetGame()
    }
    
    let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleClear), for: .touchUpInside)
        
        return button
    }()
    @objc fileprivate func handleClear(){
        clear()
    }
    
    func undo(){
        _ = paths.popLast()
        setNeedsDisplay()
    }
    let undoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Undo", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleUndo), for: .touchUpInside)
        
        return button
    }()
    @objc fileprivate func handleUndo(){
        undo()
        
    }

    var game = [[" "," "," "],[" "," "," "],[" "," "," "]]
 
    var s = " | ", mark = "1"
    var xTurn = true
    var winInfo = "DRAW BOARD"
    
    var scoreX = 0, scoreO = 0, round = 0
    
    var run = true;//
    var board = true;//
    var lineNumber = 0;
    
    var tem,x1,x2,y1,y2,x0,x3,y0,y3:CGFloat?
    //var c1,c2,d1,d2:CGFloat?
    
    // var a1,a2,b1,b2:CGFloat?
    var a1,a2,a3,a4: CGFloat? //satrtpoint 1 and 2
    var b1,b2,b3,b4: CGFloat?
    var context = UIGraphicsGetCurrentContext()
    var currentLines = [NSValue:Line]() //dictionary of key-value pairs
    var paths = [[CGPoint]]()
    
    var winLine = Line(begin: CGPoint(x:0,y:0), end: CGPoint(x:0,y:0));
    
    
    var finishedLines = [Line]()
    
    @IBInspectable var finishColor: UIColor = UIColor.blue {didSet {setNeedsDisplay()}}
    @IBInspectable var pathColor: UIColor = UIColor.orange {didSet {setNeedsDisplay()}}
    @IBInspectable var pathThickness: CGFloat = 8 {didSet {setNeedsDisplay()}}
    
    @IBInspectable var finishedLineColor: UIColor = UIColor.black {didSet {setNeedsDisplay()}}
    @IBInspectable var currentLineColor: UIColor = UIColor.red {didSet {setNeedsDisplay()}}
    @IBInspectable var lineThickness: CGFloat = 5 {didSet {setNeedsDisplay()}}
    
    
    func strokeLine(line: Line){
        //Use BezierPath to draw lines
        let path = UIBezierPath();
        path.lineWidth = lineThickness;
        path.lineCapStyle = CGLineCap.round;
        path.move(to: line.begin);
        path.addLine(to: line.end);
        path.stroke(); //actually draw the path
    }
    func strokePath(line: Line){
        //Use BezierPath to draw lines
        let path = UIBezierPath();
        path.lineWidth = pathThickness;
        path.lineCapStyle = CGLineCap.round;
        path.move(to: line.begin);
        path.addLine(to: line.end);
        path.stroke(); //actually draw the path
    }
    
    func printBoard(){
        //printed the state of the board
        for i in 0...2 {
            for j in 0...2{
                if j == 2{
                    s = ""
                }else{
                    s = " | "
                }
                print(game[i][j],terminator: s)
            }
            if i != 2 {
                print("\n----------")
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        let s: NSString = "\(winInfo)\n    " as NSString
        
        // set the text color to dark grcay
        let fieldColor: UIColor = UIColor.darkGray
        
        // set the font to Helvetica Neue 18
        let fieldFont = UIFont(name: "Helvetica Neue", size: 18)
        
        // set the line spacing to 6
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 6.0
        
        // set the Obliqueness to 0.1
        let skew = 0.1
        
        let attributes: NSDictionary = [
            NSAttributedString.Key.foregroundColor: fieldColor,
            NSAttributedString.Key.paragraphStyle: paraStyle,
            NSAttributedString.Key.obliqueness: skew,
            NSAttributedString.Key.font: fieldFont!
        ]
        
        s.draw(in: CGRect(x: 20.0, y: 50.0, width: 300.0, height: 48.0), withAttributes: attributes as? [NSAttributedString.Key : Any])
        
        
        //        game[0][1] = "2"
        //        game[1][0] = "X"
        
        //draw current path if it exists
        pathColor.setStroke()
        if board == false{
            guard let context = UIGraphicsGetCurrentContext() else{return}
            context.setLineWidth(pathThickness)
            context.setLineCap(CGLineCap.round)
            
            paths.forEach { (currPath) in
                for(i,p) in currPath.enumerated(){
                    if i==0 {
                        context.move(to: p)
                    }else{
                        context.addLine(to: p)
                    }
                }
            }
            context.strokePath()
        }
        
        //draw the finished lines
        finishedLineColor.setStroke() //set colour to draw
        for line in finishedLines{
            strokeLine(line: line);
        }
        
        if run == false {
            strokeLine(line: winLine)
        }
        
        if checkWin() == "X" || checkWin() == "O"{
            finishColor.setStroke() //set colour to draw
            strokePath(line: winLine)
        }
        //draw current lines if it exists
        for (_ ,line) in currentLines{
            currentLineColor.setStroke();
            strokeLine(line: line);
        }
        
    }
    
    //Override Touch Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        print(#function) //for debugging
        if board == true{
            for touch in touches {
                let location = touch.location(in: self)
                let newLine = Line(begin: location, end: location)
                let key = NSValue(nonretainedObject: touch)
                currentLines[key] = newLine
              //  print("-X-",location.x)
              //  print("-Y-",location.y)
                
            }
        }else{
            for touch in touches {
                let location = touch.location(in: self)
                let newLine = Line(begin: location, end: location)
                let key = NSValue(nonretainedObject: touch)
                currentLines[key] = newLine
                if a1 == nil{
                    a1 = location.x
                    a2 = location.y
                }else{
                    a3 = location.x
                    a4 = location.y
                }

            }
            paths.append([CGPoint]())
            
            
        }
        setNeedsDisplay(); //this view needs to be updated
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //TODO
        //        print(#function) //for debugging
        if board == true{
            for touch in touches{
                let location = touch.location(in: self);
                let key = NSValue(nonretainedObject: touch)
                currentLines[key]?.end = location
            }
        }else{
            guard let point = touches.first?.location(in: nil) else {return}
            
            guard var lastPath = paths.popLast() else {return}
            lastPath.append(point)
            paths.append(lastPath)
        }
        setNeedsDisplay();
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //TODO
        print(#function) //for debugging
        if board == true{
            for touch in touches{
                let key = NSValue(nonretainedObject: touch)
                if currentLines[key] != nil {
                    var location = touch.location(in: self)
                    let firstlocation = currentLines[key]!.begin
                    let differX = location.x - firstlocation.x
                    let differY = location.y-firstlocation.y
                    if abs(differX) > abs(differY){
                        x0 = firstlocation.x
                        x3 = location.x
                        if x3!.isLess(than: x0!){
                            tem = x0
                            x0 = x3
                            x3 = tem
                            
                        }
                        location.y = firstlocation.y
                        if y1 == nil  {
                            y1 = location.y
                        }else{
                            y2 = location.y
                            if y2!.isLess(than: y1!){
                                tem = y1!;
                                y1 = y2!
                                y2 = tem!
                            }
                            
                        }
                    }
                    else{
                        y0 = firstlocation.y
                        y3 = location.y
                        if y3!.isLess(than: y0!){
                            tem = y0
                            y0 = y3
                            y3 = tem
                            
                        }
                        
                        location.x = firstlocation.x
                        if x1 == nil{
                            x1 = location.x
                            //print("x1:")
                           // print(x1!)
                        }else{
                            
                            x2 = location.x
                            if x2!.isLess(than: x1!){
                                tem = x1!;
                                x1 = x2!
                                x2 = tem!
                                x3 = max(x3!,x2!)
                                
                            }
                           // print("x2:")
                           // print(x2! )
                        }
                        
                    }
                    currentLines[key]?.end = location;
                    finishedLines.append(currentLines[key]!)
                    lineNumber += 1
                    //var c1 = (x1! - x0!)/2 + x0!
                    if lineNumber == 4{
                        
       
                        board = false
                        //run = false
                        print("borded!!!")
                        printBoard()
                        round += 1
                    }
                }
                currentLines[key] = nil
            }
        }else{
            for touch in touches {
                let location = touch.location(in: self)
                
                //let firstlocation = currentLines[key]!.begin
                
                let key = NSValue(nonretainedObject: touch)
                let firstlocation = currentLines[key]!.begin
                let FernDX = abs(location.x - firstlocation.x)
                let FernDY = abs(location.y - firstlocation.y)
                let FX = firstlocation.x
                let FY = firstlocation.y
           
                
                let FernSqure = sqrt(Double(Int(FernDX)^2 + Int(Int(FernDY)^2)))

           

                
                if FX < x1!{
                    if FY < y1! {
                        print("[0][0]")
                        if FernSqure < 4{
                           // print("It is O")
                            a1 = nil
                            a2 = nil
                            a3 = nil
                            a4 = nil
                            game[0][0] = "O"
                            printBoard()
                        }else{
                            //let m = abs(a4! - a2!)
                            if a4 != nil{
                                let m = abs(a4! - a2!)
                                if m < 15 {
                                    //print("It is X")
                                    game[0][0] = "X"
                                    printBoard()
                                }
                                else{
                                    print("Draw again it is not X or O")
                                    undo()
                                }
                            }
                        }
                        
                    }
                    else if FY > y1! && FY < y2!{
                        print("[1][0]")
                        if FernSqure < 4{
                            // print("It is O")
                            a1 = nil
                            a2 = nil
                            a3 = nil
                            a4 = nil
                            game[1][0] = "O"
                            printBoard()
                        }else{
                            //let m = abs(a4! - a2!)
                            if a4 != nil{
                                let m = abs(a4! - a2!)
                                if m < 15 {
                                    //print("It is X")
                                    game[1][0] = "X"
                                    printBoard()
                                }
                                else{
                                    print("Draw again it is not X or O")
                                    undo()
                                }
                            }
                        }
                    }
                    else if FY > y2!{
                        print("[2][0]")
                        if FernSqure < 4{
                            // print("It is O")
                            a1 = nil
                            a2 = nil
                            a3 = nil
                            a4 = nil
                            game[2][0] = "O"
                            printBoard()
                        }else{
                            //let m = abs(a4! - a2!)
                            if a4 != nil{
                                let m = abs(a4! - a2!)
                                if m < 15 {
                                    //print("It is X")
                                    game[2][0] = "X"
                                    printBoard()
                                }
                                else{
                                    print("Draw again it is not X or O")
                                    undo()
                                }
                            }
                        }
                    }
                }
                else if FX > x1! && FX < x2!{
                    if FY < y1!{
                        print("[0][1]")
                        if FernSqure < 4{
                            // print("It is O")
                            a1 = nil
                            a2 = nil
                            a3 = nil
                            a4 = nil
                            game[0][1] = "O"
                            printBoard()
                        }else{
                            //let m = abs(a4! - a2!)
                            if a4 != nil{
                                let m = abs(a4! - a2!)
                                if m < 15 {
                                    //print("It is X")
                                    game[0][1] = "X"
                                    printBoard()
                                }
                                else{
                                    print("Draw again it is not X or O")
                                    undo()
                                }
                            }
                        }
                    }
                    else if FY > y1! && FY < y2!{
                        print("[1][1]")
                        if FernSqure < 4{
                            // print("It is O")
                            a1 = nil
                            a2 = nil
                            a3 = nil
                            a4 = nil
                            game[1][1] = "O"
                            printBoard()
                        }else{
                            //let m = abs(a4! - a2!)
                            if a4 != nil{
                                let m = abs(a4! - a2!)
                                if m < 15 {
                                    //print("It is X")
                                    game[1][1] = "X"
                                    printBoard()
                                }
                                else{
                                    print("Draw again it is not X or O")
                                    undo()
                                }
                            }
                        }
                    }
                    else if FY > y2!{
                        print("[2][1]")
                        if FernSqure < 4{
                            // print("It is O")
                            a1 = nil
                            a2 = nil
                            a3 = nil
                            a4 = nil
                            game[2][1] = "O"
                            printBoard()
                        }else{
                            //let m = abs(a4! - a2!)
                            if a4 != nil{
                                let m = abs(a4! - a2!)
                                if m < 15 {
                                    //print("It is X")
                                    game[2][1] = "X"
                                    printBoard()
                                }
                                else{
                                    print("Draw again it is not X or O")
                                    undo()
                                }
                            }
                        }
                    }
                }
                else if FX > x2! {
                    if FY < y1!{
                        print("[0][2]")
                        if FernSqure < 4{
                            // print("It is O")
                            a1 = nil
                            a2 = nil
                            a3 = nil
                            a4 = nil
                            game[0][2] = "O"
                            printBoard()
                        }else{
                            //let m = abs(a4! - a2!)
                            if a4 != nil{
                                let m = abs(a4! - a2!)
                                if m < 15 {
                                    //print("It is X")
                                    game[0][2] = "X"
                                    printBoard()
                                }
                                else{
                                    print("Draw again it is not X or O")
                                    undo()
                                }
                            }
                        }
                    }
                    else if FY > y1! && FY < y2!{
                        print("[1][2]")
                        if FernSqure < 4{
                            // print("It is O")
                            a1 = nil
                            a2 = nil
                            a3 = nil
                            a4 = nil
                            game[1][2] = "O"
                            printBoard()
                        }else{
                            //let m = abs(a4! - a2!)
                            if a4 != nil{
                                let m = abs(a4! - a2!)
                                if m < 15 {
                                    //print("It is X")
                                    game[1][2] = "X"
                                    printBoard()
                                }
                                else{
                                    print("Draw again it is not X or O")
                                    undo()
                                }
                            }
                        }
                    }
                    else if FY > y2!{
                        print("[2][2]")
                        if FernSqure < 4{
                            // print("It is O")
                            a1 = nil
                            a2 = nil
                            a3 = nil
                            a4 = nil
                            game[2][2] = "O"
                            printBoard()
                        }else{
                            //let m = abs(a4! - a2!)
                            if a4 != nil{
                                let m = abs(a4! - a2!)
                                if m < 15 {
                                    //print("It is X")
                                    game[2][2] = "X"
                                    printBoard()
                                }
                                else{
                                    print("Draw again it is not X or O")
                                    undo()
                                }
                            }
                        }
                    }
                }
//checkWin()
                
                
                
            }
        }
        setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        //TODO
        print(#function) //for debugging
        setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        let doubleTapRecognizer =
            UITapGestureRecognizer(target: self,
                                   action: #selector(DrawView.doubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapRecognizer)
        
    }
    @objc func doubleTap(_ gestureRecognizer: UIGestureRecognizer){
        print("I got a double tap")
        if run == true{
            print("Game in still run")
        }else if run == false {
            print("Double to clean")
            
            resetGame()
            
        }
        setNeedsDisplay()
    }
    
    func resetGame(){
        x0 = nil
        
        x1 = nil
        
        x2 = nil
        
        x3 = nil
        
        
        
        y0 = nil
        
        y1 = nil
        
        y2 = nil
        
        y3 = nil

        
        print(">> Restart Game <<")
        

        winInfo = ""
        
        currentLines.removeAll(keepingCapacity: false)
        
        finishedLines.removeAll(keepingCapacity: false)
        
        paths.removeAll(keepingCapacity: false)
        
        board = true
        
        run = true
        
        lineNumber = 0;
        
        game = [[" "," "," "],[" "," "," "],[" "," "," "]]
    }
    
    func drawGame(){
        printBoard()
        run = false
        winInfo = "DRAW GAME!"
    }
    
    func XplayerWin(){
        scoreX += 1
        run = false
        winInfo = " X WIN!!!"
        
    }
    
    func OplayerWin(){
        scoreO += 1
        run = false
        winInfo = " O WIN!!!"
    }
    func tie(){
        run = false
        winInfo = "TIE GAME!"
    }
   // var c1 = (x1! - x0!)/2 + x0!
    func checkWin() -> String{

        if (game[0][0] == game[1][1]) && (game[0][0] == game[2][2]) && (game[0][0] !=  " ") {
            if game[0][0] == "X"{
                XplayerWin()
                
                winLine.begin = CGPoint(x:x0!, y:y0!)
                winLine.end = CGPoint(x:x3!, y:y3!)
                finishColor.setStroke()
                strokeLine(line: winLine)
      
            }
            else if game[0][0] == "O" {
                OplayerWin()
                print("\n O player win")
                winLine.begin = CGPoint(x:x0!, y:y0!)
                winLine.end = CGPoint(x:x3!, y:y3!)
                finishColor.setStroke()
                strokeLine(line: winLine)
       
            }
      
        }
            
        else if (game[0][0] == game[1][0]) && (game[0][0] == game[2][0]) && (game[0][0] !=  " ") {
            let c1 = (x1! - x0!)/2 + x0!
            if game[0][0] == "X"{
                XplayerWin()
                
                winLine.begin = CGPoint(x:c1, y:y0!)
                winLine.end = CGPoint(x:c1, y:y3!)
                finishColor.setStroke()
                strokeLine(line: winLine)
                
            }
            else if game[0][0] == "O" {
                OplayerWin()
                winLine.begin = CGPoint(x:c1, y:y0!)
                winLine.end = CGPoint(x:c1, y:y3!)
                finishColor.setStroke()
                strokeLine(line: winLine)
              
            }
           
        }
        else if (game[0][0] == game[0][1]) && (game[0][0] == game[0][2]) && (game[0][0] !=  " ") {
            let r1 = (y1! - y0!)/2 + y0!
            if game[0][0] == "X"{
                XplayerWin()
                winLine = Line(begin: CGPoint(x:x0!, y:r1), end: CGPoint(x:x3!, y:r1))
                
                finishColor.setStroke()
                
                strokeLine(line: winLine)
                

             
            }
            else if game[0][0] == "O" {
                OplayerWin()
                winLine = Line(begin: CGPoint(x:x0!, y:r1), end: CGPoint(x:x3!, y:r1))
                
                finishColor.setStroke()
                
                strokeLine(line: winLine)
                
                
            }
        }
        else if (game[0][1] == game[1][1]) && (game[0][1] == game[2][1]) && (game[0][1] !=  " ") {
            let c2 = (x2! - x1!)/2 + x1!
            if game[0][1] == "X"{
                XplayerWin()

                winLine = Line(begin: CGPoint(x:c2, y:y0!), end: CGPoint(x:c2, y:y3!))
                finishColor.setStroke()
                strokeLine(line: winLine)
            }
            else if game[0][1] == "O" {
                OplayerWin()
                winLine = Line(begin: CGPoint(x:c2, y:y0!), end: CGPoint(x:c2, y:y3!))
        
                finishColor.setStroke()
                strokeLine(line: winLine)
           
            }
        }
            
        else if (game[0][2] == game[1][2]) && (game[0][2] == game[2][2]) && (game[0][2] !=  " ") {
            let c3 = (x3! - x2!)/2 + x2!
            if game[0][2] == "X"{
                XplayerWin()
                winLine = Line(begin: CGPoint(x:c3, y:y0!), end: CGPoint(x:c3, y:y3!))
                finishColor.setStroke()
                strokeLine(line: winLine)
            }
            else if game[0][2] == "O" {
                OplayerWin()
                winLine = Line(begin: CGPoint(x:c3, y:y0!), end: CGPoint(x:c3, y:y3!))
                finishColor.setStroke()
                strokeLine(line: winLine)
            }
        }
            
        else if (game[0][2] == game[1][1]) && (game[0][2] == game[2][0]) && (game[0][2] !=  " ") {
            if game[0][2] == "X"{
                XplayerWin()
                winLine.begin = CGPoint(x:x3!, y:y0!)
                winLine.end = CGPoint(x:x0!, y:y3!)
                finishColor.setStroke()
                strokeLine(line: winLine)

            }
            else if game[0][2] == "O" {
                OplayerWin()
                winLine.begin = CGPoint(x:x3!, y:y0!)
                winLine.end = CGPoint(x:x0!, y:y3!)
                finishColor.setStroke()
                strokeLine(line: winLine)

            }
        }
            
        else if (game[1][0] == game[1][1]) && (game[1][0] == game[1][2]) && (game[1][0] !=  " ") {
           let r2 = (y2! - y1!)/2 + y1!
            if game[1][0] == "X"{
                XplayerWin()
                winLine = Line(begin: CGPoint(x:x0!, y:r2), end: CGPoint(x:x3!, y:r2))
                
                finishColor.setStroke()
                
                strokeLine(line: winLine)
                //run = false
            }
            else if game[1][0] == "O" {
                OplayerWin()
                winLine = Line(begin: CGPoint(x:x0!, y:r2), end: CGPoint(x:x3!, y:r2))
                
                finishColor.setStroke()
                
                strokeLine(line: winLine)
            }
        }
            
            
        else if (game[2][0] == game[2][1]) && (game[2][0] == game[2][2]) && (game[2][0] !=  " ") {
            let r3 = (y3! - y2!)/2 + y2!
            if game[2][0] == "X"{
                XplayerWin()
                winLine = Line(begin: CGPoint(x:x0!, y:r3), end: CGPoint(x:x3!, y:r3))
                
                finishColor.setStroke()
                
                strokeLine(line: winLine)
          
            }
            else if game[2][0] == "O" {
                OplayerWin()
                winLine = Line(begin: CGPoint(x:x0!, y:r3), end: CGPoint(x:x3!, y:r3))
                
                finishColor.setStroke()
                
                strokeLine(line: winLine)
            }
        }
        
        
        for i in 0...2 {
            for j in 0...2 {
                if game[i][j] ==  " " {
                    return game[i][j]
                }
                
            }
        }
        
        tie()
        return "DREW"
    }
    
}


// let c3 = (x3! - x2!)/2 + x2!
// let r1 = (y1! - y0!)/2 + y0!
//let r2 = (y2! - y1!)/2 + y1!
// let r3 = (y3! - y2!)/2 + y2!
