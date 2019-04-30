import("stdfaust.lib");

ramp = os.lf_sawpos(1/(hslider("time", 0.0, 0, 23, 0.01)));
distance = hslider("distance", 0.5, 0, 1, 0.01);

process = hgroup("Halaphon", sp.spat(4, ramp, distance));
