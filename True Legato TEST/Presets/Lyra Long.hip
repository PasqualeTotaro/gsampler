Processor 
Type SynthChain ID Lyra Long Bypassed Gain 	      ??Balance 	        VoiceLimit 	      P@KillFadeTime 	      4@IconColour 0 packageName  BuildVersion ?  EditorStates BodyShown 0 Visible 1 Solo 0 Folded 1 OverviewFolded 0  ChildProcessors  Processor Type MidiProcessorChain ID Midi Processor Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type ScriptProcessor ID Interface Bypassed Script ?Content.makeFrontInterface(600, 600);


const var DefaultEnvelope = Synth.getModulator("DefaultEnvelope");


const var AHDSR = Synth.getModulator("AHDSR");
const var EnvelopePnl = Content.getComponent("EnvelopePnl")
const var AHDSRKnbs = [Content.getComponent("A"),
					   Content.getComponent("AL"),
                       Content.getComponent("H"),
                       Content.getComponent("D"),
                       Content.getComponent("S"),
                       Content.getComponent("R"),
                       Content.getComponent("AC"),
                       Content.getComponent("DC")];


//	AHDSR sliders	=======================
inline function onAHDRSKnbsControl(component, value)
{
	local Attributes = [2, 3, 4, 5, 6, 7, 8, 9];
	local panelValues = [];
	local i;
	for (i = 0; i < 8; i++)
	{
		AHDSR.setAttribute(Attributes[i], AHDSRKnbs[i].getValue());
		panelValues.push(AHDSRKnbs[i].getValueNormalized());
	}
	
	EnvelopePnl.setValue(panelValues);
	EnvelopePnl.changed();
}

for (k in AHDSRKnbs)
{
	k.setControlCallback(onAHDRSKnbsControl);
}

//	PR	=================================
EnvelopePnl.setPaintRoutine(function(g)
{
	var w = this.getWidth();
	var h = this.getHeight();
	var v = this.getValue();
	var offset = Preferences[0].getValue();
	var lineWidth = Preferences[6].getValue();
	var slot = w / 5;
	var x, db;
	var obj = [];
	var names = ["Attack", "Hold", "Decay", "Sustain", "Release"];
	var knbsOrder = [0, 2, 3, 4, 5];
	
	var p = Content.createPath();
	p.clear();
	//	Start painting
	p.startNewSubPath(0, h-0.5);
	x = slot*v[0];
	v[1] > v[4] ? db = h*(1-v[1]) : db = h*(1-v[4]);
	
	p.quadraticTo(x/2, h*(1-v[1]*(1-v[6])), x, db); //attack
	obj.push([x, db]);
	var dbA = db;
	x += slot*v[2];
	p.lineTo(x, db); //hold
	obj.push([x, db]);
	x += slot*v[3]*2;
	db = h*(1-v[4]);
	var ddb = db - dbA; // diff Sustain L - Attack L 
	p.quadraticTo(x-slot*v[3], (db-ddb*(1-v[7])), x, db); // decay, sustain
	obj.push([x, db]);
	x = slot*4;
	p.lineTo(x, db);
	obj.push([x, db]);
	x += slot*v[5];
	p.quadraticTo(x-slot*v[5], h, x, h-0.5); //release
	obj.push([x, h]);
	p.lineTo(0, h-0.5);
	
	this.data.objects = obj;
	var area = p.getBounds(1);

	g.beginLayer(true);
	g.fillAll(this.get("bgColour"));
	g.setColour(this.get("itemColour"));
	Preferences[1].getValue() ? g.fillPath(p, area) : "";
	g.setColour(this.get("itemColour2"));
	Preferences[2].getValue() ? g.drawPath(p, area, lineWidth) : "";
	
	if (Preferences[3].getValue())
	{
		for (i = 0; i < 5; i++)	// hover
			{
				i == this.data.hover ? g.setColour(Colours.crimson) : g.setColour(Colours.cornflowerblue);
				var x = obj[i][0]-offset;
				var y = obj[i][1]-offset;
				//
				x = Math.range(x, 0, w-(offset*2));
				y = Math.range(y, 0, h-(offset*2));
				g.drawEllipse([x, y, offset*2, offset*2], 2);
			}
	}
	
	//	text, name & value
	var mouseX, mouseY, suffix;
	
	g.setColour(this.get("textColour"));
	
	this.data.mouseX > w-60 ? mouseX = w-60 : mouseX = this.data.mouseX;
	this.data.mouseY < 40 ? mouseY = 10 : mouseY = this.data.mouseY-30;
	
	var name = names[this.data.hover];
	var data = Math.round(AHDSRKnbs[knbsOrder[this.data.hover]].getValue());
	
	this.data.hover == 3 ? suffix = " dB" : suffix = " ms";
	
	Preferences[4].getValue() ?
	g.drawAlignedText(name, [mouseX, mouseY, 100, 20], "left") : "";
	
	Preferences[5].getValue() ?
	g.drawAlignedText(data + suffix, [mouseX, mouseY+14, 100, 20], "left") : "";
});

