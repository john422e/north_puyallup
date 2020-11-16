// John Eagle
// 8/30/18
// for still life: North Puyallup River Bridge

// pi four (guitar)

// osc
OscIn in;
OscMsg msg;
10001 => in.port;
in.listenAll();

// sound network
SinOsc s => dac;

// because of distortion
dac.gain(0.9); // is this too high?

// initialize volume
0 => s.gain;

// GLOBAL VARIABLES

// frequency array
//0.      1.       2.       3.       4.       5.       6.       7.       8.       9.       10.      11.    12.    13.    14.      15.      16.    17.    18.    19.    20.    21.    22.    23.      24.      25.
[291.167, 291.167, 201.167, 129.333, 129.333, 129.333, 201.167, 201.167, 201.167, 201.167, 133.833, 321.0, 321.0, 321.0, 249.667, 249.667, 312.0, 312.0, 312.0, 312.0, 312.0, 312.0, 312.0, 249.667, 187.333, 249.667] @=> float freqs[];
// amplitude array
[0.0,     0.71,    0.73,    0.85,    0.85,    0.0,     0.73,    0.73,    0.73,    0.73,    0.85,    0.7,   0.0,   0.0,   0.72,    0.72,    0.7,   0.7,   0.0,   0.0,   0.0,   0.0,   0.0,   0.72,    0.77,    0.0] @=> float amps[];
// timing array
[0,       30,      90,      135,     165,     195,     225,     240,     255,     285,     315,     345,   390,   405,   450,     465,     480,   510,   525,   555,   570,   600,   615,   630,     660,     690] @=> int times[]; // 26 timing markers

// time variables
0 => int second_i; // current second
0 => int displayMinute => int displaySecond; // for display
720 => int end; // when to stop loop

0 => int index; // freq array index
0 => int soundOn; // switch for sound (0 or 1)
15.0 => float thresh; // distance threshold (lower than values trigger sound)

// adjust starting position if command line argument present
Std.atoi(me.arg(0)) => index; // user provides section number (same as index value)
times[index] => second_i; // sets second_i from index
<<< "start at index:", index, "second:", second_i >>>;

// gain variables
0.0 => float targetGain;
0.0 => float gainPosition;
0.005 => float gainInc;

// functions
fun void fadeIn()
{
    while( gainPosition <= targetGain )
    {
        gainPosition + gainInc => gainPosition;
        gainPosition => s.gain;
        //<<< gainPosition >>>;
        10::ms => now;
    }
    //<<< "end" >>>;
}

fun void fadeOut()
{
    while( gainPosition > 0.0 )
    {
        gainPosition - gainInc => gainPosition;
        gainPosition => s.gain;
        10::ms => now;
    }
}


// MAIN PROGRAM

// infinite loop
while( second_i <= end )
{
    // check for osc messages
    //in => now;
    while( in.recv(msg)) {
        // ultrasonic sensor distance
        if( msg.address == "/distance" )
        {
            <<< "/distance", msg.getFloat(0) >>>;
            // turn on sound if value below thresh
            if ( msg.getFloat(0) < thresh && msg.getFloat(0) > 0.0)
            {
                //<<< "sound on!" >>>;
                1 => soundOn;
            }
            else
            {
                0 => soundOn;
            }
        }
    }
    second_i / 60 => displayMinute;
    second_i % 60 => displaySecond;
    <<< "Time:", displayMinute, displaySecond, "Index:", index, "Sound on: ", soundOn >>>;
   
    // checks for timing interval to update s
    if( times[index] == second_i ) // only gets triggered at each timing interval
    {
        freqs[index] => s.freq;
        <<< "Time: ", times[index], "Freq:", freqs[index], "Target Gain:", amps[index] >>>;
        if( index < times.cap()-1 )
        {
            index++;
        }
    }
    // checks for soundOn to update amp, checks every loop
    if( soundOn==1 )
    {
        amps[index-1] => targetGain;
        spork ~ fadeIn();
        //<<< "fade in" >>>;
        //amps[index-1] => s.gain;
    }
    else
    {
        0.0 => targetGain;
        spork ~ fadeOut();
        //<<< "fade out" >>>;

        //0 => s.gain;
    }
    
    // now advance time
    second_i++;
    1::second => now;
}