Processor 
Type SynthChain ID colortest Bypassed Gain 	      ??Balance 	        VoiceLimit 	      P@KillFadeTime 	      4@IconColour 0 packageName  BuildVersion ?  EditorStates BodyShown 0 Visible 1 Solo 0 Folded 1  ChildProcessors  Processor Type MidiProcessorChain ID Midi Processor Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type Transposer ID  Transposer 1  Bypassed TransposeAmount 	      &@EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Processor Type ScriptProcessor ID Interface Bypassed Script ?Content.makeFrontInterface(600, 600);








const var Knob1 = Content.getComponent("Knob1");
Console.print(Knob1.getValue());



Content.getComponent("Panel1").setControlCallback(onPanel1Control);




const var LFOModulator1 = Synth.getModulator("LFO Modulator1");

const var Panel1 = Content.getComponent("Panel1");

Panel1.setPaintRoutine(function(g){
    g.setColour(Colours.withAlpha(0xca2332, LFOModulator1.getCurrentLevel()));
    g.fillEllipse([4,0.5,(Knob1.getValue()),(Knob1.getValue())]);


});

Panel1.setTimerCallback(function(){
    this.repaint();
});

Panel1.startTimer(30);












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
  EditorStates BodyShown 1 Visible 1 Solo 0 contentShown 1 onInitOpen 1  ChildProcessors   Content  Control type ScriptSlider id Knob1 value 	      T@ UIData  ContentProperties DeviceType 	Desktop Component 
type ScriptPanel id Panel1 x 	     ?Q@y 	     ?w@width 	     ?V@height 	     ?V@bgColour 	22ԕ    itemColour2 	::??    itemColour 	????    textColour 	WW??     Component type ScriptSlider id Knob1 x 	     `s@y 	     ?w@stepSize 	   @?z??min 	      $@max 	      T@ Processor Type ModulatorChain ID GainModulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor Type ScriptTimeVariantModulator ID  Script Time Variant Modulator1 Bypassed Intensity 	      ??Script ? function prepareToPlay(sampleRate, samplesPerBlock)
{
	
}
 function processBlock(buffer)
{
	
}
 function onNoteOn()
{
	
}
 function onNoteOff()
{
	
}
 function onController()
{
	
}
 function onControl(number, value)
{
	
}
  EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors   Content   UIData  ContentProperties DeviceType 	Desktop  Processor Type ModulatorChain ID PitchModulation Bypassed Intensity 	        EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type EffectChain ID FX Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type SineSynth ID Sine Wave Generator1 Bypassed Gain 	      ??Balance 	        VoiceLimit 	      p@KillFadeTime 	      4@IconColour 0 OctaveTranspose 	        SemiTones 	        UseFreqRatio 	        CoarseFreqRatio 	      ??FineFreqRatio 	        SaturationAmount 	        EditorStates BodyShown 1 Visible 1 Solo 0 Folded 1  ChildProcessors  Processor Type MidiProcessorChain ID Midi Processor Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type ModulatorChain ID GainModulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors  Processor 	Type SimpleEnvelope ID DefaultEnvelope1 Bypassed Monophonic 	        Retrigger 	      ??Intensity 	      ??Attack 	      @Release 	      $@LinearMode 	      ??EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors  Processor Type ModulatorChain ID Attack Time Modulation Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type LFO ID LFO Modulator1 Bypassed Intensity 	      ??Frequency 	   ?G???FadeIn 	        WaveformType 	      ??Legato 	        TempoSync 	        SmoothingTime 	        LoopEnabled 	      ??PhaseOffset 	        SyncToMasterClock 	        CustomWaveform %24...............vO...f+....9ioXCvO StepData [64....f+....9C...3O...f+....9C...3O...f+....9C...3O...f+....9C...3O...f+....9C...3O...f+. EditorStates BodyShown 1 Visible 1 Solo 0  ChildProcessors  Processor Type ModulatorChain ID LFO Intensity Mod Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID LFO Frequency Mod Bypassed Intensity 	      ??EditorStates BodyShown 1 Visible 0 Solo 0 Folded 1  ChildProcessors   Processor Type ModulatorChain ID PitchModulation Bypassed Intensity 	        EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   Processor Type EffectChain ID FX Bypassed EditorStates BodyShown 1 Visible 0 Solo 0  ChildProcessors   RoutingMatrix NumSourceChannels    Channel0     Send0 ????Channel1    Send1 ???? RoutingMatrix NumSourceChannels    Channel0     Send0 ????Channel1    Send1 ???? macro_controls  macro name 	Macro 1 value 0.0 midi_cc -1  macro name 	Macro 2 value 0.0 midi_cc -1  macro name 	Macro 3 value 0.0 midi_cc -1  macro name 	Macro 4 value 0.0 midi_cc -1  macro name 	Macro 5 value 0.0 midi_cc -1  macro name 	Macro 6 value 0.0 midi_cc -1  macro name 	Macro 7 value 0.0 midi_cc -1  macro name 	Macro 8 value 0.0 midi_cc -1  MidiAutomation   MPEData Enabled  