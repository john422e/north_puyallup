// sound chain
SinOsc sines[6];
Noise noiseVariations[8];
ResonZ filters[8];
Gain master => dac;
Gain noiseMaster => master;
.25 => master.gain;
// sine tones
[700.0, 985.0, 2959.96, 200.0, 2793.83, 2489.02] @=> float freqs[];
[80.0, 120.0, 140.0, 160.0, 3000.0, 5020.0, 12040.0, 18060.0] @=> float centerFreqs[];
for( 0 => int freq_index; freq_index < freqs.cap(); freq_index++ )
{
    // use array to set all sinOsc freq values
    freqs[freq_index] => sines[freq_index].freq;
    // initialize all gain values to 0
    0.0 => sines[freq_index].gain;
    // chuck to master
    sines[freq_index] => master;
}
// noise oscs
for( 0 => int noise_index; noise_index < noiseVariations.cap(); noise_index++ )
{
    // initialize all gain values to 0
    0.0 => noiseVariations[noise_index].gain;
    // chuck noise to filter
    noiseVariations[noise_index] => filters[noise_index];
    // chuck filter to master
    filters[noise_index] => noiseMaster;
    // set filter center freq and Q
    centerFreqs[noise_index] => filters[noise_index].freq;
    0.9 => filters[noise_index].Q;
    
}
    
// MIDI in setup
MidiIn min;
MidiMsg msg;

// MIDI Port
0 => int port;

// open the port
if ( !min.open(port) )
{
    <<< "Error: MIDI port did not open on port: ", port >>>;
    me.exit();
}

// global variables
int controller, sineKnob, value;
float oneAmp;
Event controlChange;

// loop
while( true )
{
    // wait for MIDI message
    min => now;
    
    while ( min.recv(msg) )
    {
        // print out all the data
        <<< msg.data1, msg.data2, msg.data3 >>>;
        
        // parse messages
        msg.data2 => controller;
        msg.data3 => value;
        
        // noise osc control
        if (controller < 8)
        {
            (value/127.0) * (value/127.0) * (value/127.0) => float thisGain;
            thisGain => noiseVariations[controller].gain;
            <<< thisGain >>>;
        }
        
        // sine osc control
        if (controller >= 16 && controller <= 21)
        {
            controller - 16 => sineKnob;
            (value/127.0) * (value/127.0) * (value/127.0) => float thisGain;
            thisGain => sines[sineKnob].gain;
            <<< thisGain >>>;
        }
        else
        {
            <<< controller >>>;
        }
    }
}