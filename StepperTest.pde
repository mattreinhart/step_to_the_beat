// Adafruit Motor shield library
// copyright Adafruit Industries LLC, 2009
// this code is public domain, enjoy!

#include <AFMotor.h>

AF_Stepper motor(48, 2);

void setup() {
  Serial.begin(115200);    // set up Serial library at 115200 bps
  Serial.println("Step to the beat!");

  motor.setSpeed(100);  // 100 rpm   
}

char val;

void loop() {

    int number = read_serial();
    
    if (number > 0){
      Serial.println("Stepping right.");
      motor.step(number, FORWARD, SINGLE);
    
    } else if (number < 0) {
      number *= -1;
      Serial.println("Stepping left.");
      motor.step(number, BACKWARD, SINGLE);
    }
    
    motor.release();
}

int read_serial(){
  if(Serial.available())
  {
    val = Serial.read();
  
    int number = 0;
    
    if(val == 'R'){
      
      do{
        if(Serial.available())
        {
          val = Serial.read();
          
          if (val != ';'){
            number *= 10;
            number += atoi(&val);
          }
        }
      } while (val != ';');
    
    } else if(val == 'L'){
            
      do{
        if(Serial.available())
        {
          val = Serial.read();
          
          if (val != ';'){
            number *= 10;
            number += atoi(&val);
          }
        }
      } while (val != ';');
      
      number *= -1;
    
    }
    
    return number;
    
  } else {
    return 0;
  }
}