//	MCB	==========================
EnvelopePnl.setMouseCallback(function(event)
{
	 var w = this.getWidth();
	 var h = this.getHeight();
	 var v = this.getValue();
	 var sens = 200; // drag sensibility
	 
	 if (event.hover && !event.drag)
	 {
		 var closest = 1000.0;
		 var closestX = [];
		 var objIdx;
		 this.data.mouseX = event.x;
		 this.data.mouseY = event.y;
		 var tdo = this.data.objects;
		 
		 for (i = 0; i < 5; i++) // which x value is closest to the mouse x
		 {
			 var diffX = Math.abs(parseInt(tdo[i][0]) -
			 parseInt(event.x));
			 if (diffX < closest)
			 {
				 closest = diffX;
				 objIdx = i;
			 }
			 
			 else if (diffX == closest) // if 2 parameters have the same x val
			 {
				 // which y value is closest to the mouse y
				 if (Math.abs(tdo[i][1] - parseInt(event.y)) <
				 Math.abs(tdo[objIdx][1] - parseInt(event.y)))
				 {
					 objIdx = i;
				 }
				 else if (objIdx == 0)
				 {
					 objIdx = 1; // both are on same x & y, chosing "hold"
				 }
				 else
				 {
					 "";
				 }
			 }
		 }
		 
		 this.data.hover = objIdx;
		 this.repaint();
	 }
	 
	 if (event.clicked || event.drag)
	 {
		 if (event.clicked)
		 {
			 var KnbValues = [];
			 for (k in AHDSRKnbs)
			 	KnbValues.push(k.getValueNormalized());
			 	
			 this.data.values = KnbValues;
		 }
		//
		switch (this.data.hover)
		{
			case 0:
				if (event.shiftDown)
				{
					AHDSRKnbs[6].setValueNormalized(this.data.values[6] + event.dragX/sens); // A curve
					AHDSRKnbs[6].changed();
				}
				else
				{
					AHDSRKnbs[0].setValueNormalized(this.data.values[0] + event.dragX/sens); // A time
					AHDSRKnbs[1].setValueNormalized(this.data.values[1] - event.dragY/sens); // A level
					AHDSRKnbs[0].changed();
					AHDSRKnbs[1].changed();
				}
				break;
			case 1:
				AHDSRKnbs[2].setValueNormalized(this.data.values[2] + event.dragX/sens); // H time
				AHDSRKnbs[2].changed();
				break;
			case 2:
				if (event.shiftDown)
				{
					AHDSRKnbs[7].setValueNormalized(this.data.values[7] + event.dragX/sens); // D curve
					AHDSRKnbs[7].changed();
				}
				else
				{
					AHDSRKnbs[3].setValueNormalized(this.data.values[3] + event.dragX/sens); // D time
					AHDSRKnbs[3].changed();
				}
				
				break;
			case 3:
				AHDSRKnbs[4].setValueNormalized(this.data.values[4] - event.dragY/sens); // S level
				AHDSRKnbs[4].changed();
				break;
			case 4:
				AHDSRKnbs[5].setValueNormalized(this.data.values[5] + event.dragX/sens); // R time
				AHDSRKnbs[5].changed();
				break;
		}
	 }
});

//	Preferences	==============================================
           
const var Preferences = [Content.getComponent("BallSize"),
                         Content.getComponent("Fill"),
                         Content.getComponent("Line"),
                         Content.getComponent("Balls"),
                         Content.getComponent("Name"),
                         Content.getComponent("Value"),
                         Content.getComponent("LineWidth")];
                         
const var ShowPreferences = Content.getComponent("ShowPreferences");
const var PreferencesContainer = Content.getComponent("PreferencesContainer");

//	Preferences	==============
inline function onShowPreferencesControl(component, value)
{
	PreferencesContainer.showControl(value);
}
ShowPreferences.setControlCallback(onShowPreferencesControl);


inline function onPreferencesControl(component, value)
{
	EnvelopePnl.changed();
}

