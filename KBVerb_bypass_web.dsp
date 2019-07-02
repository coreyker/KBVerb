import("https://raw.githubusercontent.com/sletz/KBVerb/master/bypass.lib");

process = bypass_fx_fade(checkbox("bypass"), ma.SR/10, component("https://raw.githubusercontent.com/sletz/KBVerb/master/KBVerb.dsp"));
