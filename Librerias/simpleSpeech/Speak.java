package simpleSpeech;

import processing.core.*;
import com.sun.speech.freetts.Voice;
import com.sun.speech.freetts.VoiceManager;

public class Speak {
	PApplet parent;
	VoiceManager myVM;
	Voice myVoice;
	
	public Speak(PApplet parent) {
		this.parent = parent;
		parent.registerDispose(this);
		myVM = VoiceManager.getInstance();
		if (myVM==null) {
			System.err.println("Voice manager not available.");
			System.exit(1);
		}
		
		myVoice = myVM.getVoice("kevin16");
		if (myVoice==null) {
			System.err.println("Default voice not available.");
			System.exit(1);
		}
		myVoice.allocate();
	}
	
	public void speak(String _s) {
		myVoice.speak(_s);
	}
	
	public void dispose() {
		myVoice.deallocate();
	}
}
