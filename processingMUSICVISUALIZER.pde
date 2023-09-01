// Import necessary libraries
import ddf.minim.*;
import ddf.minim.analysis.*;
import oscP5.*;
import netP5.*;
import java.util.Calendar;


// Declare global variables
Minim minim;           // Audio library
AudioPlayer song;      // Audio player
FFT fft;               // Fast Fourier Transform for audio analysis
int specSize = 0;      // Size of the audio spectrum
int myPointer = 0;     // Index for storing audio data
float [][] myBuffer;   // Buffer for storing audio data
int pIng = 0;           // Unused variable
int drawCount = 0;     // Unused variable
int currentSongKey = 0; // Index of the current song
String [] songTitles;   // Array to hold song file names
// PFont my_font; // Commented out the font loading to avoid NullPointerException
int value = 0;          // Unused variable



void setup() {
  // Set up the canvas size and frame rate
  size(1080, 640, P3D); // Canvas size is 1200x1200 pixels in 3D mode
  frameRate(30); // Set the frame rate to 30 frames per second

  // Initialize songTitles with actual song file names
  songTitles = new String[]{
  "audio/01_bicep_glue.mp3",
  "audio/02_djt_patci.mp3",
  "audio/03_roman_flugel_wilkie.mp3"
};

  // Initialize audio and load the first song
  setupSong(songTitles[currentSongKey]);
}

void setupSong(String fileName) {
  // Close the current song and audio resources if they exist
  if (minim != null && song != null && song.isPlaying()) {
    song.close(); // Close the current audio player
    minim.stop(); // Stop the audio system
  }

  // Initialize Minim audio library
  minim = new Minim(this);

  // Set the audio buffer size
  int bufferSize = 2048;

  // Load the audio file
  song = minim.loadFile(fileName, bufferSize);
  // Start playing the loaded audio
  song.play();

  // Initialize FFT for audio analysis
  fft = new FFT(song.bufferSize(), song.sampleRate());
  specSize = fft.specSize();

  // Initialize the buffer for storing audio data
  myBuffer = new float[61][specSize];
}

