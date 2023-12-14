declare name "KBVerb";
declare author "Corey Kereliuk";
declare copyright "Corey Kereliuk";
declare version "0.0";
declare license "MIT";

import("stdfaust.lib");

// Prime Numbers List
primes(n) = ba.take(int(n), (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73,
79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163,
167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251,
257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349,
353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443,
449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541, 547, 557,
563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647,
653, 659, 661, 673, 677, 683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757,
761, 769, 773, 787, 797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859, 863,
877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 947, 953, 967, 971, 977, 983,
991, 997, 1009, 1013, 1019, 1021, 1031, 1033, 1039, 1049, 1051, 1061, 1063,
1069, 1087, 1091, 1093, 1097, 1103, 1109, 1117, 1123, 1129, 1151, 1153, 1163,
1171, 1181, 1187, 1193, 1201, 1213, 1217, 1223, 1229, 1231, 1237, 1249, 1259,
1277, 1279, 1283, 1289, 1291, 1297, 1301, 1303, 1307, 1319, 1321, 1327, 1361,
1367, 1373, 1381, 1399, 1409, 1423, 1427, 1429, 1433, 1439, 1447, 1451, 1453,
1459, 1471, 1481, 1483, 1487, 1489, 1493, 1499, 1511, 1523, 1531, 1543, 1549,
1553, 1559, 1567, 1571, 1579, 1583, 1597, 1601, 1607, 1609, 1613, 1619, 1621,
1627, 1637, 1657, 1663));

fb = hslider("feedback",0.5,0.0,1.0,0.01):si.smooth(0.99);

allpass(N,n,g) = (+ <: (de.delay(N, n), *(g))) ~ *(-g) : mem, _: +;
section((n1, n2)) = allpass(2048, n1, 0.7) : allpass(2048, n2, 0.7) : de.delay(4096, int(0.75*(n1+n2)));

allpass_chain(((n1, n2), ns), x) = _ : section((n1, n2)) <: R(x, ns), _
with {
	R(x, ((n1, n2), ns)) = _,x : + : section((n1, n2)) <: R(x, ns), _;
	R(x, (n1, n2)) = _,x : + : section((n1, n2));
};

procMono(feedfwd_delays, feedback_delays, feedback_gain, x) = x : (+ : allpass_chain(feedfwd_delays, x)) ~ (_,x : + : section(feedback_delays) : *(feedback_gain)) :> _;

process = si.bus(2) : mix(ma.PI/2) : *(0.5), *(0.5) : procLeft, procRight : si.bus(2)
with {	 

	mix(theta) = si.bus(2) <: (*(c), *(-s), *(s), *(c)) : (+,+) : si.bus(2)
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