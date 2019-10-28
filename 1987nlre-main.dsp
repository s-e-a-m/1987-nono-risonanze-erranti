import("stdfaust.lib");

envelop = abs : max ~ -(1.0/ma.SR) : max(ba.db2linear(-70)) : ba.linear2db;
vmeter(x) = attach(x, envelop(x) : vbargraph("[03][unit:dB]", -70, +5));
hmeter(x) = attach(x, envelop(x) : hbargraph("[03][unit:dB]", -70, +5));

h1ramp = os.lf_sawpos(1.0/(hslider("[01] h1 time", 3.0, -23.0, 23.0, 0.01)));
h2ramp = os.lf_sawpos(1.0/(hslider("[01] h2 time", 3.0, -23.0, 23.0, 0.01)));
h3ramp = os.lf_sawpos(1.0/(hslider("[01] h3 time", 3.0, -23.0, 23.0, 0.01)));

h1dist = hslider("[02] h1 distance", 1, 0, 1, 0.01);
h2dist = hslider("[02] h2 distance", 1, 0, 1, 0.01);
h3dist = hslider("[02] h3 distance", 1, 0, 1, 0.01);

//gain = vslider("[1]", 0, -70, +0, 0.1) : ba.db2linear : si.smoo;

h1(v) = vgroup("Ch %v", hmeter);
h2(v) = vgroup("Ch %v", hmeter);
h3(v) = vgroup("Ch %v", hmeter);

h1meters = vgroup("h1 meters", par(i, 4, h1(i)));
h2meters = vgroup("h2 meters", par(i, 4, h2(i)));
h3meters = vgroup("h3 meters", par(i, 4, h3(i)));

hal1 = vgroup("h1", sp.spat(4, h1ramp, h1dist) : h1meters);
hal2 = vgroup("h2", sp.spat(4, h2ramp, h2dist) : h2meters);
hal3 = vgroup("h3", sp.spat(4, h3ramp, h3dist) : h3meters);

process = si.bus(3) : hgroup("", hal1, hal2, hal3) :> si.bus(4);
