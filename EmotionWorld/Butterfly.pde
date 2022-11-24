public class Butterfly{
    Wing[] wing;
    ParticleSystem ps;

    PVector location;
    PVector velocity;
    PVector acceleration;
    final PVector fixedAngle;

    float mass;

    PVector controllposition;
    PVector polar;
    float r;
    float theta;
    float phi;
    float roff;
    float toff;
    float poff;

    PVector targetPosition;

    boolean cruiseMode;
    boolean riseMode;
    boolean descentMode;
    boolean steepDescentMode;

    boolean turningMode;
    boolean steepTurningMode;

    float flappingRandomS;
    float pittingAmplitude;

    int updown1;
    int updown2;

    float[][][] flowfield;
    int resolution;
    int column;
    int row;

    int actPattern;
    int wingN;
    int[] wingStop;

    Butterfly(float flowfield[][][],int resolution,int column,int row){
        wing = new Wing[2];
        ps = new ParticleSystem();

        location = new PVector(random(width),random(height),random(100));
        velocity = new PVector(0,0,0);
        acceleration = new PVector(0,0,0);
        fixedAngle = new PVector(random(360),90,90);

        targetPosition = new PVector(0,0,0);

        PVector otherPlus = new PVector(0,180,0); //もう片方の羽への回転
        wing[0] = new Wing(fixedAngle,1);
        wing[1] = new Wing(PVector.add(fixedAngle,otherPlus),-1);
        wing[1].angle.y *= -1; //もう一つの羽の回転方向の調整

        mass = 0.024;

        r = random(100);
        theta = random(360);
        phi = random(360);
        polar = new PVector(r*sin(radians(theta))*sin(radians(phi)),r*cos(radians(theta)),r*sin(radians(theta))*cos(radians(phi)));
        controllposition = PVector.add(location,polar);
        roff = 0;
        toff = 10000;
        poff = 20000;

        cruiseMode = true;
        riseMode = false;
        descentMode = false; 
        steepDescentMode = false;

        turningMode = true;
        steepTurningMode = false;

        updown1 = 0;
        updown2 = 0;

        this.resolution = resolution;
        this.column = column;
        this.row = row;
        this.flowfield = new float[column][row][50];
        for(int i=0; i<50; i++){
            yoff = 0;
            for(int j=0; j<row; j++){
                xoff = 0;
                for(int k=0; k<column; k++){
                    this.flowfield[k][j][i] = flowfield[k][j][i];
                }
            }
        }

        actPattern = 0;
        wingN = 0;
        wingStop = new int[2];
        wingStop[0] = 0;
        wingStop[1] = 0;
    }

    void run(){
        update(); //runを先に実行するとNullPointerExceptionが発生してしまう
        wing[0].run();
        wing[1].run();
        ps.run();
    }

    void update(){
        velocity.add(acceleration);
        location.add(velocity);

        velocity.limit(2);

        wing[0].getLocation(location);
        wing[1].getLocation(location);

        //println(acceleration);
        acceleration.mult(0);

        actPatternDecide();
        wingStep();

        ps.addParticle(location,velocity);
    }

    //applyforceに重力を入力する場合，第二引数に1を入れる
    void applyForce(PVector force,int gravityFlag){
        if(gravityFlag==0){
            force.div(mass);
        }
        acceleration.add(force);
    }

    void wingStep(){
        if(fixedAngle.y<=wing[0].angle.y){
            if(updown1==0 && (actPattern==0 || actPattern==1)){
                flappingRandomS = random(wing[0].wd.upFlappingAngle_min,wing[0].wd.upFlappingAngle_max);
                updown1=1;
            }
            else if(updown1==0 && actPattern==2){
                flappingRandomS = wing[0].wd.upFlappingAngle_max;
                updown1=1;
                wingN++;
            }
        }
        else if(fixedAngle.y>wing[0].angle.y){
            if(updown1==1 && (actPattern==0 || actPattern==1)){
                flappingRandomS = random(wing[0].wd.downFlappingAngle_min,wing[0].wd.downFlappingAngle_max);
                updown1=0;
            }
            else if(updown1==1 && actPattern==2){
                flappingRandomS = wing[0].wd.downFlappingAngle_max;
                updown1=0;
            }
        }

        if(fixedAngle.z<=wing[0].angle.z){
            if(updown2==0){
                pittingAmplitude = wing[0].wd.upPitchingAngle;
                updown2=1;
            }
        }
        else if(fixedAngle.z>wing[0].angle.z){
            if(updown2==1){
                pittingAmplitude = wing[0].wd.downPittingAngle;
                updown2=0;
            }
        }

        if(!(wingStop[0]==1 && wingStop[1]==1)){
            wingStop[0] = wing[0].wingStep(flappingRandomS,pittingAmplitude,actPattern,wingN);
            wingStop[1] = wing[1].wingStep(flappingRandomS,pittingAmplitude,actPattern,wingN);
        }

        if(wingStop[0]==1 && wingStop[1]==1){
            if(random(1)>0.995){
                wingN = 0;
                actPattern = 1;
                wingStop[0] = 0;
                wingStop[1] = 0;
            }
        }
    }

    void controllPointStep(){
        //display
        pushMatrix();
        translate(controllposition.x,controllposition.y,controllposition.z);
        //println(controllposition);
        fill(255,0,0,150);
        noStroke();
        sphere(5);
        popMatrix();

        r += map(noise(roff),0,1,-1,1);
        theta += map(noise(toff),0,1,-1,1);
        phi += map(noise(poff),0,1,-1,1);
        polar = new PVector(r*sin(radians(theta))*sin(radians(phi)),r*cos(radians(theta)),r*sin(radians(theta))*cos(radians(phi)));
        controllposition = PVector.add(location,polar);

        roff += 0.01;
        toff += 0.01;
        poff += 0.01;
    }

    void atitudeAdjust(){

    }

    void turningAdjust(){
        float targetd = getTargetAngle(phi);

        if(targetd <= wing[0].wd.turningAngle_max){
            turningMode = true;
            steepTurningMode = false;
        }
        else if(targetd > wing[0].wd.turningAngle_max){
            turningMode = false;
            steepTurningMode = true;
        }
        else if(targetd==0){
            turningMode = false;
            steepTurningMode = false;
        }

        wing[0].turningUpdate(turningMode,steepTurningMode,targetd);
        wing[1].turningUpdate(turningMode,steepTurningMode,targetd);
    }

    float getTargetAngle(float phi){
        float targetd1 = phi - wing[0].angle.x;
        float targetd2 = -(360+(wing[0].angle.x - phi));
        
        if(targetd1>abs(targetd2)){
            return targetd2;
        }
        else{
            return targetd1;
        }
    }

    void harmony(){
        int c = int(location.x/resolution);
        int r = int(location.y/resolution);
        int d = int(location.z/resolution);

        if(0<=c&&c<column&&0<=r&&r<row&&0<=d&&d<50){
            float targetd = getTargetAngle(flowfield[c][r][d]);
            //println(targetd);

            if(targetd <= wing[0].wd.turningAngle_max){
                turningMode = true;
                steepTurningMode = false;
            }
            else if(targetd > wing[0].wd.turningAngle_max){
                turningMode = false;
                steepTurningMode = true;
            }
            else if(targetd==0){
                turningMode = false;
                steepTurningMode = false;
            }

            wing[0].turningUpdate(turningMode,steepTurningMode,targetd);
            wing[1].turningUpdate(turningMode,steepTurningMode,targetd);
        }
    }

    int actPattern(){
        if(actPattern==0){
            harmony();
        }
        else if(actPattern==1){
            controllPointStep();
            turningAdjust();
        }
        else if(actPattern==2){
            turningAdjust();

            return 1;
        }

        return 0;
    }

    void actPatternDecide(){
        /*if(random(1)>0.70){
            actPattern = 2;
        }*/
    }

    void stopMotion(){
        PVector v = PVector.sub(targetPosition,location);

        v.div(100);

        location.add(v);
    }
}