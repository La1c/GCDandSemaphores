//
//  ViewController.swift
//  GCDSamples
//
//  Created by Gabriel Theodoropoulos on 07/11/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // simpleQueues()
        
         //queuesWithQoS()
        
        
        // concurrentQueues()
        
         if let queue = inactiveQueue {
            queue.activate()
         }
 
        
        // queueWithDelay()
        
        fetchImage()
        
        // useWorkItem()
        //testQueue()
     //   testAsyncQueue()
      //  queuesWithQoSDifPriorities()
       // queuesWithQoSBackgroundPriorities()
       // queueWithDelay()
       // globalQueues()
        
        //semaphoreTest()
        deadlockPossible()
    }
    
    func testQueue(){
        print("Sync queue")
        let q = DispatchQueue(label: "com.test.firstQueue")
        q.sync{
            for i in 0..<10{
                print("RED ", i)
            }
        }
        
        for i in 0..<10{
            print("Ⓜ️", i)
        }
    }
    
    func testAsyncQueue(){
        print("Async queue")
        let q = DispatchQueue(label: "com.test.asyncTestQueue")
        q.async {
            for i in 0..<10{
                print("RED ", i)
            }
        }
        
        for i in 0..<10{
            print("Ⓜ️", i)
        }
    }
    
    
    
    func simpleQueues() {
        
    }
    
    
    func queuesWithQoS() {
        let initiatedQ1 = DispatchQueue(label: "com.test.initiatedQueue1", qos: .userInitiated)
        let initiatedQ2 = DispatchQueue(label: "com.test.initiatedQueue2", qos: .userInitiated)
        
        
        print("Initiated queues")
        initiatedQ1.async {
            for i in 0..<10{
                print("RED init", i)
            }
        }
        
        initiatedQ2.async {
            for i in 0..<10{
                print("Ⓜ️ init", i)
            }
        }
        
    }
    
    func queuesWithQoSDifPriorities() {
        let initiatedQ1 = DispatchQueue(label: "com.test.initiatedQueue1", qos: .utility)
        let initiatedQ2 = DispatchQueue(label: "com.test.initiatedQueue2", qos: .userInitiated)
        
        
        print("Initiated queues with different priorities")
        initiatedQ1.async {
            for i in 0..<10{
                print("RED ", i)
            }
        }
        
        initiatedQ2.async {
            for i in 0..<10{
                print("Ⓜ️ ", i)
            }
        }
        
    }
    
    func queuesWithQoSBackgroundPriorities() {
        let initiatedQ1 = DispatchQueue(label: "com.test.initiatedQueue1", qos: .utility)
        let initiatedQ2 = DispatchQueue(label: "com.test.initiatedQueue2", qos: .userInitiated)
        
        
        print("Background vs utility")
        initiatedQ1.async {
            for i in 0..<10{
                print("RED utility", i)
            }
        }
        
        initiatedQ2.async {
            for i in 0..<10{
                print("Ⓜ️ user init", i)
            }
        }
        
        for i in 1000..<1010 {
            print("MAIN Thread!!", i)
        }
        
    }
    
    
    var inactiveQueue: DispatchQueue!
    func concurrentQueues() {
        let q1 = DispatchQueue(label: "com.test.serialQueue", qos: .utility, attributes: [.initiallyInactive, .concurrent])
        inactiveQueue = q1
        
        
        print("Concurrent")
        q1.async {
            for i in 0..<10{
                print("RED", i)
            }
        }
        
        q1.async {
            for i in 0..<10{
                print("Ⓜ️", i)
            }
        }
        
        q1.async {
            for i in 1000..<1010 {
                print("BLACK", i)
            }
        }
        
    }
    
    
    func queueWithDelay() {
        let delayedQ = DispatchQueue(label: "com.test.delay", qos: .userInitiated)
        print(Date())
        let additional: DispatchTimeInterval = .seconds(2)
        
        delayedQ.asyncAfter(deadline: .now() + additional){
            print(Date())
        }
    }
    
    func globalQueues(){
        let gq = DispatchQueue.global()
        
        gq.async {
            for i in 0..<10{
                print("RED", i)
            }
            DispatchQueue.main.async {
                print("MAIN")
            }
        }
    }
    
    
    func fetchImage() {
        let url:URL! = URL(string: "http://www.appcoda.com/wp-content/uploads/2015/12/blog-logo-dark-400.png")
        
        (URLSession(configuration: .default).dataTask(with: url){
            (image, response, error) in
            if let data = image{
                print("got image")
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                }
                
            }
        }).resume()
    }
    
    
    func useWorkItem() {
        var val = 10
        let workItem = DispatchWorkItem{
            print("I am a work item")
            val += 5
        }
        
        DispatchQueue.global().async(execute: workItem)
        workItem.notify(queue: DispatchQueue.main){
            print(val)
        }
    }
    
    
    let semaphore = DispatchSemaphore(value: 1)
    func asyncPrint(queue: DispatchQueue, symbol: String){
        queue.async {
            print("\(symbol) is waiting")
            self.semaphore.wait() //requesting resource
            
            for i in 0..<10{
                print(symbol, i)
            }
            
            print("\(symbol) signal")
            self.semaphore.signal() //releasing the resource
        }
    }
    
    
    func semaphoreTest(){
        let highPriority = DispatchQueue(label: "com.test.highPriority", qos: .userInitiated)
        let lowPriority = DispatchQueue(label: "com.test.lowPriority", qos: .utility)
        
        asyncPrint(queue: highPriority, symbol: "RED")
        asyncPrint(queue: lowPriority, symbol: "BLUE")
    }
    
    func requestResource(symbol: String, resource: String, with semaphore: DispatchSemaphore){
        print("\(symbol) waiting resource \(resource)")
        semaphore.wait()
    }
    
    
    func asyncPrint2(queue: DispatchQueue,
                     symbol: String,
                     firstResource: String,
                     firstSemaphore: DispatchSemaphore,
                     secondResource: String,
                     secondSemaphore: DispatchSemaphore){
        
        queue.async {
            self.requestResource(symbol: symbol, resource: firstResource, with: firstSemaphore)
            for i in 0...10{
                if i == 5{
                    self.requestResource(symbol: symbol, resource: secondResource, with: secondSemaphore)
                    //deadlock here
                }
                print(symbol, i)
            }
            
            print("\(symbol) releasing resource")
            firstSemaphore.signal()
            secondSemaphore.signal()
        }
        
        
        
    }
    
    func deadlockPossible(){
        let higherPriority = DispatchQueue.global(qos: .userInitiated)
        let lowerPriority = DispatchQueue.global(qos: .utility)
        
        let semaphoreA = DispatchSemaphore(value: 1)
        let semaphoreB = DispatchSemaphore(value: 1)
        
        
        asyncPrint2(queue: higherPriority, symbol: "🔴", firstResource: "A", firstSemaphore: semaphoreA, secondResource: "B", secondSemaphore: semaphoreB)
        asyncPrint2(queue: lowerPriority, symbol: "🔵", firstResource: "B", firstSemaphore: semaphoreB, secondResource: "A", secondSemaphore: semaphoreA)

    }
    
    
}

