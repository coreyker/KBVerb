// faust -a supercollider.cpp KBVerb.dsp -o KBVerb.cpp
// g++ -O3 -DNO_LIBSNDFILE -DSC_DARWIN -DSC_FAUST_PREFIX="\"\"" -bundle -I./include -I/Users/corey/Development/supercollider/include/{plugin_interface,common,server} -I/usr/local/lib/faust/ -Dmydsp=KBVERB -o KBVerb.scx KBVerb.cpp

declare name "KBVerb";
declare author "Corey Kereliuk";
declare copyright "Corey Kereliuk";
declare version "0.0";
declare license "MIT";

import("math.lib"); 
import("signal.lib");
import("delay.lib");
//os = library("miscoscillator.lib"); // for testing

primes = ffunction(int primes (int),<primes.h>,"primes");
fb = hslider("feedback",0.5,0.0,1.0,0.01):smooth(0.99);

allpass(N,n,g) = (+ <: (delay(N, n), *(g))) ~ *(-g) : mem, _: +;
section((n1, n2)) = allpass(2048, n1, 0.7) : allpass(2048, n2, 0.7) : delay(4096, int(0.75*(n1+n2)));

allpass_chain(((n1, n2), ns), x) = _ : section((n1, n2)) <: R(x, ns), _
with {
	R(x, ((n1, n2), ns)) = _,x : + : section((n1, n2)) <: R(x, ns), _;
	R(x, (n1, n2)) = _,x : + : section((n1, n2));
};

procMono(feedfwd_delays, feedback_delays, feedback_gain, x) = x : (+ : allpass_chain(feedfwd_delays, x)) ~ (_,x : + : section(feedback_delays) : *(feedback_gain)) :> _;

process = bus(2) : mix(PI/2) : *(0.5), *(0.5) : procLeft, procRight : bus(2)
with {	 

	mix(theta) = bus(2) <: (*(c), *(-s), *(s), *(c)) : (+,+) : bus(2)
	with {
		c = cos(theta);
		s = sin(theta);
	};

	ind_left(i) = 100 + 10*pow(2,i);
	feedfwd_delays_left = par(i, 5, (primes(ind_left(i)), primes(ind_left(i)+1)));
	feedback_delays_left = (primes(100), primes(101));
	procLeft = procMono(feedfwd_delays_left, feedback_delays_left, fb);

	ind_right(i) = 100 + 11*pow(2,i);
	feedfwd_delays_right = par(i, 4, (primes(ind_right(i)), primes(ind_right(i)+1)));
	feedback_delays_right = (primes(97), primes(99));
	procRight = procMono(feedfwd_delays_right, feedback_delays_right, fb);
};

// impulse (test)
// process = os.lf_imptrain(0.25) <: procLeft, procRight
// with {	 

// 	ind_left(i) = 100 + 10*pow(2,i);
// 	feedfwd_delays_left = par(i, 5, (primes(ind_left(i)), primes(ind_left(i)+1)));
// 	feedback_delays_left = (primes(100), primes(101));
// 	procLeft = procMono(feedfwd_delays_left, feedback_delays_left, fb);

// 	ind_right(i) = 100 + 11*pow(2,i);
// 	feedfwd_delays_right = par(i, 4, (primes(ind_right(i)), primes(ind_right(i)+1)));
// 	feedback_delays_right = (primes(97), primes(99));
// 	procRight = procMono(feedfwd_delays_right, feedback_delays_right, fb);
// };