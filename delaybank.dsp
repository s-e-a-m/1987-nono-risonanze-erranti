import("stdfaust.lib");

fbgroup(x) = hgroup("Feedback", x);

fbgain1 = fbgroup(vslider("Feedback1", 0.,0.,1.,0.1) : si.smoo); 
fbgain2 = fbgroup(vslider("Feedback3", 0.,0.,1.,0.1) : si.smoo); 
fbgain3 = fbgroup(vslider("Feedback5", 0.,0.,1.,0.1) : si.smoo); 
fbgain4 = fbgroup(vslider("Feedback7", 0.,0.,1.,0.1) : si.smoo); 


process = _ <: de.sdelay(ba.sec2samp(5),1024,ba.sec2samp(5))~ *(fbgain1),
               de.delay(ba.sec2samp(5.5),ba.sec2samp(5.5)),
               de.sdelay(ba.sec2samp(6.2),1024,ba.sec2samp(6.2))~ *(fbgain2),
               de.delay(ba.sec2samp(6.6),ba.sec2samp(6.6)),
               de.sdelay(ba.sec2samp(7.3),1024,ba.sec2samp(7.3))~ *(fbgain3),
               de.delay(ba.sec2samp(7.7),ba.sec2samp(7.7)),
               de.sdelay(ba.sec2samp(8.2),1024,ba.sec2samp(8.2))~ *(fbgain4),
               de.delay(ba.sec2samp(9.1),ba.sec2samp(9.1));
