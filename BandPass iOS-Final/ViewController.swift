//
//  ViewController.swift
//  BandPass iOS-Final
//
//  Created by Andrew Cloud on 3/16/16.
//  Copyright © 2016 Andrew Cloud. All rights reserved.

import UIKit
import AVFoundation

class ViewController: UIViewController
{
    @IBOutlet var LabelFQ: UILabel!             // Label to display the Frequency
    
    @IBOutlet var BandLabel: UILabel!           // Label to display the Bandwidth
    
    @IBOutlet var LabelGain: UILabel!           // Label to display the Gain
    
    @IBOutlet weak var bandSlider: UISlider!    // Used to update Bandwidth Slider
    
    @IBOutlet weak var fqSlider: UISlider!      // Used to update Frequency Slider
    
    var engine:AVAudioEngine!
    
    var EQNode:AVAudioUnitEQ!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Start the Audio Engine
        initAudioEngine()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    func initAudioEngine ()
    {
        engine = AVAudioEngine()
        
        EQNode = AVAudioUnitEQ(numberOfBands: 2)
        
        // Set the Global Gain (Going to be used to alter gain with UISlider)
        EQNode.globalGain = 15
        // Really only notice globalGain from -24 to 24 dB
        
        // Attach the EQ node to the engine to do work
        engine.attachNode(EQNode)
        
        // Set application defaults for the Bandpass Filter
        let filterParams = EQNode.bands[0] as AVAudioUnitEQFilterParameters
        
        filterParams.filterType = .BandPass     // Band pass filter
        
        // 20 Hz to nyquist
        filterParams.frequency = 5000.0
        
        //The value range of values is 0.05 to 5.0 octaves
        filterParams.bandwidth = 2.0
        
        filterParams.bypass = false
        
        // in db -96 db through 24 dB
        filterParams.gain = 15.0
        // Only setting to build successfully
        
        let format = engine.inputNode!.inputFormatForBus(0)
        
        // Connect the Band Pass Filter to the main mixer's input (goes to the output)
        engine.connect(EQNode, to:engine.mainMixerNode, format:format)
        
        // Start the enging
        startEngine()
    }
    
