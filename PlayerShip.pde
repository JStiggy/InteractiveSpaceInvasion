class PlayerShip {
  PImage playerSprite;
  float playerXPos;
  float playerYPos;
  float playerSpeed;
  float playerHealth;
  boolean hasShield;
  int playerScore;
  int playerRecharge;

  PlayerShip() {
    //Creates a Player ship that targets the nearest enemy ship, moves fast vertically, does not move horizontally
    playerXPos = 30;
    playerYPos = 360;
    playerHealth = 100;
    playerSpeed = 4;
    playerScore = 0;
    playerRecharge = 50;
    hasShield = false;
  }

  boolean movePlayer(Enemy ClosestTarget, float heatLvl) {
    playerRecharge++;
    //Player Moves towards the location of its current target
    if (playerTarget.enemyYPos < playerYPos) {
      playerYPos = playerYPos - playerSpeed;
    }
    if (playerTarget.enemyYPos > playerYPos) {
      playerYPos = playerYPos + playerSpeed;
    }
    if (playerYPos>690) {

      playerYPos = 670;
    }

    if (playerYPos<0) {
      playerYPos = 0;
    }

    if (playerTarget.enemyYPos <= playerYPos+5 && playerTarget.enemyYPos >= playerYPos-5) {
      image(loadImage("player.png"), playerXPos, playerYPos);
      deployShield();
      return true;
    }
    image(loadImage("player.png"), playerXPos, playerYPos);
    deployShield();
    return false;
  }

  boolean attackPlayer() {
    //When in range, the player fires a shot, undecided on interactivty of bullets and player
    if (playerRecharge >100) {
      playerRecharge = 0;
      return true;
    }
    return false;
  }

  void deployShield() {
    if (hasShield) {
      noFill();
      stroke(0, 0, 255);
      ellipse(playerXPos+25, playerYPos+25, 25, 25);
    }
  }
}

