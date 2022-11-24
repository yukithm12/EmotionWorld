import java.util.*;

ArrayList<Butterfly> butterfly;
PVector gravity;
float airDensity; //空気密度
int resolution; //流場ベクトル解像度
int column;
int row;
float[][][] flowfield; //流場

float frameCount;
int displayNum; //蝶の表示数
float xoff,yoff,zoff;

void setup(){
    size(1200,800,P3D);
    background(255);
    frameRate(60);

    init_setup();
}

void draw(){
    background(0);
    blendMode(ADD);

    butterflyRun();

    frameCount++;
}

//初期化
void init_setup(){
    butterfly = new ArrayList<Butterfly>();
    gravity = new PVector(0,0.1,0);
    airDensity = 0.00129;

    resolution = 10;
    column = width/resolution;
    row = height/resolution;
    flowfield = new float[column][row][50];

    zoff = 0;
    for(int z=0; z<50; z++){
        yoff = 0;
        for(int y=0; y<row; y++){
            xoff = 0;
            for(int x=0; x<column; x++){
                float phi = map(noise(xoff,yoff,zoff),0,1,0,TWO_PI);
                flowfield[x][y][z] = phi;

                xoff += 0.1;
            }
            yoff += 0.1;
        }
        zoff += 0.1;
    }
    
    for(int i=0; i<30; i++){
        butterfly.add(new Butterfly(flowfield,resolution,column,row));
    }
}

void butterflyRun(){
    if(displayNum<butterfly.size()){
        for(int i=0; i<displayNum; i++){
            Butterfly b = butterfly.get(i);
            int actPattern = b.actPattern();

            b.run();

            if(actPattern==0){
                b.applyForce(gravity,1);
                b.applyForce(b.wing[0].wingForce(b.velocity,airDensity,b.flappingRandomS),0); //右翼の揚力
                b.applyForce(b.wing[1].wingForce(b.velocity,airDensity,b.flappingRandomS),0); //左翼の揚力
            }
            else if(actPattern==1){
                b.stopMotion();
            }
        }
    }

    else if(displayNum>=butterfly.size()){
        for(int i=0; i<butterfly.size(); i++){
            Butterfly b = butterfly.get(i);
            int actPattern = b.actPattern();

            b.run();

            if(actPattern==0){
                b.applyForce(gravity,1);
                b.applyForce(b.wing[0].wingForce(b.velocity,airDensity,b.flappingRandomS),0); //右翼の揚力
                b.applyForce(b.wing[1].wingForce(b.velocity,airDensity,b.flappingRandomS),0); //左翼の揚力
            }
            else if(actPattern==1){
                b.stopMotion();
            }
        }
    }

    if(frameCount%20==0){
        displayNum++;
    }
}
