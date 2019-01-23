// IMPORTED --------------------------------------------------
/*
 Importing packages essentially gives JAVA a hint about what pieces
 of code external to this file itself may be referenced further down.
 */
// SOUND
import ddf.minim.*;
import ddf.minim.analysis.*;

// NETWORK
//import ciid2015.exquisitdatacorpse.*;
import oscP5.*;
import netP5.*;

// TIME
import java.util.Calendar;



// DECLARED --------------------------------------------------
/*
 Declaring an object or a variable means letting JAVA know that
 there is a need to store some kind of data for this program to work. What kind of
 data is actually to be stored is defined by the first word of the declaration. It could be of
 three types:
 
 1) Simple JAVA type variable (int, float, double, long, char, boolean) - occupies very little space in RAM memory and is very simplistic - just stores its value and allows to update it if needed.
 2) Object - topic of objects is a separate one, but in short they are more complex than simple type variables in that they themselves may be composed of other variables and Objects and have methods that can manipulate with data passed to them.
 3) Arrays - collections of many simple variables or Objects. Specified by adding square brackets after the type’s name
 
 After the type of the object or variable comes the name of it so that its value may be referenced using that name further in code.
 */
NetworkClient mClient;
Minim minim;
AudioPlayer song;
FFT fft;
int specSize = 0;
int myPointer = 0;
float [][] myBuffer; // Declaring an array of floats which will be called myBuffer. At this point we didn’t yet specify its size.
int pIng = 0;
int drawCount = 0;
int currentSongKey = 0;
String [] songTitles;
PFont my_font; // FONT // Decaring an object of PFont class.
int value = 0; // CLICK CHANGE


// SETUP -----------------------------------------------------
/*
As by how Processing is built, setup method is called automatically when the program starts. This is a good place to initialize variables and Objects (initialization involves supplying default values to variables, if needed, and actually creation Object instances (because when we declared them we simply informed JAVA that we will need space for them in future - instantiating is about actually filling that empty space with an object
*/
void setup() {
  size(displayWidth, displayHeight, P3D);
  frameRate(30);

  // FONT/TYPEFACE ---------------------------------------------------
 
  /* here we instantiate my_font object by calling loadFont method. Processing makes this method available to us directly without the need to reference it though any object. */
  my_font=loadFont("DINPro-Light-48.vlw");
  textAlign(CENTER);
  textFont(my_font, 60);
 
  /*
  But often we would need to call a method through the object it belongs to first specifying object’s name, then writing a dot, then method name, and method arguments in parentheses, comma-separated.
 
   Example:
   int strLength = someStringObjectName.length()
  
   In this example we wanted to find out the length of string hidden behind the someStringObjectName object. Length method happens to accept no arguments, but we still had to put parentheses - otherwise JAVA would start looking for a variable called “length” inside someStringObjectName object
   */




  //// NETWORK ------------------------------------------------------------
  ///*
  //    create a client that connects to the server `edc.local` and specify
  // `client` as the sender.
  
  // network party knowledge: if the server is run on the same machine as
  // the sketch you can also specify the server as `localhost` or with the
  // ip address `127.0.0.1.`
  // */
  ///*
  // Below we instantiate an object by calling its constructor method. Constructor method always has the same name as the Class name of the object and is always returning an object instance of that class. In this particular case NetworkClient is expecting to get three arguments from us to build NetworkClient object. We must provided all of them unless there is another NetworkClient method written by a developer that accepts different number or different kinds of arguments.
  // */
  //mClient = new NetworkClient(this, "edc.local", "client");
  //// SETUP SONG LIST
  //songTitles = new String[5]; // Here we instantiate an array of String objects and say that it will hold up to 5 elements.
  //songTitles[0] = "Prokofiev-Montagues And Capulets.mp3"; // here we assign value to the first element (we begin with 0) of the above array
  //setupSong(songTitles[currentSongKey]); // Here we call a method we ourselves wrote down below




  // CAMERA --------------------------------------
  camera(width/2, height/2-600, (height/2.0f) / tan(PI*30.0f / 180.0f), width/2, height/2, 0, 0, 1, 0);
}
  // PLAYER /SONG----------------------------------
 
  // below we “clean up” after ourselves - if our previous song is still playing we want to stop that and release the song file so it doesn’t occupy our RAM