for (c in Preferences){c.setControlCallback(onPreferencesControl);
};function onNoteOn()
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
  EditorStates BodyShown 1 Visible 1 Solo 0 contentShown 1 onInitOpen 1  ChildProcessors   Content  Control type ScriptSlider id Knob1 value 	   `?@?@ Control type ScriptSlider id Knob2 value 	   ???@ Control type ScriptButton id 	Button1 value 	         Control type ScriptSlider id Knob3 value 	         UIData  ContentProperties DeviceType 	Desktop Component 
type ScriptSlider id Knob1 x 	      >@y 	     ?q@max 	     @?@text Attack tooltip Attack isPluginParameter processorId DefaultEnvelope parameterId Attack  Component 	type ScriptSlider id Knob2 x 	     ?g@y 	     ?q@max 	     @?@text 	Release tooltip 	Release processorId DefaultEnvelope parameterId 	Release  Component type ScriptButton id 	Button1 x 	     @u@y 	      r@text Delay processorId Delay1 parameterId Bypass  Component 
type ScriptSlider id Knob3 x 	     ?r@y 	      d@filmstripImage !{PROJECT_FOLDER}Slider ADSR.png numStrips 	      D@width 	      4@height 	     ?Q@isVertical dragDirection 
Vertical  Processor Type ModulatorChain ID GainModulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0 Folded 0  ChildProcessors   Processor Type ModulatorChain ID PitchModulation Bypassed Intensity 	        EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type EffectChain ID FX Bypassed EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type SynthGroup ID Syntesizer Group1 Bypassed Gain 	    Vs??Balance 	        VoiceLimit 	      p@KillFadeTime 	      4@IconColour 0 EnableFM 	        CarrierIndex 	      ??ModulatorIndex 	      ??UnisonoVoiceAmount 	      ??UnisonoDetune 	        UnisonoSpread 	   @33??KillSecondVoices 	      ??EditorStates BodyShown 1 Visible 1 Solo 0 Folded 1  ChildProcessors  Processor Type MidiProcessorChain ID Midi Processor Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type ModulatorChain ID GainModulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor 	Type SimpleEnvelope ID DefaultEnvelope Bypassed Monophonic 	        Retrigger 	      ??Intensity 	      ??Attack 	   `?@?@Release 	   ???@LinearMode 	      ??EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors  Processor Type ModulatorChain ID Attack Time Modulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type ModulatorChain ID PitchModulation Bypassed Intensity 	        EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type EffectChain ID FX Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type Delay ID Delay1 Bypassed DelayTimeLeft 	      @DelayTimeRight 	      @FeedbackLeft 	   @33??FeedbackRight 	   @33??LowPassFreq 	     ??@HiPassFreq 	      D@Mix 	   @?z??TempoSync 	      ??EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   RoutingMatrix NumSourceChannels    Channel0     Send0 ????Channel1    Send1 ???? Processor Type ModulatorChain ID Detune Mod Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type ModulatorChain ID Spread Mod Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type StreamingSampler ID 
Sampler1 Bypassed Gain 	      ??Balance 	        VoiceLimit 	      p@KillFadeTime 	      4@IconColour 0 PreloadSize 	      ?@BufferSize 	      ?@VoiceAmount 	      p@SamplerRepeatMode 	      @RRGroupAmount 	      ??PitchTracking 	      ??OneShot 	        CrossfadeGroups 	        Purged 	        Reversed 	        NumChannels    UseStaticMatrix 	        Group0Table  Group1Table  Group2Table  Group3Table  Group4Table  Group5Table  Group6Table  Group7Table  EditorStates BodyShown 1 Visible 1 Solo 0 MapPanelShown 1 BigSampleMap 1 Folded 1  ChildProcessors  Processor Type MidiProcessorChain ID Midi Processor Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type ModulatorChain ID GainModulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor 
Type MidiController ID Midi Controller1 Bypassed Intensity 	      ??UseTable 	      ??Inverted 	        ControllerNumber 	      ??SmoothTime 	     @?@DefaultValue 	        ControllerTableData %24..........9C...vO...f+.........vO EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor Type ModulatorChain ID PitchModulation Bypassed Intensity 	        EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type EffectChain ID FX Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type ModulatorChain ID Sample Start Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type ModulatorChain ID Group Fade Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   RoutingMatrix NumSourceChannels    Channel0     Send0 ????Channel1    Send1 ???? channels  channelData enabled level 	        suffix   samplemap CrossfadeGamma 0.9450000000000001 ID Lyra Long Dyn 1 RRGroupAmount 1.0 MicPositions ; sample Root 46 LoKey 46 HiKey 49 LoVel 0 HiVel 127 RRGroup 1 FileName R/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Soft_A#1.wav Duplicate LoopEnabled 1 LoopStart 22546 LoopEnd 301905 LoopXFade 15500  sample Root 58 LoKey 58 HiKey    LoVel 0 HiVel 127 RRGroup 1 FileName R/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Soft_A#2.wav Duplicate LoopEnabled 1 LoopEnd 333407 LoopStart 19477 LoopXFade 15500  sample 
Root 57 LoKey 57 HiKey 57 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Soft_A2.wav Duplicate LoopEnabled 1 LoopXFade 0  sample 
Root 50 LoKey 50 HiKey 52 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Soft_D2.wav Duplicate LoopEnabled 1 LoopXFade 0  sample Root 41 LoKey 9 HiKey 45 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Soft_F1.wav Duplicate LoopEnabled 1 LoopStart 23489 LoopEnd 270127 LoopXFade 15500 GainTable e72...............vO..............vORAgf6....7C...nOlp0e+....7C...zO...f+.........zO...f+.........zO  sample Root 53 LoKey 53 HiKey 56 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Soft_F2.wav Duplicate LoopEnabled 1 LoopXFade 15257 LoopEnd 139993 LoopStart 20896  Processor Type StreamingSampler ID 
Sampler2 Bypassed Gain 	      ??Balance 	        VoiceLimit 	      p@KillFadeTime 	      4@IconColour 0 PreloadSize 	      ?@BufferSize 	      ?@VoiceAmount 	      p@SamplerRepeatMode 	      @RRGroupAmount 	      ??PitchTracking 	      ??OneShot 	        CrossfadeGroups 	        Purged 	        Reversed 	        NumChannels    UseStaticMatrix 	        Group0Table  Group1Table  Group2Table  Group3Table  Group4Table  Group5Table  Group6Table  Group7Table  EditorStates BodyShown 1 Visible 1 Solo 0 MapPanelShown 1 BigSampleMap 1 Folded 1  ChildProcessors  Processor Type MidiProcessorChain ID Midi Processor Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type ModulatorChain ID GainModulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor 
Type MidiController ID Midi Controller2 Bypassed Intensity 	      ??UseTable 	      ??Inverted 	        ControllerNumber 	      ??SmoothTime 	     @?@DefaultValue 	        ControllerTableData  EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor Type ModulatorChain ID PitchModulation Bypassed Intensity 	        EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type EffectChain ID FX Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type ModulatorChain ID Sample Start Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type ModulatorChain ID Group Fade Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   RoutingMatrix NumSourceChannels    Channel0     Send0 ????Channel1    Send1 ???? channels  channelData enabled level 	        suffix   samplemap ID Lyra Long Dyn 2 RRGroupAmount 1.0 MicPositions ; CrossfadeGamma 	      ??sample Root 9   LoKey 57 HiKey    LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Hard_A2.wav Duplicate Normalized 1 NormalizedPeak 1.122018575668335 LoopStart 14863 LoopEnd 276867 LoopEnabled 1  sample Root 47 LoKey 9 HiKey 49 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Hard_B1.wav Duplicate LoopStart 12939 LoopEnd 243931 LoopXFade 0 LoopEnabled 1  sample Root 50 LoKey 50 HiKey 52 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Hard_D2.wav Duplicate LoopEnd 328378 LoopStart 16970 LoopEnabled 1  sample Root 53 LoKey 53 HiKey 54 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Hard_F2.wav Duplicate LoopStart 16235 LoopEnd 303720 LoopEnabled 1  sample Root 55 LoKey 55 HiKey 56 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Hard_G2.wav Duplicate LoopStart ? LoopEnd 344671 LoopEnabled 1 LoopXFade     SampleStart ??  RoutingMatrix NumSourceChannels    Channel0     Send0 ????Channel1    Send1 ???? RoutingMatrix NumSourceChannels    Channel0     Send0 ????Channel1    Send1 ???? macro_controls  macro name 	Macro 1 value 0.0 midi_cc -1  macro name 	Macro 2 value 0.0 midi_cc -1  macro name 	Macro 3 value 0.0 midi_cc -1  macro name 	Macro 4 value 0.0 midi_cc -1  macro name 	Macro 5 value 0.0 midi_cc -1  macro name 	Macro 6 value 0.0 midi_cc -1  macro name 	Macro 7 value 0.0 midi_cc -1  macro name 	Macro 8 value 0.0 midi_cc -1  MidiAutomation   MPEData Enabled  