  
import processing.sound.*;

final int X = 150;
final int Y = 100;
final int boxSize = 10;

int turnLenght = 100; // how many miliseconds each turn takes
int beatInterval = 8;
int lastUpdateTime = 0;

int currentTurn = 0;
int scoreBlockTurnInterval = 1;
int lastScoreBlockTurn = 0;

int maxBadBlocks = 500;

int topScore = 0;

final color onBoxColor = color(255);
final color offBoxColor = color(50);
final color pointColor = color(0,175,0);
final color badBlockColor = color(200,0,0);

boolean paused = false;
boolean started = false;
boolean gameOver = false;

// if a box has a zero value it has offBoxColor, else onBoxColor
int [][] boxes = new int [X][Y];

SoundFile startSound;
SinOsc eat1 = new SinOsc(this);
SinOsc eat2 = new SinOsc(this);
TriOsc triangle = new TriOsc(this);
TriOsc death = new TriOsc(this);


void PlayEatSound() {
  
  triangle.play();
  eat1.stop();
  eat2.stop();
   eat1.play(200, 0.2);
  eat2.play(205, 0.2);
  
}

void PlayDeathSound() {
  death.play();
  delay(1000);
  death.stop();
}

class Snake {
 
  int direction = 1; // 1 = up , 2 = right, -1 = down, -2 = left
  int x_pos, y_pos;
  int score = 0;
  int size = 1;
  
  public Snake() {
  }
  
  public void ChangeDirection(int dir) {
   if(dir == -this.direction) {
    return; // we can not turn around in place 
   }
   direction = dir;
  }
  
  public int GetScore() {
   return score; 
  }
  
  public void Reset() {
    direction = 1;
    x_pos = X/2;
    y_pos = Y/2;
    score = 0;
    size = 1;
  }
  
  public void AdvanceTurn() {
    // check which direction we are going
    int x_next = x_pos;
    int y_next = y_pos;
    
    switch(direction) {
     case 1:
     y_next += 1;
     if(y_next >= Y) {
      y_next = 0; 
     }
     break;
     case 2:
     x_next += 1;
     if(x_next >= X) {
      x_next = 0; 
     }
     break;
     case -1:
     y_next -= 1;
     if(y_next < 0) {
      y_next = Y-1; 
     }
     break;
     case -2:
     x_next -= 1;
     if(x_next < 0) {
      x_next = X-1; 
     }
     break;
     default:
     break;
    }
    
    // check if we have a collision - if so game over, show score
    if(boxes[x_next][y_next] > 0 || boxes[x_next][y_next] < -1) {
     gameOver = true;
     PlayDeathSound();
     return;
    }
    else if(boxes[x_next][y_next] == -1) {
     // we picked up a score, add to score and increase our size
     score += 10;
     size++;
     maxBadBlocks++;
     turnLenght--;
     if(turnLenght == 0) {
       // you win!!
       gameOver = true;
       PlayDeathSound();
     return;
     }
     PlayEatSound();
    }
    
    // no collision, move the snake head position
    boxes[x_next][y_next] = size+1;
    
    x_pos = x_next;
    y_pos = y_next;
  }
}

// this function updates our grid state, called once a turn
void UpdateGrid() {
  for (int i = 0; i< boxes.length; i++) {
    for (int j = 0; j < boxes[i].length; j++) {
      if(boxes[i][j] > 0) {
        boxes[i][j]--;
      }
      else if(boxes[i][j] < -1) {
        boxes[i][j]--;
        if(boxes[i][j] < 0-maxBadBlocks) {
          boxes[i][j] = 0; // reset
        }
      }
    } 
  }  
}

void ResetGrid() {
    for (int i = 0; i< boxes.length; i++) {
    for (int j = 0; j < boxes[i].length; j++) {
      boxes[i][j] = 0;
    } 
  }
  maxBadBlocks = 500;
}

void AddScoreBlocks() {
  int x = int(random(0,X-1));
  int y = int(random(0,Y-1));
  
  if(boxes[x][y] == 0) {
    boxes[x][y]--;
  }
}

void AddBadBlocks() {
  int x = int(random(0,X-1));
  int y = int(random(0,Y-1));
  
  if(boxes[x][y] == 0) {
    boxes[x][y]=-2;
  }
}

void settings() {
  //this should be here
  size(X * boxSize, Y * boxSize);
}

Snake s;
void setup() {
  for (int i = 0; i< boxes.length; i++) {
    for (int j = 0; j < boxes[i].length; j++) {
      boxes[i][j] = 0;
    }
  }
 //eatSound = new SoundFile(this,"t.wav"); //<>//
  s = new Snake();
  startSound = new SoundFile(this,"intro.wav");
  death.freq(200);
  // place the snake starting in the middle
}



