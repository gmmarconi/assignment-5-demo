// -*- mode:C++; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-
//
// Author: Ugo Pattacini - <ugo.pattacini@iit.it>

#include <string>

#include <yarp/os/all.h>
#include <yarp/dev/all.h>
#include <yarp/sig/all.h>
#include <yarp/math/Math.h>

using namespace std;
using namespace yarp::os;
using namespace yarp::dev;
using namespace yarp::sig;
using namespace yarp::math;


/***************************************************/
class CtrlModule: public RFModule
{
protected:
    PolyDriver drvArm, drvGaze;
    ICartesianControl *iarm;
    IGazeControl      *igaze;

    BufferedPort<ImageOf<PixelRgb> > imgLPortIn,imgRPortIn;
    BufferedPort<ImageOf<PixelRgb> > imgLPortOut,imgRPortOut;
    RpcServer rpcPort;

    Mutex mutex;
    Vector cogL,cogR,initX,initO;
    bool okL,okR;

    /***************************************************/
    bool getCOG(ImageOf<PixelRgb> &img, Vector &cog)
    {
        int xMean=0;
        int yMean=0;
        int ct=0;

        for (int x=0; x<img.width(); x++)
        {
            for (int y=0; y<img.height(); y++)
            {
                PixelRgb &pixel=img.pixel(x,y);
                if ((pixel.b>5.0*pixel.r) && (pixel.b>5.0*pixel.g))
                {
                    xMean+=x;
                    yMean+=y;
                    ct++;
                }
            }
        }

        if (ct>0)
        {
            cog.resize(2);
            cog[0]=xMean/ct;
            cog[1]=yMean/ct;
            return true;
        }
        else
            return false;
    }

    /***************************************************/
    Vector retrieveTarget3D(const Vector &cogL, const Vector &cogR)
    {
      Vector x;
      igaze->triangulate3DPoint(cogL,cogR,x);
      return x;
    }

    /***************************************************/
    void fixate(const Vector &x)
    {
      igaze->lookAtFixationPoint(x);
      igaze->waitMotionDone();
      igaze->setTrackingMode(true);
    }

    /***************************************************/
    Vector computeHandOrientation()
    {
      Vector oy(4), ox(4);
      oy[0]=0.0; oy[1]=1.0; oy[2]=0.0; oy[3]=+M_PI;
      ox[0]=1.0; ox[1]=0.0; ox[2]=0.0; ox[3]=-M_PI/2.0;
      Matrix Ry = yarp::math::axis2dcm(oy);        // from axis/angle to rotation matrix notation
      Matrix Rx = yarp::math::axis2dcm(ox);
      Matrix R  = Rx*Ry;                            // compose the two rotations keeping the order
      return yarp::math::dcm2axis(R);
    }

    /***************************************************/
    void approachTargetWithHand(const Vector &x, const Vector &o)
    {
      iarm->goToPoseSync(x,o);
      iarm->waitMotionDone();
    }

    /***************************************************/
    void roll(const Vector &x, const Vector &o)
    {
      double ttime;
      iarm->getTrajTime(&ttime);
      iarm->setTrajTime(0.5);
      Vector y(x);
      y[1] -=0.25;
      iarm->goToPoseSync(y,o);
      iarm->waitMotionDone();
      iarm->setTrajTime(ttime);
    }

    /***************************************************/
    void look_down()
    {
      Vector staredown(3,0.0);
      staredown[0] = -0.3;
      igaze->lookAtFixationPoint(staredown);
      igaze->waitMotionDone();
    }

    /***************************************************/
    void make_it_roll(const Vector &cogL, const Vector &cogR)
    {
        yInfo()<<"detected cogs = ("<<cogL.toString(0,0)<<") ("<<cogR.toString(0,0)<<")";

        Vector x=retrieveTarget3D(cogL,cogR);
        yInfo()<<"retrieved 3D point = ("<<x.toString(3,3)<<")";

        fixate(x);
        yInfo()<<"fixating at ("<<x.toString(3,3)<<")";

        Vector o=computeHandOrientation();
        yInfo()<<"computed orientation = ("<<o.toString(3,3)<<")";

        approachTargetWithHand(x,o);
        yInfo()<<"approached";

        roll(x,o);
        yInfo()<<"roll!";
    }

