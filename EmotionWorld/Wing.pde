//x...蝶の進行方向、y...羽の角度、z...体の角度
//蝶の進行方向、羽の角度はPVectorで管理、力の方向は管理された角度から極座標系よりベクトルを算出

public class Wing{
    WingData wd;
    PImage img;

    PVector fixedAngle;
    PVector angle;
    PVector location;
    float wingVelocity;

    float flappingAngle;
    float preFlappingAngle;
    float pittingAngle;

    int heightSizeHalf;
    int widthSize;

    //ノイズの時間
    float floff;
    float poff;

    int PN; //左右の羽の振幅を反転させる係数
    int updown; //羽が上と下どちらに羽ばたかせているかを判定する値

    Wing(PVector fixedAngle,int pn){
        wd = new WingData();
        img = loadImage("Emotion_wing.png");
        
        angle = new PVector();
        this.fixedAngle = new PVector();
        angle.set(fixedAngle);
        this.fixedAngle.set(fixedAngle);
        wingVelocity = 0.03;

        flappingAngle = 0;
        pittingAngle = 0;

        heightSizeHalf = 40;
        widthSize = heightSizeHalf*2/3;

        floff = 30000;
        poff = 40000;

        PN = pn;
        updown = 0;
    }

    void run(){
        display();
    }

    void display(){

        textureMode(NORMAL);
        pushMatrix();
        translate(location.x,location.y,location.z);
        rotateZ(radians(angle.z));
        rotateX(radians(angle.x));
        rotateY(radians(angle.y));
        beginShape();
        texture(img);
        noStroke();
        vertex(0,-heightSizeHalf,0,0,0);
        vertex(widthSize,-heightSizeHalf,0,1,0);
        vertex(widthSize,heightSizeHalf,0,1,1);
        vertex(0,heightSizeHalf,0,0,1);
        endShape();
        popMatrix();
    }

    int wingStep(float a,float b,int actPattern,float wingN){
        if(actPattern==0 || actPattern==1){
            flappingStep(a);
            pittingStep(b);
        }
        else if(actPattern==2){
            if(wingSlow(a,wingN)==1){
                angle.y = fixedAngle.y + 90 * PN;
                return 1;
            }
        }

        return 0;
    }

    //フラッピング角度のステップ
    void flappingStep(float a){
        preFlappingAngle = angle.y;
        angle.y = fixedAngle.y + a*sin(TWO_PI*wd.flappingTime/wd.flappingPeriod) * PN; //基準角からの三角関数による増減

        //println(angle.y);

        wd.flappingTime += map(noise(floff),0,1,0,wingVelocity*2);
        wd.flappingTime += wingVelocity;

        floff += 0.01;
    }

    void pittingStep(float b){
        angle.z = fixedAngle.z + b*sin(TWO_PI*wd.pittingTime/wd.pittingPeriod); //基準角からの三角関数による増減

        wd.pittingTime += map(noise(poff),0,1,0,0.006);
        wd.pittingTime += 0.003;

        poff += 0.01;
    }

    int wingSlow(float a,float wingN){
        if(wingN<4){
            preFlappingAngle = angle.y;
            angle.y = fixedAngle.y + a*sin(TWO_PI*wd.flappingTime/wd.flappingPeriod) * PN; //基準角からの三角関数による増減

            wd.flappingTime += wingVelocity/2;
        }
        else if(wingN>=4){
            angle.y = fixedAngle.y + 90*sin(TWO_PI*wd.flappingTime/wd.flappingPeriod) * PN;

            wd.flappingTime += wingVelocity/4;

            if(angle.y>=90){
                println("止まる");
                return 1;
            }
        }

        return 0;
    }

    PVector lift(PVector v,float k,float a){
        PVector lift = new PVector(0,-1,0);

        lift.mult(wd.wingWidth*wd.wingShapeC*wd.offsetAngleAdjustmentC*(map(noise(floff),0,1,0,100))*0.000031);
        //println(angle.y-preFlappingAngle);

        pushMatrix();
        translate(location.x,location.y,location.z);
        stroke(0);
        line(0,0,0,lift.x,lift.y,lift.z);
        popMatrix();

        return lift;
    }

    PVector drag(PVector v,float k){
        PVector drag = new PVector(sin(radians(angle.x-fixedAngle.x+90)),0,cos(radians(angle.x-fixedAngle.x+90)));

        drag.mult(wd.wingWidth*wd.wingShapeC*wd.offsetAngleAdjustmentC*(map(noise(floff),0,1,0,100))*0.00002);

        return drag;
    }

    PVector wingForce(PVector v,float k,float a){
        PVector force = PVector.add(lift(v,k,a),drag(v,k));
        //println(force);
        return force;
    }   

    void atitudeUpdate(){

    }

    void turningUpdate(boolean mode1,boolean mode2,float targetd){
        float turningAngle = 0.5;
        //println(targetd);
        if(mode1==true&&mode2==false){
            if(targetd>=0){
                angle.x += turningAngle;
            }
            else if(targetd<0){
                angle.x -= turningAngle;
            }
        }
        else if(mode2==true&&mode1==false){            
            if(targetd>=0){
                angle.x += (targetd-wd.turningAngle_max)/wingVelocity;
                //angle.x += turningAngle;
            }
            else if(targetd<0){
                angle.x -= (targetd-wd.turningAngle_max)/wingVelocity;
                //angle.x -= turningAngle;
            }
        }
    }

    void getLocation(PVector location){
        this.location = location;
    }
}