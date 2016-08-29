class Bullet {
  //PImage projectile;
  float bulletXPos;
  float bulletYPos;
  float bulletXSpeed;
  float bulletYSpeed;
  double waveTimer;
  boolean waveBullet;
  boolean isPlayerBullet;

  Bullet(boolean boolBullet, float bXPos, float bYPos, float heatLev, int formNumber) {
    isPlayerBullet = boolBullet;
    waveBullet = false;
    waveTimer  = 0;
    bulletXPos = bXPos;
    bulletYPos = bYPos+12;
    if (isPlayerBullet) {
      bulletXSpeed = 7 + (int)(7 * heatLev/100);
    } else if (formNumber !=2) {
      bulletXSpeed = -5;
    } else {
      waveBullet = true;
      bulletYPos = bulletYPos +20;
      bulletXSpeed = -3;
      bulletYSpeed = -3;
    }
  }

  void moveBullet() {
    //Moves the bullet based on its x and y speeds, checks collision and prints
    if (waveBullet) {
      waveTimer = waveTimer +.2;
      bulletXPos = bulletXPos + bulletXSpeed;
      bulletYPos = bulletYPos + bulletYSpeed * (float)(5*Math.sin(waveTimer));
    } else {
      bulletXPos = bulletXPos + bulletXSpeed;
    }
    image(loadImage("bullet.png"), bulletXPos, bulletYPos);
  }

  boolean despawnBullet() {
    //Clears the bullet if it hits anything or exits the screen
    if (bulletXPos > width+60 || bulletXPos <-60 || bulletYPos >height+60 || bulletYPos <-60) {
      return true;
    }
    return false;
  }
}

