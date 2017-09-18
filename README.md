# KinectRecord
Matlab GUI for recording synchoronized color, depth, and skeleton from Kinect V2
It is manly written to record a database for sign language recognition.
# Requirement
The Kinect V2 Toolbox for Matlab availabe at
https://github.com/jrterven/Kin2
download and compile.

The matleap https://github.com/jeffsp/matleap download and build.
# Usage 
Start Kinect button to start/stop Kinect.

Use Browse button to select a folder to save the recorded files to. Default is the cuurent folder.

Make sure that the skeleton is shown befor pressing the Start Recording button.

Use Stop Recording button to stop and save the recorded sample.

The color is saved to .mp4, the depth to _d.mat the skeleton to _s.mat, the leap motion readings to _lcm.mat
