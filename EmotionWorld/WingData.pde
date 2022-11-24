public class WingData{
    final float upFlappingAngle_max;
    final float upFlappingAngle_min;
    final float downFlappingAngle_max;
    final float downFlappingAngle_min;
    final float flappingPeriod;
    float flappingTime;

    final float upFeatheringAngle;
    final float downfeatheringAngle;
    final float featheringPeriod;
    float featherringTime;

    final float upPitchingAngle;
    final float downPittingAngle;
    final float pittingPeriod;
    float pittingTime;

    final float wingSize;
    final float wingWidth;
    final float wingShapeC;
    float liftC;
    float dragC;

    final float turningAVelocity;

    final float turningAngle_max;
    final float downAltitudeAngle;
    final float upCruiseAngle;
    final float downCruiseAngle;

    final float offsetAngleAdjustmentC;

    WingData(){
    upFlappingAngle_max = 90;
    upFlappingAngle_min = 50;
    downFlappingAngle_max = 80;
    downFlappingAngle_min = 40;
    flappingPeriod = 1;
    flappingTime = 0;

    upFeatheringAngle = 30;
    downfeatheringAngle = 20;
    featheringPeriod = 1;
    featherringTime = 0;

    upPitchingAngle = 30;
    downPittingAngle = 20;
    pittingPeriod = 1;
    pittingTime = 0;

    wingSize = 8.25;
    wingWidth = 2.8;
    wingShapeC = 0.54;

    turningAVelocity = 83;

    turningAngle_max = 30;
    downAltitudeAngle = 60;
    upCruiseAngle = 60;
    downCruiseAngle = 25;

    offsetAngleAdjustmentC = 0.5;
    }

    void getLiftC(float a){
        liftC = a;
    }

    void getDragC(float a){
        dragC = a;
    }
}