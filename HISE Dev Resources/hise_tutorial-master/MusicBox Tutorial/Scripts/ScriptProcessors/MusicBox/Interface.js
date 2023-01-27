include("SettingsButton.js");
include("UserPresetWidgets.js");
include("VuMeter.js");


Content.makeFrontInterface(505, 252 + 72 + 40);



const var presetDecButton = UserPresetWidgets.createPresetButton("presetDecButton", 290, 7, false);
const var presetIncButton = UserPresetWidgets.createPresetButton("presetIncButton", 482, 7, true);

const var presetDisplayPanel = UserPresetWidgets.createPresetDisplay("presetDisplayPanel", 314, 4);
UserPresetWidgets.setPresetBrowserLookAndFeel(presetDisplayPanel, "Oxygen", 15, "0xFFAAAAAA");

//! ==================================================================== UI Parts


const var bgImage = Content.addImage("bgImage", 0, 40);
// [JSON bgImage]
Content.setPropertiesFromJSON("bgImage", {
  "width": 505,
  "height": 252,
  "fileName": "{PROJECT_FOLDER}Background.png"
});
// [/JSON bgImage]

//! ======================================================================= Knobs

                         
inline function createMusicBoxKnob(name, x, y)
{
	local widget = Content.addKnob(name, x, y);
    
    Content.setPropertiesFromJSON(name, {
      "width": 32,
      "height": 38,
      "filmstripImage": "{PROJECT_FOLDER}knob_128frames.png",
      "numStrips": "128"
    });
    
    return widget;
};

const var modWheelAttKnob = createMusicBoxKnob("modWheelAttKnob", 87, 139);
const var clickAttackKnob = createMusicBoxKnob("clickAttackKnob", 212, 139);
const var reverbAmountKnob = createMusicBoxKnob("reverbAmountKnob", 345, 139);

reverbAmountKnob.setRange(-100, 0, 0.1);
reverbAmountKnob.setMidPoint(-12.0);

const var reverbSizeKnob = createMusicBoxKnob("reverbSizeKnob", 419, 139);
const var reverbColourKnob = createMusicBoxKnob("reverbColourKnob", 419, 214);
const var predelayKnob = createMusicBoxKnob("predelayKnob", 344, 214);

predelayKnob.setRange(0.0, 50.0, 1.0);


//! ===================================================================== Buttons

const var releaseTriggerButton = Content.addButton("releaseTriggerButton", 75, 238);
// [JSON releaseTriggerButton]
Content.setPropertiesFromJSON("releaseTriggerButton", {
  "width": 56,
  "height": 22,
  "filmstripImage": "{PROJECT_FOLDER}onoffSwitch.png"
});
// [/JSON releaseTriggerButton]
const var noteOffButton = Content.addButton("noteOffButton", 207, 239);
// [JSON noteOffButton]
Content.setPropertiesFromJSON("noteOffButton", {
  "width": 48,
  "height": 20,
  "filmstripImage": "{PROJECT_FOLDER}switch.png"
});
// [/JSON noteOffButton]

//! ============================================================================== Tooltips

modWheelAttKnob.set("tooltip", "Dampens the velocity according to the modwheel position");
clickAttackKnob.set("tooltip", "Controls the volume of the click noise");
reverbAmountKnob.set("tooltip", "Controls the reverb amount");
reverbSizeKnob.set("tooltip", "Controls the room size of the reverb");
reverbColourKnob.set("tooltip", "Controls the timbre of the reverb");
predelayKnob.set("tooltip", "Controls the predelay of the reverb");
releaseTriggerButton.set("tooltip", "Enables a muted ring off sound");
noteOffButton.set("tooltip", "Lets the note ring off naturally (ignores note offs)");


//! =========================================================== Module References


const var ReverbSendGain = Synth.getEffect("ReverbSendGain");
const var SimpleReverb = Synth.getEffect("Simple Reverb");
const var MalletClick = Synth.getChildSynth("Mallet Click");
const var ModwheelHandler = Synth.getMidiProcessor("ModwheelHandler");
const var MidiMuter = Synth.getMidiProcessor("MidiMuter");
const var MusicboxSamples = Synth.getChildSynth("Musicbox Samples");

//! =========================================================== Additional UI Elements


const var settingsButton = SettingsButton.createSettingsButton("settingsButton", 5, 5);

const var PerformanceLabel = Content.addFloatingTile("PerformanceLabel", 31, 2);
// [JSON PerformanceLabel]
Content.setPropertiesFromJSON("PerformanceLabel", {
  "width": 186,
  "height": 32
});
// [/JSON PerformanceLabel]
const var perfData = {
  "Type": "PerformanceLabel",
  "Font": "Oxygen Bold",
  "FontSize": "12.0",
  "ColourData": {
    "textColour": "0xAAFFFFFF"
  }
};

PerformanceLabel.setContentData(perfData);


const var MasterGain = Synth.getEffect("Master Gain");
const var outputMeter = VuMeter.createVuMeter("outputMeter", 328, 72, MasterGain);
outputMeter.set("height", 28);
outputMeter.set("width", 28);
outputMeter.set("bgColour", 0x003A3A3A);
outputMeter.set("itemColour2", 0x88282828);
outputMeter.set("opaque", false);;



const var Tooltips = Content.addFloatingTile("Tooltips", 27, 41);
// [JSON Tooltips]
Content.setPropertiesFromJSON("Tooltips", {
  "width": 453,
  "height": 26
});
// [/JSON Tooltips]

Tooltips.setContentData({"Type": "TooltipPanel", 
                         "FontSize": 13.0, 
                         "ColourData": {"bgColour": "0x000000"}});

const var Keyboard = Content.addFloatingTile("Keyboard", 0, 292);
// [JSON Keyboard]
Content.setPropertiesFromJSON("Keyboard", {
  "width": 505,
  "height": 72
});
// [/JSON Keyboard]

Keyboard.setContentData({"Type": "Keyboard", "LowKey": 33});

for(i = 0; i < 127; i++)
{
    if(i >= 50 && i <= 76) Engine.setKeyColour(i, 0x22FFFFFF);    
    else				   Engine.setKeyColour(i, 0x77000000);
};
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
	
	switch(number)
	{
		case reverbAmountKnob:
		{
			ReverbSendGain.setAttribute(ReverbSendGain.Gain, value);
			break;
		}
		case releaseTriggerButton:
		{
			MidiMuter.setAttribute(MidiMuter.ignoreButton, !value);
			break;
		}
		case predelayKnob:
		{
			ReverbSendGain.setAttribute(ReverbSendGain.Delay, value);
			break;
		}
		case reverbColourKnob:
		{
			SimpleReverb.setAttribute(SimpleReverb.Damping, value);
			break;
		}
		case clickAttackKnob:
		{
			MalletClick.setAttribute(MalletClick.Gain, value);
			break;
		}
		case modWheelAttKnob:
		{
			ModwheelHandler.setAttribute(ModwheelHandler.amount, value);
			break;
		}
		case noteOffButton:
		{
			MusicboxSamples.setAttribute(MusicboxSamples.OneShot, value);
			break;
		}
		case reverbSizeKnob:
		{
			SimpleReverb.setAttribute(SimpleReverb.RoomSize, value);
			break;
		}
	};
}
