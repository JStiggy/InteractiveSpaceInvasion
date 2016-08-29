import processing.video.*;

int numPixels;
int[] backgroundPixels;
Capture video;

//Heat increases firing and movement speed for your ship and when over 
//50% you become immune to direct damage from ships and instead destroy them. However, if you hit 100%
//Ship overheats and you cannot deflect bullets until the percentage has droppped below 30%
//Heat also serves as a point multiplier.
float heatLevel;
boolean hasOverHeated;
boolean gameStart = false;
PImage uiMenu;
PImage differenceImage;
ArrayList<Bullet> allBullets = new ArrayList<Bullet>();
ArrayList<Enemy> allEnemies = new ArrayList<Enemy>();
int timer;
PlayerShip player;
Enemy playerTarget;


void setup() {
  size(1280, 720);
  uiMenu = loadImage("UI.png");
  video = new Capture(this, width, height);
  // Start capturing the images from the camera
  video.start();  
  numPixels = video.width * video.height;
  // Create array to store the background image
  backgroundPixels = new int[numPixels];
  // Make the pixels[] array available for direct manipulation
  differenceImage = createImage (1280, 720, RGB);
  differenceImage.loadPixels();
}

void draw() {
  if (!gameStart) {
    image(loadImage("startScreen.png"), 0, 0);
  } else {
    if (video.available()) {
      video.loadPixels();
      arraycopy(video.pixels, backgroundPixels);
      video.read(); // Read a new video frame
      video.loadPixels(); // Make the pixels of video available
      // Difference between the current frame and the stored background
      int presenceSum = 0;
      for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
        // Fetch the current color in that location, and also the color
        // of the background in that spot
        color currColor = video.pixels[i];
        color bkgdColor = backgroundPixels[i];
        // Extract the red, green, and blue components of the current pixel's color
        int currR = (currColor >> 16) & 0xFF;
        int currG = (currColor >> 8) & 0xFF;
        int currB = currColor & 0xFF;
        // Extract the red, green, and blue components of the background pixel's color
        int bkgdR = (bkgdColor >> 16) & 0xFF;
        int bkgdG = (bkgdColor >> 8) & 0xFF;
        int bkgdB = bkgdColor & 0xFF;
        // Compute the difference of the red, green, and blue values
        int diffR = abs(currR - bkgdR);
        int diffG = abs(currG - bkgdG);
        int diffB = abs(currB - bkgdB);
        // Add these differences to the running tally
        presenceSum += diffR + diffG + diffB;
        // Render the difference image to the screen
        differenceImage.pixels[i] = 0xFF000000 | (diffR << 16) | (diffG << 8) | diffB;
      }
      differenceImage.updatePixels(); // Notify that the pixels[] array has changed
      differenceImage = getReversePImage(differenceImage);
      // check brightness and destroy bullets
      if (allBullets.size() > 0 && !hasOverHeated) {
        for (int k = 0; k < allBullets.size (); k++) {
          int c=differenceImage.get((int)allBullets.get(k).bulletXPos, (int)allBullets.get(k).bulletYPos);
          float b=brightness (c);
          if (b>25)
          {
            allBullets.remove(k);
            heatLevel = heatLevel + 4;
          }
        }
      }
      image(differenceImage, 0, 0);
    }

    //Spawn enemies every set interval either vertically or horizontally;
    if (timer == 100 || timer == 35) {
      allEnemies.add(new Enemy(0, loadImage("horizShip.png")));
    }
    if (timer == 150) {
      allEnemies.add(new Enemy(1, loadImage("vertShip.png")));
    }
    if (timer == 170) {
      allEnemies.add(new Enemy(2, loadImage("waveShip.png")));
      timer = 0;
    }
    timer++;

    //Controls enemy movement, shooting, and despawning
    if (allEnemies.size()>0) {
      for (int i = 0; i< allEnemies.size (); i++) {
        allEnemies.get(i).moveEnemy();
        //Added these lines have not tested
        if (checkCollision(player, allEnemies.get(i))) {
          if (allEnemies.get(i) == playerTarget) {
            playerTarget = null;
          }
          allEnemies.remove(i);
          if (player.hasShield) {
            player.playerScore = (int)(player.playerScore + 10 + (heatLevel/10));
            heatLevel = heatLevel -5;
            if (heatLevel<0) {
              heatLevel = 0;
            }
          } else {
            player.playerHealth = player.playerHealth - 25;
          }
          continue;
        }      
        if (allEnemies.get(i).attackEnemy()) {
          allBullets.add(new Bullet(false, allEnemies.get(i).enemyXPos, allEnemies.get(i).enemyYPos, heatLevel, allEnemies.get(i).enemyForm));
        }
        if (allEnemies.get(i).despawnEnemy()) {
          if (allEnemies.get(i) == playerTarget) {
            playerTarget = null;
          }
          allEnemies.remove(i);
        }
      }
    }

    //Controls the movement, collision, and despawning of bullets
    if (allBullets.size()>0) {
      for (int i = 0; i< allBullets.size (); i++) {
        allBullets.get(i).moveBullet();
        if (allBullets.get(i).isPlayerBullet) {
          for (int j = 0; j < allEnemies.size (); j++) {
            if (j == allEnemies.size () || i == allBullets.size()) {
              break;
            }
            if (checkCollision(allBullets.get(i), allEnemies.get(j))) {
              if (allEnemies.get(j) == playerTarget) {
                playerTarget = null;
              }
              player.playerScore = player.playerScore + 100 + (int)heatLevel;
              allEnemies.remove(j);
              allBullets.remove(i);
            }
          }
        } else {
          if (checkCollision(allBullets.get(i), player)) {
            player.playerHealth = player.playerHealth-25;
            allBullets.remove(i);
          }
        }
        if (i == allBullets.size()) {
          break;
        }
        if (allBullets.get(i).despawnBullet()) {
          allBullets.remove(i);
        }
      }
    }
    //Finds a target for the player to attack, the ship will not change targets until the current ship has been destroyed
    if (playerTarget == null && allEnemies.size() >0) {
      int closestIndex = 0;
      float closestDistance = 2000;
      for ( int i=0; i< allEnemies.size (); i++) {
        if (allEnemies.get(i).enemyXPos < closestDistance && allEnemies.get(i).enemyXPos >400) {
          closestIndex = i;
          closestDistance = allEnemies.get(i).enemyXPos;
        }
      }
      playerTarget = allEnemies.get(closestIndex);
    }

    //Controls the player ships movement and attack.
    if (playerTarget != null) {
      if (player.playerHealth >0) {
        if (heatLevel >=50) {
          player.hasShield = true;
        } else {
          player.hasShield = false;
        }
        if (player.movePlayer(playerTarget, heatLevel)) {
          if (player.attackPlayer()) {
            allBullets.add(new Bullet(true, player.playerXPos, player.playerYPos, heatLevel, 3));
          }
        }
      } else {
        gameStart = false;
      }
    }
    if (heatLevel >100) {
      hasOverHeated = true;
    }
    if (heatLevel <=50 && hasOverHeated) {
      hasOverHeated = false;
    }
    displayUI();
  }
}
void displayUI() {
  textSize(15);
  fill(0);
  image(uiMenu, 1080, 0);
  player.playerHealth = player.playerHealth + .01;
  if (player.playerHealth > 100.9) {
    player.playerHealth = 100;
  }
  text("DURABILITY", 1100, 40);
  text((int)player.playerHealth, 1100, 70);

  text("SCORE", 1100, 170);
  text(player.playerScore, 1100, 200);
  player.playerHealth = player.playerHealth + .01;

  int redValue = (int)(255*(heatLevel/100));
  if (redValue > 255) {
    redValue = 255;
  }
  if (hasOverHeated) {
    fill(255, 0, 0);
    text("ERROR 274:",1100,410);
    text("OVERHEATED!", 1100, 440);
  }
  fill(redValue, 0, 0);
  text("HEAT LVL", 1100, 470);
  textSize(15 + 15*(heatLevel/100));
  text(String.format("%.2f", heatLevel) + "%", 1100, 500);
  heatLevel = heatLevel - .17;
  if (heatLevel < 0) {
    heatLevel = 0f ;
  }
}

