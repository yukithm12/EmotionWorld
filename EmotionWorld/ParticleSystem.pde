public class ParticleSystem{
    ArrayList<Particle> particles;

    PVector bornPosition;
    PVector invelocity;

    int frameCount;

    ParticleSystem(){
        particles = new ArrayList<Particle>();

        frameCount=0;
    }

    void addParticle(PVector p,PVector v){
        bornPosition = p.get();
        invelocity = v.get();
        frameCount++;
        particles.add(new Particle(bornPosition,invelocity));
    }

    void run(){
        for(int i=particles.size()-1; i>=0; i--){
            Particle p = (Particle)particles.get(i);
            p.run();
            if(p.isDead()){
                particles.remove(i);
            }
        }
    }
}