void draw() {
  // Set the background color to black
  background(0);
  lights();

  // -------------------------------------------------------------
 //TEXT
  pushMatrix();
    translate(0, -500, 0); // Translate the coordinate system
  // Display the song name
  fill(255, 255, 255, 225); // Fill color is white with transparency
  textAlign(CENTER); // Align text to the middle horizontally
  textSize(64); // Set text size to 48
  // Display the song name at a specific position on the canvas
  text("Song: " + songTitles[currentSongKey].substring(0, (songTitles[currentSongKey].lastIndexOf("."))), width/2, 0, -1200);

  // Display the current time in the song
  fill(255, 255, 255, 128); // Fill color is white with transparency
  textSize(56); // Set text size to 32
  // Display the current time in the song at a specific position on the canvas
  textAlign(CENTER); // Align text to the middle horizontally
  text((String.format("%02d", (song.position()/500)/60) + ":" + String.format("%02d", (song.position()/1000)%60) + "." + String.format("%03d", song.position()%1000)), width/2, 75, -1200);
  popMatrix(); // Pop the previous coordinate transformation

  // -------------------------------------------------------------
  // GRAPH
  // Draw a UI element
  pushMatrix();
  translate(0, 0, 1600); // Translate the coordinate system
  fill(255, 255, 255, 225); // Fill color is white with transparency
  textSize(22); // Set text size to 22
  text("[ >> ]", width/2, 550, -1200); // Display "[ >> ]" at a specific position on the canvas
  popMatrix(); // Pop the previous coordinate transformation

  // Get the current time and calculate a remainder
  Calendar cal = Calendar.getInstance();
  int remainder = ((cal.get(Calendar.MILLISECOND)) + (cal.get(Calendar.SECOND)*1000)) % 20001;

  // Translate and rotate the scene based on the remainder
  translate(width/2, height/3, 0); // Translate the coordinate system to the center of the canvas
  rotateY(map(remainder, 0, 20000, 0, 2*PI)); // Rotate around the Y-axis based on the remainder

  // Perform FFT analysis on the audio
  fft.forward(song.mix);

  // Set the stroke weight for drawing lines
  strokeWeight(2);

  // Create an array to store audio amplitudes
  float[] myAmps = new float[specSize];

  // Loop through the audio spectrum
  for (int iterationCount = 0; iterationCount < specSize; iterationCount = iterationCount+20) {
    myAmps[iterationCount] = fft.getFreq(iterationCount); // Get the frequency data
  }

  // Store the audio amplitudes in the buffer
  myBuffer[myPointer] = myAmps;
  myPointer++;
  myPointer = myPointer % myBuffer.length;

  // Loop through the spectrum and draw lines based on audio amplitudes
  for (int shiftX = 0; shiftX < specSize; shiftX = shiftX+20) {
    for (int i = 0; i < myBuffer.length; i++) {
      int j = i + myPointer;
      j %= myBuffer.length;
      float amplitude = 0;

      // Check if audio data is available in the buffer
      if (myBuffer[j] != null) {
        amplitude = myBuffer[j][shiftX]; // Get the amplitude for a specific frequency band
      }

      // Normalize the amplitude and calculate line position and length
      float amplitudeNormalized1 = 180 * amplitude / (height/2);
      float deGrade = (70 - (float) Math.abs(i - 60)) / 70;
      float deGrade2 = deGrade * deGrade;
      float amplitudeNormalized = amplitudeNormalized1 * deGrade;
      int displace = 0;

      // Calculate horizontal displacement for drawing lines
      if (i < 31) {
        displace = (31 - i) * 10;
      } else if (i > 31) {
        displace = (i - 31) * -10;
      } else {
        displace = 0;
      }

      // Draw lines based on audio amplitudes
      stroke(255, 255, 255, 200*deGrade2); // Set stroke color with transparency
      // Draw a line from one point to another
      line(shiftX/4, height/3, displace, shiftX/4, height/3 - amplitudeNormalized, displace);

      stroke(255, 255, 255, 200*deGrade2); // Set stroke color with transparency
      // Draw a line from one point to another
      line(-shiftX/4, height/3, displace, -shiftX/4, height/3 - amplitudeNormalized, displace);

      stroke(255, 255, 255, 50*deGrade2); // Set stroke color with transparency
      // Draw a line from one point to another
      line(shiftX/4, height/3, displace, shiftX/4, height/3 + amplitudeNormalized, displace);

      stroke(255, 255, 255, 50*deGrade2); // Set stroke color with transparency
      // Draw a line from one point to another
      line(-shiftX/4, height/3, displace, -shiftX/4, height/3 + amplitudeNormalized, displace);
    }
  }

  // Check if the song is not playing, rewind and play it
  if (!song.isPlaying()) {
    song.rewind(); // Rewind the song to the beginning
    song.play();   // Start playing the song
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == RIGHT) {
      // Right arrow: Increment the current song index
      currentSongKey = (currentSongKey + 1) % songTitles.length;

      // Load and play the new song
      setupSong(songTitles[currentSongKey]);
    } else if (keyCode == LEFT) {
      // Left arrow: Decrement the current song index
      currentSongKey = (currentSongKey - 1 + songTitles.length) % songTitles.length;

      // Load and play the new song
      setupSong(songTitles[currentSongKey]);
    }
  }
}

void mousePressed() {
  // Check if the mouse is within a specific area and change the current song
  if (mouseX < 1035 && mouseX > 875 && mouseY < 815 && mouseY > 765) {
    currentSongKey = currentSongKey + 1; // Increment the current song index
    currentSongKey %= songTitles.length; // Wrap around if the index exceeds the number of songs
    setupSong(songTitles[currentSongKey]); // Load and play the new song
  } else {
    // Calculate rotation angles based on mouse coordinates
    float angleX = map(mouseX, 0, width, -PI, PI); // Map mouse X position to rotation angle around X-axis
    float angleY = map(mouseY, 0, height, -PI, PI); // Map mouse Y position to rotation angle around Y-axis

    // Rotate the scene based on mouse coordinates
    rotateX(angleX); // Rotate around the X-axis
    rotateY(angleY); // Rotate around the Y-axis
  }
}