boolean checkCollision(Bullet bul, Enemy ene) {
  if (ene.enemyXPos+15 < bul.bulletXPos)
    return false;
  if (ene.enemyXPos > bul.bulletXPos+15)
    return false;
  if (ene.enemyYPos+15 < bul.bulletYPos)
    return false;
  if (ene.enemyYPos > bul.bulletYPos +15)
    return false;
  return true;
}

boolean checkCollision(Bullet bul, PlayerShip pla) {
  if (pla.playerXPos+15 < bul.bulletXPos)
    return false;
  if (pla.playerXPos > bul.bulletXPos+15)
    return false;
  if (pla.playerYPos+15 < bul.bulletYPos)
    return false;
  if (pla.playerYPos > bul.bulletYPos +15)
    return false;
  return true;
}

boolean checkCollision(PlayerShip pla, Enemy ene) {
  if (pla.playerXPos+30 < ene.enemyXPos)
    return false;
  if (pla.playerXPos > ene.enemyXPos+30)
    return false;
  if (pla.playerYPos+30 < ene.enemyYPos)
    return false;
  if (pla.playerYPos > ene.enemyYPos +30)
    return false;
  return true;
}

PImage getReversePImage( PImage image ) {
  PImage reverse = new PImage( image.width, image.height );
  for ( int i=0; i < image.width; i++ ) {
    for (int j=0; j < image.height; j++) {
      reverse.set( image.width - 1 - i, j, image.get(i, j) );
    }
  }
  return reverse;
}

void keyPressed() {   
  timer = 0;
  playerTarget = null;
  player = new PlayerShip();
  heatLevel = .0f;
  hasOverHeated = false;
  allBullets.clear();
  allEnemies.clear();
  gameStart = true;
}

