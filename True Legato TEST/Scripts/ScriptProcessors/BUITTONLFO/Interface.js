Content.makeFrontInterface(50, 50);

const var LFOModulator1 = Synth.getModulator("LFO Modulator1");

const var Panel1 = Content.getComponent("Panel1");

Panel1.setPaintRoutine(function(g){
    g.setColour(Colours.withAlpha(0xca2333, LFOModulator1.getCurrentLevel()));
    g.fillEllipse([5,3,40,40]);
});

Panel1.setTimerCallback(function(){
    this.repaint();
});

Panel1.startTimer(40);function onNoteOn()
{
	
}
 function onNoteOff()
{
	
}
 function onController()
{
	
}
 function onTimer()
{
	
}
 function onControl(number, value)
{
	
}
 