void draw() {
  for (int i = 0; i< boxes.length; i++) {
    for (int j = 0; j < boxes[i].length; j++) {
      int x = i * boxSize;
      int y = j * boxSize;
      
      if(boxes[i][j] > 0) {
       fill(onBoxColor);
      }
      else if (boxes[i][j] == -1) {
        fill(pointColor);
      }
      else if (boxes[i][j] < -1) {
        fill(badBlockColor);
      }
      else {
        fill(offBoxColor);
      }
      stroke(0);
      rect (x, y, boxSize, boxSize);
    }
  }
  if(gameOver) {
     PFont font;
    font = loadFont("ARDESTINE-96.vlw");
    textFont(font);
    fill(255, 184, 75);
    textAlign(CENTER, CENTER);
    textSize(84);
    text("--- Game Over ---", ((X-0)*boxSize)/2,((Y-50)*boxSize)/2);
    text(String.format("Your Score is %d",s.GetScore()), ((X-0)*boxSize)/2,((Y-25)*boxSize)/2);
    if(s.GetScore() > topScore) {
     topScore = s.GetScore();
    }
    if(topScore == s.GetScore()) {
    text("Congratulations, you got top score!", ((X-0)*boxSize)/2,((Y)*boxSize)/2);
    }
    text(String.format("Total Turns Survived: %d",currentTurn), ((X-0)*boxSize)/2,((Y+25)*boxSize)/2);
    text("Press Enter to Play again", ((X-0)*boxSize)/2,((Y+50)*boxSize)/2);
   return;
  }
  if(!started) {
    PFont font;
    font = loadFont("ARDESTINE-96.vlw");
    textFont(font);
    textSize(128);
    fill(255, 184, 75);
    textAlign(CENTER, CENTER);
    text("--- Snake ---", ((X-0)*boxSize)/2,((Y-(Y/2))*boxSize)/2);

    textSize(96);
    text(String.format("Top Score: %d",topScore), ((X-0)*boxSize)/2,((Y-(Y/4))*boxSize)/2);
    
    text("Press Enter to Start", ((X-0)*boxSize)/2,((Y-0)*boxSize)/2);
   // show start screen 
   return;
  }
  if(paused) {
     PFont font;
    font = loadFont("ARDESTINE-96.vlw");
    textFont(font);
    fill(255, 184, 75);
    textAlign(CENTER, CENTER);
    textSize(96);
    text("--- Paused ---", ((X-0)*boxSize)/2,((Y-50)*boxSize)/2);
    text(String.format("Current Score: %d",s.GetScore()), ((X-0)*boxSize)/2,((Y-25)*boxSize)/2);
    text("Press Enter to Continue", ((X-0)*boxSize)/2,((Y-0)*boxSize)/2);
    text("Press Backspace to Restart", ((X-0)*boxSize)/2,((Y+25)*boxSize)/2);
   return;
  }
  
  // all state updates below
  int time_now = millis();
  if(time_now > turnLenght + lastUpdateTime) {
    
    // time for a state update
    lastUpdateTime = time_now;
    currentTurn++;

    if(currentTurn > lastScoreBlockTurn + scoreBlockTurnInterval) {
      lastScoreBlockTurn = currentTurn;
      AddScoreBlocks();
      AddBadBlocks();
      triangle.stop();
    }

    s.AdvanceTurn();
    UpdateGrid();
  }
}

void keyPressed() {
 if(key == ENTER) {
  // should start/pause the game
  
  if(gameOver) {
   // enter will put us back to start screenwa
   ResetGrid();
   s.Reset();
   started = false;
   gameOver = false;
   startSound.play();
   return;
  }
  
  if(!started) { //<>//
   ResetGrid();
   s.Reset();
   currentTurn = 0;
   lastUpdateTime = millis();
   lastScoreBlockTurn = 0;
   turnLenght = 100;
   started = true;
   int i = 0;
   while(i < 1500) {
      AddScoreBlocks();
      i++;
   }
   startSound.play();
   return;
  }
  else {
   paused = !paused;
   triangle.stop();
   return;
  }
 }
 if(key == BACKSPACE) {
   // only if we are paused
   if(paused) { //<>//
      ResetGrid();
     s.Reset();
     started = false;
     gameOver = false;
     paused = false;
     return;
   }
 }
 if(!started) {
  return; 
 }
 // controls 
 if(key == 'w' || key == 'W') {   
   s.ChangeDirection(-1);
 } 
 if(key == 'a' || key == 'A') {
    s.ChangeDirection(-2);
  }
  if(key == 's' || key == 'S') {
    s.ChangeDirection(1);
  }
  if(key == 'd' || key == 'D') {
  s.ChangeDirection(2);
  }
}
