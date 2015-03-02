import ddf.minim.*;
import ddf.minim.analysis.*;
 
Minim minim;
AudioPlayer song;
FFT fft;
 
void setup()
{
  size(displayWidth, displayHeight, P3D);
 
  minim = new Minim(this);
 
 int bufferSize = 2048;
  song = minim.loadFile("mysong.mp3", bufferSize); 
  song.play();
 
  // an FFT needs to know how 
  // long the audio buffers it will be analyzing are
  // and also needs to know 
  // the sample rate of the audio it is analyzing
  fft = new FFT(song.bufferSize(), song.sampleRate());

  lights();
  camera(width/8, height/8, (height/2.0) / tan(PI*30.0 / 180.0), width/2, height/2, 0, 0, 1, 0);

}
 
void draw()
{
  background(0);

  
  // first perform a forward fft on one of song's buffers
  // I'm using the mix buffer
  //  but you can use any one you like
  fft.forward(song.mix);
 
  stroke(255);
  strokeWeight(3);
  // draw the spectrum as a series of vertical lines
  // I multiple the value of getBand by 4 
  // so that we can see the lines better
  
  // between x cordinate 0 and the 
  for(int shiftX = 0; shiftX < fft.specSize(); shiftX = shiftX+10) // shiftX+10 Controls a sequence of repeated 
  
  {
    
    float amplitude = fft.getBand(shiftX)*4;
    
    float amplitudeNormalised = 90*amplitude/(height/2);
    
    //TOP - RIGHT
    line(width/2 + shiftX/2, height/2, width/2 + shiftX/2, height/2 - amplitudeNormalised);
    
    //Bottom - LEFT
    line(width/2 + shiftX/2, height/2, width/2+ shiftX/2, height/2 + amplitudeNormalised);

    //TOP - LEFT
    line(width/2 - shiftX/2, height/2, width/2 - shiftX/2, height/2 - amplitudeNormalised);

    //Bottom - RIGHT
    line(width/2 - shiftX/2, height/2, width/2 - shiftX/2, height/2 + amplitudeNormalised);   
  }
  

  
 //WAVEFORMS
  stroke(255);
    strokeWeight(0.5);
  // I draw the waveform by connecting 
  // neighbor values with a line. I multiply 
  // each of the values by 50 
  // because the values in the buffers are normalized
  // this means that they have values between -1 and 1. 
  // If we don't scale them up our waveform 
  // will look more or less like a straight line.
  for(int i = 0; i < song.left.size() - 1; i++)
  {
    // LEFT
    stroke(255,255,255,100);
    line(i, height/2 + song.left.get(i)*50, i+1, height/2 + song.left.get(i+1)*50);
    
    // RIGHT
    stroke(255,255,255,100);
    line(i, height/2 + song.right.get(i)*50, i+1, height/2 + song.right.get(i+1)*50);
  }
  
  
}
