// John Eagle
// 8/30/18
// for still life: North Puyallup River Bridge

// do i need to ping oscDistance.py or can I modify to send itself every .25 seconds?

// osc
OscIn in;
OscMsg msg;
10001 => in.port;
in.listenAll();

// sound network
SinOsc s => dac;

// because of distortion
dac.gain(0.5);

// initialize volume
0 => s.gain;

// GLOBAL VARIABLES

// flute values
// frequency array
[129.333, 0.0] @=> float freqs[];
// amplitude array
[0.8, 0.0] @=> float amps[];
// timing array
[30, 60] @=> int times[];

// time variables
0 => int second_i; // current second
90 => int end; // when to stop loop

0 => int freq_i; // freq array index
0 => int soundOn; // switch for sound (0 or 1)
30.0 => float thresh; // distance threshold (lower than values trigger sound)

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
    <<< "end" >>>;
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
            if ( msg.getFloat(0) < thresh )
            {
                <<< "sound on!" >>>;
                1 => soundOn;
            }
            else
            {
                0 => soundOn;
            }
        }
    }
    <<< "Time:", second_i, "Index:", freq_i, "Sound on: ", soundOn >>>;
    
    // checks for timing interval to update s
    if( times[freq_i] == second_i ) // only gets triggered at each timing interval
    {
        freqs[freq_i] => s.freq;
        if( freq_i < times.cap()-1 )
        {
            freq_i++;
        }
    }
    // checks for soundOn to update amp, checks every loop
    if( soundOn==1 )
    {
        amps[freq_i-1] => targetGain;
        spork ~ fadeIn();
        <<< "fade in" >>>;
        //amps[freq_i-1] => s.gain;
    }
    else
    {
        0.0 => targetGain;
        spork ~ fadeOut();
        <<< "fade out" >>>;

        //0 => s.gain;
    }
    
    // now advance time
    second_i++;
    1::second => now;
}