
// initialize
0 => int second_i;
0 => int index;

// lists
["a", "b", "c", "d"] @=> string sections[];
[0, 3, 6, 9] @=> int timings[];

// input argument is the rehearsal number and index
me.arg(0) => string ui;
Std.atoi(ui) => index;

// now use that index to set second_i
timings[index] => second_i;


while( second_i < 15 )
{
    <<< second_i >>>;
    if( second_i == timings[index] )
    {
        <<< "INDEX:", sections[index] >>>;
        index++;
    }
    1::second => now;
    second_i++;
}