    func startEngine()
    {
        // Would call engine.startAndReturnError() but it does not recognize the function
        // manually try starting the engine and catch/display any errors instead
        if !engine.running {
            do {
                try engine.start()
            } catch let error as NSError {
                fatalError("couldn't start engine, \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func gain(sender: UISlider)
    {
        
        // Gain works alongside the Engine (Use EQ stops the engine and any gain slider
        // Changes do not alter Bypassed gain
        let val = sender.value
        
        // Overwrite the Gain value with info from the UISlider
        //let filterParams = EQNode.bands[0] as AVAudioUnitEQFilterParameters
        //filterParams.gain = val
         EQNode.globalGain = val
        
        // Display the value in string format on Gain Label
        let value = String(format:"%.2f dB", val)   // Convert the .2 float into a string
        self.LabelGain.text = value                 // Set the new string as the text for the label
    }
    
    @IBAction func bandwidth(sender: UISlider)
    {
        let val = sender.value
        
        // Overwrite the bandwith value with info from UISlider
        let filterParams = EQNode.bands[0] as AVAudioUnitEQFilterParameters
        filterParams.bandwidth = val
        
        // Display value in string format on Bandwidth Label
        let value = String(format:"%.2f oct", val)
        self.BandLabel.text = value
    }
    
    @IBAction func fq(sender: UISlider)
    {
        let val = sender.value
        
        // Overwrite the frequency paraments with info from UISlider
        let filterParams = EQNode.bands[0] as AVAudioUnitEQFilterParameters
        filterParams.frequency = val
        
        // Display value in string format on Frequency Label
        let value = String(format:"%.1f Hz", val)
        self.LabelFQ.text = value
    }
    
    // Bypass the EQ Node
    @IBAction func UseEQ(sender: UISwitch) {
       
        // If the engine is already doing work
        // Stop the engine to rewrite the connections
        if engine.running {
            engine.stop()
        }
        
        let format = engine.inputNode!.inputFormatForBus(0)     // Set the format for the input bus
        
        // If the Sender is off (Unbypassed)
        if !sender.on {
            print("EQ Engaged")
            // Reconnect the Input to the EQNode
            engine.connect(engine.inputNode!, to: EQNode, format: format)
            // Reconnect the EQ to the mainMixerNode (Output)
            engine.connect(EQNode, to: engine.mainMixerNode, format: format)
            
        } else {
            print("EQ Disengaged")
            // Bypass the EQ Node and send the Input straight to the mainMixerNode (Output)
            engine.connect(engine.inputNode!, to: engine.mainMixerNode, format: format)
        }
        // With new connections made, start the engine
        startEngine()
    }
    
    @IBAction func Preset3(sender: UIButton)
    {
        // Preset 3 is intense bandpass (for clear filtering effect)
        // Bandwith Preset
        let filterParams1 = EQNode.bands[0] as AVAudioUnitEQFilterParameters
        filterParams1.bandwidth = 0.50
        
        // Display value in string format on Bandwidth Label
        let value1 = String(format:"%.2f oct", 0.50)            // Update Bandwidth Label
        self.BandLabel.text = value1
        
        // Center Frequency Preset
        let filterParams2 = EQNode.bands[0] as AVAudioUnitEQFilterParameters
        filterParams2.frequency = 750.00
        
        // Display value in string format on Frequency Label
        let value2 = String(format:"%.1f Hz", 750.00)          // Update Frequency Label
        self.LabelFQ.text = value2
        
        // Update Center Frequency Slider
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations:
            {
                self.fqSlider.setValue(750.0, animated:true)}, completion: nil)
        // Update Bandwidth Slider with animation
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations:
            {
                self.bandSlider.setValue(0.50, animated:true)}, completion: nil)
    }
    @IBAction func Preset2(sender: UIButton)
    {
        // Preset 2 is Almost full Bandwidth (Pretty much Bypassed)
        
        // Bandwith Preset
        let filterParams1 = EQNode.bands[0] as AVAudioUnitEQFilterParameters
        filterParams1.bandwidth = 4.50
        
        // Display value in string format on Bandwidth Label
        let value1 = String(format:"%.2f oct", 4.50)                // Update Bandwidth Label
        self.BandLabel.text = value1
        
        // Center Frequency Preset
        let filterParams2 = EQNode.bands[0] as AVAudioUnitEQFilterParameters
        filterParams2.frequency = 15000.00
        
        // Display value in string format on Frequency Label
        let value2 = String(format:"%.1f Hz", 15000.00)             // Update Frequency Label
        self.LabelFQ.text = value2
        
        // Update Center Frequency Slider
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations:
            {
                self.fqSlider.setValue(15000.0, animated:true)}, completion: nil)
        // Update Bandwidth Slider with animation
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations:
            {
                self.bandSlider.setValue(4.50, animated:true)}, completion: nil)
    }
    
    @IBAction func Preset1(sender: UIButton)
    {
        // Preset 1 is the application factory preset settings
        
        // Bandwith Preset
        let filterParams1 = EQNode.bands[0] as AVAudioUnitEQFilterParameters
        filterParams1.bandwidth = 2.00
        
        // Display value in string format on Bandwidth Label
        let value1 = String(format:"%.2f oct", 2.00)                // Update Bandwidth Label
        self.BandLabel.text = value1
        
        // Center Frequency Preset
        let filterParams2 = EQNode.bands[0] as AVAudioUnitEQFilterParameters
        filterParams2.frequency = 5000.00
        
        // Display value in string format on Frequency Label
        let value2 = String(format:"%.1f Hz", 5000.00)              // Update Frequency Label
        self.LabelFQ.text = value2
        
        // Update FQ Slider with animation
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations:
            {
                self.fqSlider.setValue(5000.00, animated:true)}, completion: nil)
        
        // Update Bandwidth Slider with animation
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations:
            {
                self.bandSlider.setValue(2.00, animated:true)}, completion: nil)
    }
    
}



