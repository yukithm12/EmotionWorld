public class Particle{
    PVector position;
    PVector velocity;
    PVector acceleration;
    PVector invelocity;
    float size;
    float lifespan;

    Particle(PVector l,PVector v){
        position = l.get();
        invelocity = v.get();

        //反速度の加工
        invelocity.y *= 0;
        invelocity.normalize();
        invelocity.mult(-0.1);
        velocity = new PVector(random(-1,1),1,random(-1,1));
        acceleration = new PVector(0,0.005,0);

        size = random(1,3);
        lifespan = 120;
    }

    void run(){
        update();
        display();
    }

    void update(){
        velocity.add(acceleration);
        position.add(velocity);
        velocity.limit(5);
        lifespan -= 1.0;
    }

    void display(){
        pushMatrix();
        noStroke();
        fill(212,208,170,lifespan);
        translate(position.x,position.y,position.z);
        sphere(size);
        popMatrix();
    }

    boolean isDead(){
        if(lifespan<=0){
            return true;
        }
        else{
            return false;
        }
    }
}