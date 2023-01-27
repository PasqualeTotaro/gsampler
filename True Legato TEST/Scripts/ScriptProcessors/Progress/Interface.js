Content.makeFrontInterface(900, 900);





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
 