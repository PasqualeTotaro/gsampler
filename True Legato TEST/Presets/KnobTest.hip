Processor 
Type SynthChain ID 
KnobTest Bypassed Gain 	      ??Balance 	        VoiceLimit 	      P@KillFadeTime 	      4@IconColour 0 packageName  BuildVersion ?  EditorStates BodyShown 0 Visible 1 Solo 0 Folded 1  ChildProcessors  Processor Type MidiProcessorChain ID Midi Processor Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type ScriptProcessor ID Interface Bypassed Script hContent.makeFrontInterface(500, 500);

const var Panel2 = Content.getComponent("Panel2");

Panel2.data.originalPosition = 0.0;
Panel2.data.changePosition = 0.0;

Panel2.data.originalRadius = 30;
Panel2.data.changeRadius = 0;

Panel2.setPaintRoutine(function(g)
{
	var width = Panel2.getWidth();
	var height = Panel2.getHeight();
	var radius = Panel2.data.originalRadius + Panel2.data.changeRadius;
	var rotation = Panel2.data.originalPosition + Panel2.data.changePosition;
	g.rotate((0.2 + 1.8*rotation)*3.147, [width/2.0,height/2.0]);
	g.setColour(Colours.fromVec4([0.2,0.2,0.2,1.0]));
    g.fillEllipse([(width/2-radius),(height/2-radius),radius*2, radius*2]);
    g.setColour(Colours.fromVec4([1.0,1.0,1.0,1.0]));
    g.fillEllipse([(width/2-5),(height/2+radius-20),10, 10]);
});

Panel2.setMouseCallback(function(event)
{
	var width = Panel2.getWidth();
	if(event.dragY)
	    {
			Panel2.data.changePosition =  -event.dragY/100.0;
			if ((Panel2.data.originalPosition + Panel2.data.changePosition)> 1.0){
				Panel2.data.changePosition = 1.0 - Panel2.data.originalPosition;
			}else if((Panel2.data.originalPosition + Panel2.data.changePosition) < 0.0){
				Panel2.data.changePosition = 0.0 - Panel2.data.originalPosition;
			}
			this.repaint();
	    }
	    
    if(event.dragX)
   	    {
			Console.print(event.dragX);

   			Panel2.data.changeRadius =  event.dragX/3.0;
   			if ((Panel2.data.originalRadius + Panel2.data.changeRadius)> width/2){
   				Panel2.data.changeRadius = width/2 - Panel2.data.originalRadius;
   			}else if((Panel2.data.originalRadius + Panel2.data.changeRadius) < 30){
   				Panel2.data.changeRadius = 30 - Panel2.data.originalRadius;
   			}
   			this.repaint();
   	    }
	    
	if(event.mouseUp)
		{
									Panel2.data.originalPosition=Panel2.data.originalPosition+Panel2.data.changePosition;
			Panel2.data.changePosition=0;
			Panel2.data.originalRadius=Panel2.data.originalRadius+Panel2.data.changeRadius;
						Panel2.data.changeRadius=0;
		}
		
});

function onNoteOn()
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
  EditorStates BodyShown 1 Visible 1 Solo 0 contentShown 1 onInitOpen 1  ChildProcessors   Content   UIData  ContentProperties DeviceType 	Desktop Component type ScriptPanel id Panel1 x 	        y 	        width ?  height ?  itemColour 	? ??    itemColour2 	{ ??     Component type ScriptPanel id Panel2 x 	      Y@y 	      Y@width ,  height ,  allowCallbacks Clicks, Hover & Dragging  Processor Type ModulatorChain ID GainModulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type ModulatorChain ID PitchModulation Bypassed Intensity 	        EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type EffectChain ID FX Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   RoutingMatrix NumSourceChannels    Channel0     Send0 ????Channel1    Send1 ???? macro_controls  macro name 	Macro 1 value 0.0 midi_cc -1  macro name 	Macro 2 value 0.0 midi_cc -1  macro name 	Macro 3 value 0.0 midi_cc -1  macro name 	Macro 4 value 0.0 midi_cc -1  macro name 	Macro 5 value 0.0 midi_cc -1  macro name 	Macro 6 value 0.0 midi_cc -1  macro name 	Macro 7 value 0.0 midi_cc -1  macro name 	Macro 8 value 0.0 midi_cc -1  MidiAutomation   MPEData Enabled  