    /***************************************************/
    void home()
    {
      // Define bowing position
      Vector bowX(3), bowO(3);
      bowX[0] = -0.05;
      bowX[1] = -0.15;
      bowX[2] =  0.0;
      bowO = initO;
      Vector ang(3,0.0);
      // Bows moving the arm to bow position
      // Multiple positioning commands are needed to
      // avoid collision with the table.
      iarm->goToPose(bowX,bowO);
      bowX[2] = -0.05;
      Time::delay(1);
      iarm->goToPose(bowX,bowO);
      Time::delay(2.5);
      igaze->lookAtAbsAngles(ang);
      igaze->waitMotionDone();
      // Puts arm back into position
      // Multiple positioning commands are needed to
      // avoid collision with the body.
      bowX[0] -= 0.25;
      bowX[1] += 0.05;
      bowO[0]  = -0.4;
      bowO[1]  = -0.25;
      bowO[2]  = -1.0;
      bowO[3]  =  0.0;
      iarm->goToPose(bowX,bowO);
      Time::delay(2.5);
      iarm->goToPoseSync(initX,initO);
      iarm->waitMotionDone();
      igaze->lookAtAbsAngles(ang);
      igaze->waitMotionDone();
      iarm->goToPoseSync(initX,initO);
      iarm->waitMotionDone();
    }

public:
    /***************************************************/
    bool configure(ResourceFinder &rf)
    {
        Property optArm;
        optArm.put("device","cartesiancontrollerclient");
        optArm.put("remote","/icubSim/cartesianController/right_arm");
        optArm.put("local","/cartesian_client/right_arm");

        // let's give the controller some time to warm up
        bool ok=false;
        double t0=Time::now();
        while (Time::now()-t0<10.0)
        {
            // this might fail if controller
            // is not connected to solver yet
            if (drvArm.open(optArm))
            {
                ok=true;
                break;
            }

            Time::delay(1.0);
        }
        iarm = NULL;
        drvArm.view(iarm);

        if (!ok)
        {
            yError()<<"Unable to open the Cartesian Controller";
            return false;
        }

        Vector newDof(10,1.0);
        iarm->setDOF(newDof,newDof);
        t0=Time::now();
        while ((!iarm->getPose(initX,initO)) && (Time::now()-t0)<2.0)
        {
            Time::delay(0.1);
        }
        if ((Time::now()-t0)>=2.0)
        {
            drvGaze.close();
            drvArm.close();
            return false;
        }

        iarm->getPose(initX,initO);

        Property optGaze;
        optGaze.put("device","gazecontrollerclient");
        optGaze.put("remote","/iKinGazeCtrl");
        optGaze.put("local","/client/igaze");
        drvGaze.open(optGaze);
        igaze = NULL;
        if (!drvGaze.isValid())
            return false;
        drvGaze.view(igaze);

        imgLPortIn.open("/imgL:i");
        imgRPortIn.open("/imgR:i");

        imgLPortOut.open("/imgL:o");
        imgRPortOut.open("/imgR:o");

        rpcPort.open("/service");
        attach(rpcPort);

        return true;
    }

    /***************************************************/
    bool interruptModule()
    {
        imgLPortIn.interrupt();
        imgRPortIn.interrupt();
        return true;
    }

    /***************************************************/
    bool close()
    {
        drvArm.close();
        drvGaze.close();
        imgLPortIn.close();
        imgRPortIn.close();
        imgLPortOut.close();
        imgRPortOut.close();
        rpcPort.close();
        return true;
    }

    /***************************************************/
    bool respond(const Bottle &command, Bottle &reply)
    {
        string cmd=command.get(0).asString();
        if (cmd=="help")
        {
            reply.addVocab(Vocab::encode("many"));
            reply.addString("Available commands:");
            reply.addString("- look_down");
            reply.addString("- make_it_roll");
            reply.addString("- home");
            reply.addString("- quit");
        }
        else if (cmd=="look_down")
        {
            look_down();
            // we assume the robot is not moving now
            reply.addString("ack");
            reply.addString("Yep! I'm looking down now!");
        }
        else if (cmd=="make_it_roll")
        {
          mutex.lock();
          Vector cogL=this->cogL;
          Vector cogR=this->cogR;
          bool go=okL && okR;
          mutex.unlock();
            if (go)
            {
                make_it_roll(cogL,cogR);
                // we assume the robot is not moving now
                reply.addString("ack");
                reply.addString("Yeah! I've made it roll like a charm!");
            }
            else
            {
                reply.addString("nack");
                reply.addString("I don't see any object!");
            }
        }
        else if (cmd=="home")
        {
            home();
            // we assume the robot is not moving now
            reply.addString("ack");
            reply.addString("I've got the hard work done! Going home.");
        }
        else
            // the father class already handles the "quit" command
            return RFModule::respond(command,reply);

        return true;
    }

    /***************************************************/
    double getPeriod()
    {
        return 0.0;     // sync upon incoming images
    }

    /***************************************************/
    bool updateModule()
    {
        // get fresh images
        ImageOf<PixelRgb> *imgL=imgLPortIn.read();
        ImageOf<PixelRgb> *imgR=imgRPortIn.read();

        // interrupt sequence detected
        if ((imgL==NULL) || (imgR==NULL))
            return false;

        // compute the center-of-mass of pixels of our color
        mutex.lock();
        okL=getCOG(*imgL,cogL);
        okR=getCOG(*imgR,cogR);
        mutex.unlock();

        PixelRgb color;
        color.r=255; color.g=0; color.b=0;

        if (okL)
            draw::addCircle(*imgL,color,(int)cogL[0],(int)cogL[1],5);

        if (okR)
            draw::addCircle(*imgR,color,(int)cogR[0],(int)cogR[1],5);

        imgLPortOut.prepare()=*imgL;
        imgRPortOut.prepare()=*imgR;

        imgLPortOut.write();
        imgRPortOut.write();

        return true;
    }
};


/***************************************************/
int main()
{
    Network yarp;
    if (!yarp.checkNetwork())
    {
        yError()<<"YARP doesn't seem to be available";
        return 1;
    }

    CtrlModule mod;
    ResourceFinder rf;
    return mod.runModule(rf);
}
