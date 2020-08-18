/*******************************************************************************
"Solarium" -- John Holmes
SAE Capstone Project -- August 2020
*******************************************************************************/

//Boot the Sever//
s.boot;

// Evaluate the SynthDefs //
(
    // kick //
    SynthDef(\kick,{
	    arg out=0, freq=41.2, amp=1;
	    var beater, boom, env;

	    env = EnvGen.kr(Env.perc(0, 0.05), doneAction: 2);

	    beater = WhiteNoise.ar;
	    beater = HPF.ar(beater, 500);
        beater = LPF.ar(beater, XLine.ar(3000, 500, 0.01));
	    beater = beater * Env.perc.ar * 0.55;

	    boom = FSinOsc.ar(freq);

		Out.ar(out, Pan2.ar(Mix([boom,beater]), 0, env * amp));
    }).add;

    // snare //
    SynthDef(\snare, {
	    arg out=0, pan=0.3, amp=1;
	    var snap, body, env;

	    env = EnvGen.kr(Env.perc(0, 0.05), doneAction: 2);

	    snap = WhiteNoise.ar;

		body = FSinOsc.ar(200,mul: 0.75);

		Out.ar(out, Pan2.ar(LPF.ar(Mix([snap, body]), 12000), pan, env * amp));
    }).add;

    // hat //
    SynthDef(\hat, {
	    arg out=0, release=0.05, pan=0.5, amp=1;
		var noise, env;

		noise = WhiteNoise.ar;

		env = EnvGen.kr(Env.perc(0, release), doneAction: 2);

		Out.ar(out, Pan2.ar(noise, pan, env * amp));
	}).add;

    // bass //
    SynthDef(\bass,{
	    arg out=0, freq=329.628, t_gate=1, amp=1, rel=2.5;
	    var osc1, aEnv, fEnv;

	    osc1 = Saw.ar(freq);

	    fEnv = EnvGen.kr(Env.adsr(attackTime: 0.001,
		       decayTime: 0.146,sustainLevel: 0.5,
		       releaseTime: 0.5 ));
	    osc1 = LPF18.ar(in: osc1,freq: 1200 * fEnv,res: 0.35,dist: 0.2);

	    aEnv = EnvGen.kr(Env.adsr(attackTime: 0.0005,
		       decayTime: 0.146,sustainLevel: 0.65,
		       releaseTime: rel),t_gate, doneAction: 2);

	    Out.ar(out,Pan2.ar(osc1,0,aEnv * amp));
    }).add;

    // supersquare adapted from SuperDirt //
SynthDef(\supersquare, {|out, rate=1, decay=0, sustain=1, pan=0, accelerate=0, freq=(60.midicps),
		voice=0.5, semitone=12, resonance=0.2, lfo=1, pitch1=1, amp=1|
		var env = EnvGen.ar(Env.pairs([[0,0],[0.05,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -3), timeScale:sustain, doneAction:2);
		var basefreq = freq* Line.kr(1, 1+accelerate, sustain);
		var basefreq2 = basefreq / (2**(semitone/12));
		var lfof1 = min(basefreq*10*pitch1, 22000);
		var lfof2 = min(lfof1 * (lfo + 1), 22000);
		var sound = (0.7 * Pulse.ar(basefreq, voice)) + (0.3 * Pulse.ar(basefreq2, voice));
		sound = MoogFF.ar(
			sound,
			SinOsc.ar(basefreq/64*rate, 0).range(lfof1,lfof2),
			resonance*4);
		sound = sound.tanh * 2;
		OffsetOut.ar(out, Pan2.ar(sound,pan,env * amp));
	}).add


)

// Evaluate the Patterns //
(
    ~kick1 = Pbind(
	\instrument, \kick,
	\dur, Pseq([1/2,3.5],8), //1 bar repeated 8 times = 8 bars
	\freq, 41.2,
	\amp, 1.2,
    );

     ~kick2 = Pbind(
	\instrument, \kick,
	\dur, Pseq([1/2,3.5],4), //1 bar repeated 4 times = 4 bars
	\freq, 41.2,
	\amp, 1.2,
    );

     ~snare1 = Pbind(
	\instrument, \snare,
	\dur, Pseq([1],32), //1 beat repeated 32 times = 8 bars
	\amp, Pseq([0,1],inf),
    );

    ~snare2 = Pbind(
	\instrument, \snare,
	\dur, Pseq([1],16), //1 beat repeated 16 times = 4 bars
	\amp, Pseq([0,1],inf),
    );

    ~hat1 = Pbind(
	\instrument, \hat,
	\dur, Pseq([1/4,1/4,1/4,1/4], 32), //1 beat repeated 32 times = 8 bars
	\amp, Pwhite(0,0.6,inf),
	\release, Pseq([Pseq([0.05,0.05,0.05,0.05,0.05,0.45,0.05,0.05],1), Pseq([0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.45],2)],inf),
    );

    ~hat2 = Pbind(
	\instrument, \hat,
	\dur, Pseq([1/4,1/4,1/4,1/4], 16), //1 beat repeated 16 times = 4 bars
	\amp, Pwhite(0,0.6,inf),
	\release, Pseq([Pseq([0.05,0.05,0.05,0.05,0.05,0.45,0.05,0.05],1), Pseq([0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.45],2)],inf),
    );

    ~bass1 = Pbind(
	\instrument, \bass,
	\rel, 0.55,
	\midinote, Pseq([Pseq([28],3),Pseq([29,29,\,29],1),Pseq([31],3),Pseq([29],4)],inf),
	\dur, Pseq([Pseq([1/2,(4-0.5-(1.75/8)),1.75/8],1),Pseq([1/2,1.25,1.75,1/2],1)],4), //2 bars repeated 4 times = 8 bars
	\amp, 0.7,
    );

    ~bass2 = Pbind(
	\instrument, \bass,
	\rel, 0.55,
	\midinote, Pseq([Pseq([28],3),Pseq([29,29,\,29],1),Pseq([31],3),Pseq([29],4)],inf),
	\dur, Pseq([Pseq([1/2,(4-0.5-(1.75/8)),1.75/8],1),Pseq([1/2,1.25,1.75,1/2],1)],2), //2 bars repeated 2 times = 4 bars
	\amp, 0.7,
    );

    ~square1 = Pbind(
    \instrument, \supersquare,
	\dur, Pseq([1/2],64), //8 bars
	\amp, 0.08,
	\pan, Pwhite(-0.7,0.7,inf),
	\midinote, Pseq([76,77,78,84,79,84,80,88],inf)
    );

    ~square2 = Pbind(
    \instrument, \supersquare,
	\dur, Pseq([1/2],32), //4 bars
	\amp, 0.08,
	\pan, Pwhite(-0.5,0.5,inf),
	\midinote, Prand([64,65,66,72,67,72,68,76],inf)
    );

    ~square3 = Pbind(
    \instrument, \supersquare,
	\dur, Pseq([1/2],64), //8 bars
	\amp, 0.08,
	\pan, Pwhite(-1,1,inf),
	\midinote, Prand([76,77,78,84,79,84,80,88],inf)
    );

    ~square4 = Pbind(
    \instrument, \supersquare,
	\dur, Pseq([1/2],32), //4 bars
	\amp, 0.07,
	\pan, Pwhite(-1,0.8,inf),
	\midinote, Pxrand([64,65,66,72,67,72,68,76],inf)
    );


    //Song Sections//
~intro1 = Ppar([~kick2,~hat2,~snare2]); //4 bars
~intro2 = Ppar([~kick2,~hat2,~snare2,~bass2]); //4 bars
~chorus1 = Ppar([~kick1,~hat1,~snare1,~bass1,~square1]); //8 bars
~verse1 = Ppar([~kick1,~snare1,Pseq([~square2,~square4])]); //8 bars
~chorus2 = Ppar([~kick1,~hat1,~snare1,~bass1,~square1,~square3]); //8 bars
~bridge = Ppar([~square1,~square2,~square3,~bass1]); //8 bars
~chorus3 = Ppar([~square1,Pseq([~square2,Ppar([~square2,~square4])]),~square3,~kick1,~hat1,~snare1,~bass1]); //8 bars
~outro = Ppar([~kick2,~hat2,~snare2]); //4 bars
)


//Now Play it!//
(
TempoClock.default.tempo = 90/60;

Pseq([
	~intro1,
	~intro2,
	~chorus1,
	~verse1,
	~chorus2,
	~bridge,
	~chorus3,
	~outro
    ]).play;
)

//Clean Up//
s.freeAll;


