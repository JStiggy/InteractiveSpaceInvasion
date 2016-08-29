class Enemy {
  PImage enemyShip;
  int enemyForm;
  float enemyXPos;
  float enemyYPos;
  float enemyXSpeed;
  float enemyYSpeed;
  float enemyFireRecharge;
  int attackRecharge;

  Enemy(int form, PImage eneShip) {
    //Accepts a spawn type and creates an enemy, its starting position, its speed, and point value.
    enemyShip = eneShip;
    enemyForm = form;
    if (form  == 0) {
      enemyXPos = 1100;
      enemyYPos = (int)random(50, 668);
      enemyXSpeed = -2;
      enemyYSpeed = 0;
    } else if (form == 1) {
      enemyYPos = -50;
      enemyXPos = random(750, 1000);
      enemyXSpeed = 0;
      enemyYSpeed = 5;
    } else if (form == 2) {
      enemyXPos = 1100;
      enemyYPos = (int)random(50, 668);
      enemyXSpeed = -1;
      enemyYSpeed = 0;
    }

    enemyFireRecharge = random(200, 500);
    attackRecharge = (int)(enemyFireRecharge / 2);
  }

  void moveEnemy() { 
    //Moves  the enemy based on its speed
    enemyXPos = enemyXPos + enemyXSpeed;
    enemyYPos = enemyYPos + enemyYSpeed;
    image(enemyShip, enemyXPos, enemyYPos);
  }

  boolean attackEnemy() {
    //The enemey fires a bullet based on their value fire recharge value
    attackRecharge = attackRecharge + (int)random(1, 5);
    if (attackRecharge > enemyFireRecharge && enemyXPos >325) {
      attackRecharge = 0;
      return true;
    }
    return false;
  }

  boolean despawnEnemy() {
    //Removes the enemy if it goes out of bounds, does not earn the player points this way
    if (enemyXPos <-60 || enemyYPos >height+60 || enemyYPos <-60) {
      return true;
    }
    return false;
  }
}

