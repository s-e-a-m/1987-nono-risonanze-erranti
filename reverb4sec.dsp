import("stdfaust.lib");

// <1,2,4,...,N signals> <:
// fdnrev0(MAXDELAY,delays,BBSO,freqs,durs,loopgainmax,nonl) :>
// <1,2,4,...,N signals>
// ```
//
// Where:
//
// * `N`: 2, 4, 8, ...  (power of 2)
// * `MAXDELAY`: power of 2 at least as large as longest delay-line length
// * `delays`: N delay lines, N a power of 2, lengths perferably coprime
// * `BBSO`: odd positive integer = order of bandsplit desired at freqs
// * `freqs`: NB-1 crossover frequencies separating desired frequency bands
// * `durs`: NB decay times (t60) desired for the various bands
// * `loopgainmax`: scalar gain between 0 and 1 used to "squelch" the reverb
// * `nonl`: nonlinearity (0 to 0.999..., 0 being linear)
//
// #### Reference

//process = re.satrev;


//-------------------------`(dm.)fdnrev0_demo`---------------------------
// A reverb application using `fdnrev0`.
//
// #### Usage
//
// ```
// _,_ : fdnrev0_demo(N,NB,BBSO) : _,_
// ```
//
// Where:
//
// * `n`: Feedback Delay Network (FDN) order / number of delay lines used =
//	order of feedback matrix / 2, 4, 8, or 16 [extend primes array below for
//	32, 64, ...]
// * `nb`: Number of frequency bands / Number of (nearly) independent T60 controls
//	/ Integer 3 or greater
// * `bbso` = Butterworth band-split order / order of lowpass/highpass bandsplit
//	used at each crossover freq / odd positive integer
//------------------------------------------------------------
gs_fdnrev(N,NB,BBSO) = _ <: re.fdnrev0(MAXDELAY,delays,BBSO,freqs,durs,loopgainmax,nonl)
	  :> *(gain),*(gain)
with{
	MAXDELAY = 8192; // sync w delays and prime_power_delays above
	defdurs = (5.0,4.0,3.0,2.0,1.0); // NB default durations (sec)
	deffreqs = (500,1000,2500,5000); // NB-1 default crossover frequencies (Hz)
	deflens = (23.0,42.0); // 2 default min and max path lengths

	fdn_group(x)  = vgroup("FEEDBACK DELAY NETWORK (FDN) REVERBERATOR, ORDER 16
	[tooltip: See Faust's reverbs.lib for documentation and references]", x);

	freq_group(x)  = fdn_group(hgroup("[1] Band Crossover Frequencies", x));
	t60_group(x)  = fdn_group(hgroup("[2] Band Decay Times (T60)", x));
	path_group(x)  = fdn_group(vgroup("[3] Room Dimensions", x));
	revin_group(x)	= fdn_group(hgroup("[4] Input Controls", x));
	nonl_group(x) = revin_group(vgroup("[4] Nonlinearity",x));
	quench_group(x) = revin_group(vgroup("[3] Reverb State",x));

	nonl = nonl_group(hslider("[style:knob] [tooltip: nonlinear mode coupling]",
	    0, -0.999, 0.999, 0.001));
	loopgainmax = 1.0-0.5*quench_group(button("[1] Clear
		[tooltip: Hold down 'Quench' to clear the reverberator]"));

	pathmin = path_group(hslider("[1] min acoustic ray length [unit:m] [scale:log]
	[tooltip: This length (in meters) determines the shortest delay-line used in the FDN
	reverberator. Think of it as the shortest wall-to-wall separation in the room.]",
	46, 0.1, 63, 0.1));
	pathmax = path_group(hslider("[2] max acoustic ray length [unit:m] [scale:log]
		[tooltip: This length (in meters) determines the longest delay-line used in the
		FDN reverberator. Think of it as the largest wall-to-wall separation in the room.]",
	63, 0.1, 63, 0.1));

	durvals(i) = t60_group(nentry("[%i] %i [unit:s] [tooltip: T60 is the 60dB
		decay-time in seconds. For concert halls, an overall reverberation time (T60) near
		1.9 seconds is typical [Beranek 2004]. Here we may set T60 independently in each
		frequency band.	 In real rooms, higher frequency bands generally decay faster due
		to absorption and scattering.]",ba.take(i+1,defdurs), 0.1, 100, 0.1));
	durs = par(i,NB,durvals(NB-1-i));

	freqvals(i) = freq_group(nentry("[%i] Band %i upper edge in Hz [unit:Hz]
	[tooltip: Each delay-line signal is split into frequency-bands for separate
	decay-time control in each band]",ba.take(i+1,deffreqs), 100, 10000, 1));
	freqs = par(i,NB-1,freqvals(i));

	delays = de.prime_power_delays(N,pathmin,pathmax);

	gain = hslider("[3] Output Level (dB) [unit:dB][tooltip: Output scale factor]",
		-40, -70, 20, 0.1) : ba.db2linear;
	// (can cause infinite loop:) with { db2linear(x) = pow(10, x/20.0); };
};

process =  _ <: gs_fdnrev(16,5,3) : _,_;
