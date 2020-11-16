SinOsc s => Gain master => dac;
0.5 => master.gain;
330 => s.freq;
0 => s.gain;

0.9 => float targetGain;
0.0 => float gainPosition;
0.005 => float gainInc;

fun void fadeIn()
{
    while( gainPosition <= targetGain )
    {
        gainPosition + gainInc => gainPosition;
        gainPosition => s.gain;
        <<< gainPosition >>>;
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
        1::ms => now;
    }
}
    

spork ~ fadeIn();

0 => int i;
while( true )
{
    <<< i >>>;
    i++;
    if( i==60 )
    {
        fadeOut();
        <<< gainPosition >>>;
    }
        
    1::second => now;
}