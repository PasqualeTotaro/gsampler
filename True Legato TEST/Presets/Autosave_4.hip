Processor 
Type SynthChain ID 
Progress Bypassed Gain 	      ??Balance 	        VoiceLimit 	      P@KillFadeTime 	      4@IconColour 0 packageName  BuildVersion ?  EditorStates BodyShown 0 Visible 1 Solo 0 Folded 1  ChildProcessors  Processor Type MidiProcessorChain ID Midi Processor Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type ScriptProcessor ID Interface Bypassed Script iContent.makeFrontInterface(900, 900);





const var AHDSR = Synth.getModulator("AHDSR3");
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
  EditorStates BodyShown 1 Visible 1 Solo 0 contentShown 1 onInitOpen 1  ChildProcessors   Content  Control type ScriptButton id ShowPreferences value 	         Control type ScriptSlider id A value 	   @??D@ Control type ScriptSlider id AL value 	         Control type ScriptSlider id AC value 	   @33?? Control type ScriptSlider id DC value 	   ????? Control type ScriptSlider id H value 	   ?/>?@ Control type ScriptSlider id D value 	   ???@ Control type ScriptSlider id S value 	   ??t?? Control type ScriptSlider id R value 	   ??t?@ Control type ScriptSlider id 
BallSize value 	      $@ Control type ScriptButton id Fill value 	      ?? Control type ScriptButton id Line value 	      ?? Control type ScriptButton id Balls value 	      ?? Control type ScriptButton id Name value 	      ?? Control type ScriptButton id Value value 	      ?? Control type ScriptSlider id LineWidth value 	   `ff@ Control type ScriptTable id Table1 value 	        data %24...............vO...f+TGTG7C...vO  Control type ScriptSlider id Knob1 value 	    )\?? Control type ScriptSlider id Knob2 value 	      @ UIData  ContentProperties DeviceType 	Desktop Component type ScriptPanel id EnvelopeContainer x 	        y 	        width 	     ??@height 	     ?r@itemColour 822083583 itemColour2 813727872 Component type ScriptButton id ShowPreferences x 	     ?~@y 	      @width 	      Y@height 	      4@parentComponent EnvelopeContainer text Preferences  Component type ScriptPanel id EnvelopePnl x 	      4@y 	      >@width 	     0?@height 	      ^@allowCallbacks All Callbacks itemColour2 3305111551 parentComponent EnvelopeContainer itemColour 587202559 textColour 3439329279 bgColour 1426063360  Component type ScriptSlider id A x 	      4@y 	     ?l@width 	     ?[@height 	      I@mode Time max 	     ??@stepSize 	      ??suffix  ms middlePosition 	     @?@parentComponent EnvelopeContainer visible 0  Component type ScriptSlider id AL x 	      4@y 	     ?f@width 	     ?[@height 	      I@mode 	Decibel min 	      Y?max 	        stepSize 	   ?????suffix  dB middlePosition 	      2?parentComponent EnvelopeContainer visible 0  Component type ScriptSlider id AC x 	     @`@y 	     ?f@width 	     ?[@height 	      I@mode NormalizedPercentage suffix % middlePosition 	      ??parentComponent EnvelopeContainer visible 0  Component type ScriptSlider id DC x 	      n@y 	     ?f@width 	     ?[@height 	      I@mode NormalizedPercentage suffix % middlePosition 	      ??parentComponent EnvelopeContainer visible 0  Component type ScriptSlider id H x 	     @`@y 	     ?l@width 	     ?[@height 	      I@mode Time max 	     ??@stepSize 	      ??suffix  ms middlePosition 	     @?@parentComponent EnvelopeContainer visible 0  Component type ScriptSlider id D x 	      n@y 	     ?l@width 	     ?[@height 	      I@mode Time max 	     ??@stepSize 	      ??suffix  ms middlePosition 	     @?@parentComponent EnvelopeContainer visible 0  Component type ScriptSlider id S x 	     ?u@y 	     ?l@width 	     ?[@height 	      I@mode 	Decibel min 	      Y?max 	        stepSize 	   ?????suffix  dB middlePosition 	      2?parentComponent EnvelopeContainer visible 0  Component type ScriptSlider id R x 	     ?|@y 	     ?l@width 	     ?[@height 	      I@mode Time max 	     ??@stepSize 	      ??suffix  ms middlePosition 	     @?@parentComponent EnvelopeContainer visible 0  Component 
type ScriptPanel id PreferencesContainer x 	      y@y 	      >@width 	     ?g@height 	     ?g@parentComponent EnvelopeContainer itemColour 4285690482 itemColour2 4278190080 visible Component 	type ScriptLabel id ScriptLabel1 x 	        y 	        width 	     ?g@height 	      4@parentComponent PreferencesContainer editable 0 text What to show  Component type ScriptSlider id 
BallSize x 	      Y@y 	     @U@width 	      T@height 	      >@parentComponent PreferencesContainer style Horizontal max 	      $@min 	       @stepSize 	   ?????middlePosition 	      @defaultValue 	      @suffix  px  Component type ScriptButton id Fill x 	      @y 	      9@width 	      T@height 	      >@parentComponent PreferencesContainer  Component type ScriptButton id Line x 	      @y 	     ?K@width 	      T@height 	      >@parentComponent PreferencesContainer  Component type ScriptButton id Balls x 	      @y 	     @U@width 	      T@height 	      >@parentComponent PreferencesContainer  Component type ScriptButton id Name x 	      @y 	     ?\@width 	      T@height 	      >@parentComponent PreferencesContainer  Component type ScriptButton id Value x 	      @y 	      b@width 	      T@height 	      >@parentComponent PreferencesContainer  Component type ScriptSlider id LineWidth x 	      Y@y 	     ?K@width 	      T@height 	      >@parentComponent PreferencesContainer style Horizontal max 	      @min 	      ??stepSize 	   ?????middlePosition 	      
@defaultValue 	      ??suffix  px  Component type ScriptFloatingTile id FloatingTile1 x 	        y 	      t@ContentType 
MPEPanel bgColour 0 itemColour 2164260863 itemColour2 452984831 width 	     ?@height 	      D@FontSize 	      *@Font Source Code Pro  Component type ScriptFloatingTile id FloatingTile2 x 	     ?k@y 	      y@ContentType FilterDisplay bgColour 4278190080 itemColour 4294967295 itemColour2 2147483648 Data K{
  "ProcessorId": "Filter1",
  "Index": -1,
  "FollowWorkspace": false
} width 	     @e@height 	     ?Q@FontSize 	    ?G?? Component type ScriptTable id Table1 x 	     ?k@y 	     `}@width 	     @e@height 	     ?Q@processorId Modulation>Filter bgColour 1431326110 itemColour2 4227040131 itemColour 1716586761 customColours 1  Component type ScriptSlider id Knob1 x 	      D@y 	     ??@text lfo depth processorId 
LFO>GAIN parameterId Intensity  Component type ScriptTable id Table2 x 	     ?f@y 	     ??@width 	      i@height 	     ?V@processorId 
LFO>GAIN saveInPreset 0  Component type ScriptSlider id Knob2 x 	     ?f@y 	     І@stepSize 	   @?z??max 	      Y@processorId LFO Modulator1 parameterId Frequency mode TempoSync width 	     ?g@height 	      D@ Processor Type ModulatorChain ID GainModulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID PitchModulation Bypassed Intensity 	        EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type EffectChain ID FX Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor 	Type PolyphonicFilter ID 	Filter1 Bypassed Gain 	        Frequency 	   @???@Q 	   ?p=??Mode 	       @Quality 	   @72?ABipolarIntensity 	        EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors  Processor Type ModulatorChain ID Frequency Modulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor 
Type MidiController ID Modulation>Filter Bypassed Intensity 	      ??UseTable 	      ??Inverted 	        ControllerNumber 	      ??SmoothTime 	      i@DefaultValue 	     ?M@ControllerTableData %24...............vO...f+TGTG7C...vO EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor Type GlobalTimeVariantModulator ID  Global Time Variant Modulator1 Bypassed Intensity 	      ??UseTable Inverted TableData  Connection (Global Modulator Container1:LFO>FILTER EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor Type ModulatorChain ID Gain Modulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type ModulatorChain ID Bipolar Freq Modulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type ModulatorChain ID Q Modulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type GlobalModulatorContainer ID Global Modulator Container1 Bypassed Gain 	    )\??Balance 	        VoiceLimit 	      p@KillFadeTime 	      4@IconColour 0 EditorStates BodyShown 1 Visible 1 Solo 0 Folded 1  ChildProcessors  Processor Type MidiProcessorChain ID Midi Processor Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type MidiMuter ID MidiMuter1 Bypassed EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Content  Control type ScriptButton id ignoreButton value 	      ?? Control type ScriptButton id fixStuckNotes value 	      ?? Processor Type ModulatorChain ID Global Modulators Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type LFO ID 
LFO>GAIN Bypassed Intensity 	    )\??Bipolar Frequency 	       @FadeIn 	        WaveformType 	      @Legato 	      ??TempoSync 	      ??SmoothingTime 	   ???5@LoopEnabled 	      ??PhaseOffset 	        SyncToMasterClock 	        CustomWaveform E48..........9C...vO4MiX9PMes7C...vO4iNI+.Atw5C...vO...f+.........vO StepData [64....f+....9C...3O...f+....9C...3O...f+....9C...3O...f+....9C...3O...f+....9C...3O...f+. EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors  Processor Type ModulatorChain ID LFO Intensity Mod Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type ModulatorChain ID LFO Frequency Mod Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type LFO ID LFO>FILTER Bypassed Intensity 	    ????Bipolar Frequency 	      @FadeIn 	    \?)@WaveformType 	      @Legato 	      ??TempoSync 	      ??SmoothingTime 	    ??Y@LoopEnabled 	      ??PhaseOffset 	        SyncToMasterClock 	        CustomWaveform  StepData [64....f+ziBW6CEtdvOgqGk9HEtd5iBWOpO...f+T35Q6CEtdvOMyLC+nYlY7iBWOxOeT3J+LyLy7Sb8nzOEtdT+. EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors  Processor Type ModulatorChain ID LFO Intensity Mod Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type ModulatorChain ID LFO Frequency Mod Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type ModulatorChain ID PitchModulation Bypassed Intensity 	        EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type EffectChain ID FX Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   RoutingMatrix NumSourceChannels    Channel0     Send0 ????Channel1    Send1 ???? Processor Type SynthGroup ID Syntesizer Group1 Bypassed Gain 	    Vs??Balance 	        VoiceLimit 	      p@KillFadeTime 	      4@IconColour 0 EnableFM 	        CarrierIndex 	      ??ModulatorIndex 	      ??UnisonoVoiceAmount 	      ??UnisonoDetune 	        UnisonoSpread 	   @33??KillSecondVoices 	      ??EditorStates BodyShown 1 Visible 1 Solo 0 Folded 1  ChildProcessors  Processor Type MidiProcessorChain ID Midi Processor Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type ChannelFilter ID MIDI Channel Filter2 Bypassed EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Content  Control type ScriptSlider id channelNumber value 	      ?? Control type ScriptSlider id 
mpeStart value 	       @ Control type ScriptSlider id mpeEnd value 	      0@ Processor Type ModulatorChain ID GainModulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type AHDSR ID AHDSR3 Bypassed Monophonic 	        Retrigger 	        Intensity 	      ??AttackCurve 	   @33??DecayCurve 	   ?????Attack 	   @??D@AttackLevel 	        Hold 	   ?/>?@Decay 	   ???@Sustain 	   `?t??Release 	   ??t?@EcoMode 	      ??EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors  Processor Type ModulatorChain ID Attack Time Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Attack Level Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Decay Time Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Sustain Level Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Release Time Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type GlobalTimeVariantModulator ID  Global Time Variant Modulator1 Bypassed Intensity 	      ??UseTable Inverted TableData  Connection &Global Modulator Container1:LFO>GAIN EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor Type ModulatorChain ID PitchModulation Bypassed Intensity 	        EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type MPEModulator ID MPE Modulator2 Bypassed Monophonic 	        Retrigger 	        Bipolar Intensity 	        GestureCC 	      @SmoothingTime 	      i@DefaultValue 	        SmoothedIntensity 	        Table  EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor Type EffectChain ID FX Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type Delay ID Delay1 Bypassed DelayTimeLeft 	      @DelayTimeRight 	      @FeedbackLeft 	   ?=
??FeedbackRight 	   @33??LowPassFreq 	     ??@HiPassFreq 	      D@Mix 	   ?=
??TempoSync 	      ??EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   RoutingMatrix NumSourceChannels    Channel0     Send0 ????Channel1    Send1 ???? Processor Type ModulatorChain ID Detune Mod Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Spread Mod Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type StreamingSampler ID 
Sampler1 Bypassed Gain 	      ??Balance 	        VoiceLimit 	      p@KillFadeTime 	      4@IconColour 0 PreloadSize 	      ?@BufferSize 	      ?@VoiceAmount 	      p@SamplerRepeatMode 	      @RRGroupAmount 	      ??PitchTracking 	      ??OneShot 	        CrossfadeGroups 	        Purged 	        Reversed 	        NumChannels    UseStaticMatrix 	        Group0Table  Group1Table  Group2Table  Group3Table  Group4Table  Group5Table  Group6Table  Group7Table  EditorStates BodyShown 1 Visible 1 Solo 0 MapPanelShown 1 BigSampleMap 1 Folded 1 CrossfadeTableShown 0  ChildProcessors  Processor Type MidiProcessorChain ID Midi Processor Bypassed EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID GainModulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor 
Type MidiController ID Midi Controller1 Bypassed Intensity 	      ??UseTable 	      ??Inverted 	        ControllerNumber 	      ??SmoothTime 	     @?@DefaultValue 	      @ControllerTableData %24..........9C...vO...f+.........vO EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor Type MPEModulator ID MPE Modulator3 Bypassed Monophonic 	        Retrigger 	      ??Intensity 	      ??GestureCC 	      ??SmoothingTime 	      i@DefaultValue 	        SmoothedIntensity 	      ??Table  EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor Type ModulatorChain ID PitchModulation Bypassed Intensity 	        EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type EffectChain ID FX Bypassed EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Sample Start Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Group Fade Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   RoutingMatrix NumSourceChannels    Channel0     Send0 ????Channel1    Send1 ???? channels  channelData enabled level 	        suffix   samplemap CrossfadeGamma 0.9450000000000001 ID Lyra Long Dyn 1 RRGroupAmount 1.0 MicPositions ; sample Root 46 LoKey 46 HiKey 49 LoVel 0 HiVel 127 RRGroup 1 FileName R/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Soft_A#1.wav Duplicate LoopEnabled 1 LoopStart 22546 LoopEnd 301905 LoopXFade 15500  sample Root 58 LoKey 58 HiKey 127 LoVel 0 HiVel 127 RRGroup 1 FileName R/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Soft_A#2.wav Duplicate LoopEnabled 1 LoopEnd 333407 LoopStart 19477 LoopXFade 15500  sample 
Root 57 LoKey 57 HiKey 57 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Soft_A2.wav Duplicate LoopEnabled 1 LoopXFade 0  sample 
Root 50 LoKey 50 HiKey 52 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Soft_D2.wav Duplicate LoopEnabled 1 LoopXFade 0  sample Root 41 LoKey 9 HiKey 45 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Soft_F1.wav Duplicate LoopEnabled 1 LoopStart 23489 LoopEnd 270127 LoopXFade 15500 GainTable e72...............vO..............vORAgf6....7C...nOlp0e+....7C...zO...f+.........zO...f+.........zO  sample Root 53 LoKey 53 HiKey 56 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Soft_F2.wav Duplicate LoopEnabled 1 LoopXFade 15257 LoopEnd 139993 LoopStart 20896  Processor Type StreamingSampler ID 
Sampler2 Bypassed Gain 	      ??Balance 	        VoiceLimit 	      p@KillFadeTime 	      4@IconColour 0 PreloadSize 	      ?@BufferSize 	      ?@VoiceAmount 	      p@SamplerRepeatMode 	      @RRGroupAmount 	      ??PitchTracking 	      ??OneShot 	        CrossfadeGroups 	        Purged 	        Reversed 	        NumChannels    UseStaticMatrix 	        Group0Table  Group1Table  Group2Table  Group3Table  Group4Table  Group5Table  Group6Table  Group7Table  EditorStates BodyShown 1 Visible 1 Solo 0 MapPanelShown 1 BigSampleMap 1 Folded 1 CrossfadeTableShown 0  ChildProcessors  Processor Type MidiProcessorChain ID Midi Processor Bypassed EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID GainModulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor 
Type MidiController ID Midi Controller2 Bypassed Intensity 	      ??UseTable 	      ??Inverted 	        ControllerNumber 	      ??SmoothTime 	     @?@DefaultValue 	      ??ControllerTableData  EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor Type MPEModulator ID MPE Modulator4 Bypassed Monophonic 	        Retrigger 	      ??Intensity 	      ??GestureCC 	      ??SmoothingTime 	      i@DefaultValue 	        SmoothedIntensity 	      ??Table  EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor Type ModulatorChain ID PitchModulation Bypassed Intensity 	        EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type EffectChain ID FX Bypassed EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Sample Start Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID Group Fade Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   RoutingMatrix NumSourceChannels    Channel0     Send0 ????Channel1    Send1 ???? channels  channelData enabled level 	        suffix   samplemap ID Lyra Long Dyn 2 RRGroupAmount 1.0 MicPositions ; CrossfadeGamma 1.0 sample Root 57 LoKey 57 HiKey 127 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Hard_A2.wav Duplicate Normalized 1 NormalizedPeak 1.122018575668335 LoopStart 14863 LoopEnd 276867 LoopEnabled 1  sample Root 47 LoKey 9 HiKey 49 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Hard_B1.wav Duplicate LoopStart 12939 LoopEnd 243931 LoopXFade 0 LoopEnabled 1  sample Root 50 LoKey 50 HiKey 52 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Hard_D2.wav Duplicate LoopEnd 328378 LoopStart 16970 LoopEnabled 1  sample Root 53 LoKey 53 HiKey 54 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Hard_F2.wav Duplicate LoopStart 16235 LoopEnd 303720 LoopEnabled 1  sample Root 55 LoKey 55 HiKey 56 LoVel 0 HiVel 127 RRGroup 1 FileName Q/Volumes/8 TB RAID/Projects/Sound Design /Lyra Sampilng/EXPORT/Lyra Hard_G2.wav Duplicate LoopStart 135050 LoopEnd 344671 LoopEnabled 1 LoopXFade 0 SampleStart 126914  RoutingMatrix NumSourceChannels    Channel0     Send0 ????Channel1    Send1 ???? RoutingMatrix NumSourceChannels    Channel0     Send0 ????Channel1    Send1 ???? macro_controls  macro name 	Macro 1 value 0.0 midi_cc -1  macro name 	Macro 2 value 0.0 midi_cc -1  macro name 	Macro 3 value 0.0 midi_cc -1  macro name 	Macro 4 value 0.0 midi_cc -1  macro name 	Macro 5 value 0.0 midi_cc -1  macro name 	Macro 6 value 0.0 midi_cc -1  macro name 	Macro 7 value 0.0 midi_cc -1  macro name 	Macro 8 value 0.0 midi_cc -1  MidiAutomation   MPEData Enabled Processor 	ID MPE Modulator3 Bypassed Monophonic 	        Retrigger 	      ??GestureCC 	      ??SmoothingTime 	      i@DefaultValue 	        SmoothedIntensity 	      ??Table   Processor 	ID MPE Modulator4 Bypassed Monophonic 	        Retrigger 	      ??GestureCC 	      ??SmoothingTime 	      i@DefaultValue 	        SmoothedIntensity 	      ??Table   Processor 
ID MPE Modulator2 Bypassed Monophonic 	        Retrigger 	        Bipolar GestureCC 	      @SmoothingTime 	      i@DefaultValue 	        SmoothedIntensity 	        Table   