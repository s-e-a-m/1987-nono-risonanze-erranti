import("stdfaust.lib");

// --------------------------------------------------FIREFICE 800 INPUT SELECTOR

insel = ba.selectn(18,channel) : _
  with{
    channel = nentry("[0] Input Channel Selector
                    [style:menu{'Analog IN 1':0;
                    'Analog IN 2':1;
                    'Analog IN 3':2;
                    'Analog IN 4':3;
                    'Analog IN 5':4;
                    'Analog IN 6':5;
                    'Analog IN 7':6;
                    'Analog IN 8':7;
                    'Analog IN 9':8;
                    'Analog IN 10':9;
                    'ADAT IN 1':10;
                    'ADAT IN 2':11;
                    'ADAT IN 3':12;
                    'ADAT IN 4':13;
                    'ADAT IN 5':14;
                    'ADAT IN 6':15;
                    'ADAT IN 7':16;
                    'ADAT IN 8':17}]", 0, 0, 18, 1) : int;
};

// ----------------------------------------------------------------- PRE SECTION

presec = pre_group(ba.bypass1(lop,fi.lowpass(HO,HC)) : ba.bypass1(hip,fi.highpass(LO,LC)) : gain : rpol)
with{
	pre_group(x) = hgroup("[1] PRE SECTION ",x);

  lop = 1 - checkbox("[03] HC");

  HO = 2;//nentry("order", 2, 1, 8, 1);
  HC = hslider ("[04] High Cut [unit:Hz] [style:knob] [scale:exp]", 8000, 20, 20000, 0.1) : si.smoo;

  hip = 1 - checkbox("[01] LC");

  LO = 2;//nentry("order", 2, 1, 8, 1);
  LC = hslider ("[02] Low Cut [unit:Hz] [style:knob] [scale:exp]", 500, 20, 20000, 0.1) : si.smoo;

    rpol = *(1 - (checkbox("[05] Reverse Phase")*(2)));

    gain = *(hslider("[06] Gain [unit:dB] [style:knob]", 0, -24, +24, 0.1) : ba.db2linear : si.smoo);

};

// ------------------------------------------------------------------ EQ SECTION

peq = fi.low_shelf(LL,FL) : fi.peak_eq(LP1,FP1,BP1) : fi.peak_eq(LP2,FP2,BP2) : fi.high_shelf(LH,FH)
with{
	eq_group(x) = vgroup("[2] PARAMETRIC EQ",x);

	hs_group(x) = eq_group(hgroup("[1] High Shelf [tooltip: Provides a boost or cut above some frequency]", x));
	LH = hs_group(vslider("[0] Gain [unit:dB] [style:knob] [tooltip: Amount of boost or cut in decibels]", 0,-36,36,.1) : si.smoo);
	FH = hs_group(vslider("[1] Freq [unit:Hz] [style:knob] [tooltip: Transition-frequency from boost (cut) to unity gain]", 8000,100,19999,1) : si.smoo);

	pq1_group(x) = eq_group(hgroup("[2] Band [tooltip: Parametric Equalizer sections]", x));
	LP1 = pq1_group(vslider("[0] Gain 1 [unit:dB] [style:knob] [tooltip: Amount of local boost or cut in decibels]",0,-36,36,0.1) : si.smoo);
	FP1 = pq1_group(vslider("[1] Freq 1 [unit:Hz] [style:knob] [tooltip: Peak Frequency]", 2500,0,20000,1)) : si.smoo;
	Q1  = pq1_group(vslider("[2] Q 1 [style:knob] [scale:log] [tooltip: Quality factor (Q) of the peak = center-frequency/bandwidth]",40,1,1000,0.1) : si.smoo);

	BP1 = FP1/Q1;

  pq2_group(x) = eq_group(hgroup("[3] Band [tooltip: Parametric Equalizer sections]", x));
	LP2 = pq2_group(vslider("[0] Gain 2 [unit:dB] [style:knob] [tooltip: Amount of local boost or cut in decibels]", 0,-36,36,0.1));
	FP2 = pq2_group(vslider("[1] Freq 2 [unit:Hz] [style:knob] [tooltip: Peak Frequency]", 500,0,20000,1)) : si.smoo;
	Q2  = pq2_group(vslider("[2] Q 2 [style:knob] [scale:log] [tooltip: Quality factor (Q) of the peak = center-frequency/bandwidth]", 40,1,1000,0.1) : si.smoo);

	BP2 = FP2/Q2;

	ls_group(x) = eq_group(hgroup("[4] Low Shelf [tooltip: Provides a boost or cut below some frequency",x));
	LL = ls_group(vslider("[0] Gain [unit:dB] [style:knob] [tooltip: Amount of boost or cut in decibels]", 0,-36,36,0.1) : si.smoo);
	FL = ls_group(vslider("[1] Freq [unit:Hz] [style:knob] [tooltip: Transition-frequency from boost (cut) to unity gain]", 200,20,5000,1): si.smoo);
};

// ----------------------------------------------------------------------- FADER

vmeter(x)		= attach(x, envelop(x) : vbargraph("[5][unit:dB]", -70, +5));
hmeter(x)		= attach(x, envelop(x) : hbargraph("[5][unit:dB]", -70, +5));

envelop = abs : max ~ -(1.0/ma.SR) : max(ba.db2linear(-70)) : ba.linear2db;

fader	= *(hgroup("[10]", vslider("[1]", 0, -96, +12, 0.1)) : ba.db2linear : si.smoo);

// ------------------------------------------------------------------------ MUTE

contralto = vgroup("[01] CONTRALTO",
           vgroup("", insel : hmeter) : presec : peq <:
           hgroup("[90] CONTRALTO",
           fader : met_group(vmeter)))
             with{
    pf_group(x) = vgroup("[90]", x);
    met_group(x) = hgroup("[97]",x);
    w = v+(01);
  };

flauti = vgroup("[02] FLAUTI",
           vgroup("", insel : hmeter) : presec : peq <:
           hgroup("[90] FLAUTI",
           fader : met_group(vmeter)))
             with{
    pf_group(x) = vgroup("[90]", x);
    met_group(x) = hgroup("[97]",x);
    w = v+(01);
  };

tuba = vgroup("[03] TUBA",
           vgroup("", insel : hmeter) : presec : peq <:
           hgroup("[90] TUBA",
           fader : met_group(vmeter)))
             with{
    pf_group(x) = vgroup("[90]", x);
    met_group(x) = hgroup("[97]",x);
    w = v+(01);

};

csarde = vgroup("[04] CAMPANE SARDE",
           vgroup("", insel : hmeter) : presec : peq <:
           hgroup("[90] CAMPANE SARDE",
           fader : met_group(vmeter)))
             with{
    pf_group(x) = vgroup("[90]", x);
    met_group(x) = hgroup("[97]",x);
    w = v+(01);

};

    bongos = vgroup("[05] BONGOS",
           vgroup("", insel : hmeter) : presec : peq <:
           hgroup("[90] BONGOS",
           fader : met_group(vmeter)))
             with{
    pf_group(x) = vgroup("[90]", x);
    met_group(x) = hgroup("[97]",x);
    w = v+(01);

};

crotali = vgroup("[06] CROTALI",
           vgroup("", insel : hmeter) : presec : peq <:
           hgroup("[90] CROTALI",
           fader : met_group(vmeter)))
             with{
    pf_group(x) = vgroup("[90]", x);
    met_group(x) = hgroup("[97]",x);
    w = v+(01);

  };

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

instruments = tgroup("INPUTS", si.bus(18) <: hgroup("[01] INPUTS", contralto, flauti, tuba, csarde, bongos, crotali));// : hgroup("[02]", hal1, hal2, hal3, !, !, !) :> si.bus(4);



process = instruments ;