void setupSong(String fileName) {
  if (minim != null && song != null && song.isPlaying()) {
    song.close();
    minim.stop(); // Stop current song, releasing the file
  }
  minim = new Minim(this);
  int bufferSize = 2048;
  song = minim.loadFile(fileName, bufferSize);
  song.play();
  /*
  song = minim.getLineIn(minim.STEREO, 64);
   an FFT needs to know how
   long the audio buffers it will be analyzing are
   and also needs to know
   the sample rate of the audio it is analyzing
   */
  fft = new FFT(song.bufferSize(), song.sampleRate());
  specSize = fft.specSize();
  myBuffer = new float[61][specSize]; // instantiate (or re-instantiate, if this is called from the bottom button) the frequencies buffer
}

// DRAW LOOP --------------------------------------------------------------
// Processing calls draw method according to the frame rate we specified earlier.
void draw()
{
  background(0);
  lights();

  // TEXT --------------------------------------------------------------------------------------
  fill(255, 255, 255, 225);
  textSize(48);
  text("Song: "+ songTitles[currentSongKey].substring(0, (songTitles[currentSongKey].lastIndexOf("."))), width/2, 200, -1200);
/*
  fill(255, 255, 255, 225);
  textSize(34);
  text(("+"+pIng +" Network Activity "+" Converted To "+ song.getGain() +" Gain Level"), width/2, 250, -1200);
*/
  fill(255, 255, 255, 225);
  textSize(34);
  text((String.format("%02d", (song.position()/1000)/60)+":"+String.format("%02d", (song.position()/1000)%60)+ "." + String.format("%03d", song.position()%1000)), width/2, 300, -1200);
  pushMatrix();
  translate(0, 0, 1600);
  fill(255, 255, 255, 225);
  textSize(22);
  text("[ >> ]", width/2, 550, -1200);
  popMatrix();

  //--------------------------------------------------------------------------------------------

  // MILLISECONDS
  /* here is an example of getting an object instance not from a class Constructor, but from a Static method of that class. Static method does not require you to instantiate an object of its Class in order to be called - you can reference such method by typing class name instead of object name */
  Calendar cal = Calendar.getInstance();
  int remainder = ((cal.get(Calendar.MILLISECOND)) + (cal.get(Calendar.SECOND)*1000)) % 20001;

  // TRANSLATE
  translate(width/2, 0, 0);
  //rotateY(2*mouseY/(float)height * PI); // this will move it according to Moyse Y position
  rotateY(map(remainder, 0, 20000, 0, 2*PI));// Notice that we rotate our workspace below. This allows us to keep the same x/y/z calculations for all our visual objects on the screen.
  /*
   first perform a forward fft on one of song's buffers
   I'm using the mix buffer
   but you can use any one you like
   */
  fft.forward(song.mix);
  /* draw the spectrum as a series of vertical lines
   I multiple the value of getBand by 4
   so that we can see the lines better
   */
  strokeWeight(2);
  float[] myAmps = new float[specSize];
  for (int iterationCount = 0; iterationCount < specSize; iterationCount = iterationCount+20) { // shiftX+10 Controls a sequence of repeated
    myAmps[iterationCount] = fft.getFreq(iterationCount);
  }
  myBuffer[myPointer] = myAmps;
  myPointer++;
  myPointer=myPointer%myBuffer.length;
  // between x cordinate 0 and the
  for (int shiftX = 0; shiftX < specSize; shiftX = shiftX+20) { // shiftX+10 Controls a sequence of repeated
    //float amplitude = fft.getBand(shiftX)*4;
    for (int i = 0; i < myBuffer.length; i++) {
      int j = i + myPointer;
      j%=myBuffer.length;
      float amplitude = 0;
      if (myBuffer[j] != null) {
        amplitude = myBuffer[j][shiftX];
      }
      float amplitudeNormalised1 = 180*amplitude/(height/2);
      float deGrade = (70-(float)Math.abs(i-60))/70; // we wanted to keep this value between 0 and 1 so we decrease the number that gets multiplied by thus degrade. For that reason the use of number 70 depends on how many visual “lines” we draw (61 at the moment)
      float deGrade2 = deGrade*deGrade;
      float amplitudeNormalised = amplitudeNormalised1*deGrade;
      int displace = 0;
      /*
 Code below is used to shift lines in Z axis so that had of them are in negative Z and other half is in positive Z.
 That way we make sure our rotation seem to happen around the middle 
       */
      if (i<31) {
        displace = (31 - i) * 10;
      } else if (i>31) {
        displace = (i - 31) * -10;
      } else {
        displace = 0;
      }
      // FREQUENCY BARS ------------------------------------------------
      //TOP - RIGHT
      stroke(255, 255, 255, 200*deGrade2);
      line(shiftX/4, height/3, displace, shiftX/4, height/3 - amplitudeNormalised, displace);
      //TOP - LEFT
      stroke(255, 255, 255, 200*deGrade2);
      line(-shiftX/4, height/3, displace, -shiftX/4, height/3 - amplitudeNormalised, displace);

      //Bottom - LEFT
      stroke(255, 255, 255, 50*deGrade2);
      line(shiftX/4, height/3, displace, shiftX/4, height/3 + amplitudeNormalised, displace);
      //Bottom - RIGHT
      stroke(255, 255, 255, 50*deGrade2);
      line(-shiftX/4, height/3, displace, -shiftX/4, height/3 + amplitudeNormalised, displace);
    }
  }

  //WAVEFORMS -------------------------------------------------
  /*
   I draw the waveform by connecting
   neighbor values with a line. I multiply
   each of the values by 50
   because the values in the buffers are normalized
   this means that they have values between -1 and 1.
   If we don't scale them up our waveform
   will look more or less like a straight line.
   */

  /*
   stroke(255);
   strokeWeight(0.5f);
  
   for(int i = 0; i < song.left.size() - 1; i++)
  
   {
  
   // LEFT
   stroke(255,255,255,100);
   line(i, height/6 + song.left.get(i)*50, i+1, height/6 + song.left.get(i+1)*50);
  
   // RIGHT
   stroke(255,255,255,100);
   line(i, height/3 + song.right.get(i)*50, i+1, height/3 + song.right.get(i+1)*50);
  
   }
   */

  // REWIND MUSIC ---------------------------
  if (!song.isPlaying()) {
    song.rewind();
    song.play();
  }
}

// MOUSE PRESS -----------------------------
void mousePressed() {
  if (mouseX < 1035 && mouseX > 875 && mouseY < 815 && mouseY > 765) {
    currentSongKey = currentSongKey + 1;
    currentSongKey %= songTitles.length;
    setupSong(songTitles[currentSongKey]);
  }
}

// RECEIVE ------------------------------------------------------------------
/*
 if the following three `receive` methods are implemented they will be
 called in case a message from the server is received with eiter one, two
 or three parameters.
 */

void receive(String name, String tag, float x) {
  pIng = pIng+1;
  //println("### received: " + name + " - " + tag + " - " + x);
 
}
void receive(String name, String tag, float x, float y) {
  pIng = pIng+1;
  //println("### received: " + name + " - " + tag + " - " + x + ", " + y);
 
}
void receive(String name, String tag, float x, float y, float z) {
  pIng = pIng+1;
  //println("### received: " + name + " - " + tag + " - " + x + ", " + y + ", " + z);
 
}
