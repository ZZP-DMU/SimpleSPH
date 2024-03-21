#ifndef __DATASTRUCTURE__
#define __DATASTRUCTURE__

/* Data Structure Declare */
typedef unsigned int*** SPH_MESH;

typedef  struct 
{
    /* declare the position,velosity,pressure,density,type of the particle */
    double *x;  //x coordinations of position,iterative
    double *y;  //y coordinations of position,iterative
    double *vx; //x-direction velosity,iterative
    double *vy; //y-direction velosity,iterative
    double *accx;//
    double *accy;//
    double *dif_density;//
    double *pressure;   //pressure of paritcle,non-iterative
    double *density;    //density of particle,iterative
    double *temp_x;     //for predict-correct scheme,non-iterative
    double *temp_y;     //for predict-correct scheme,non-iterative
    double *temp_vx;    //for predict-correct scheme,non-iterative
    double *temp_vy;    //for predict-correct scheme,non-iterative
    double *temp_density;   //for predict-correct scheme,non-iterative
    double *mass;   //mass of particle
    double *w; //sum of kernel value
    int *type; //particle type:0 denote fulid;1 denote rigid;-1 denote dummy particles

    unsigned int fulid_ptc_num;  //total fluid particle number
    unsigned int wall_ptc_num;   //total wall particle number
    unsigned int rigid_ptc_num;  //total rigid particle number
    unsigned int total; //total particles number
}SPH_PARTICLE;

typedef struct 
{
    /* declare the kernel and differential kernel value of each pair */
    double *w;  //kernel value
    double *dwdx;   //differential kernel value in x-direction
    double *dwdy;   //differential kernel value in y-direction
}SPH_KERNEL;

typedef struct 
{
    /* particle pare generated by NNPS algorithm */
    unsigned int total;
    unsigned int *i;
    unsigned int *j;
}SPH_PAIR;

typedef struct 
{
    /* rigid body kinematics information */
    double vx;  //rigid body x-direction velocity
    double vy;  //rigid body y-direction velocity
    double omega;   //rigid body angular velocity
    double accx;    //rigid body x-direciton acceleration
    double accy;    //rigid body y-direction acceleration
    double alpha;   //rigid body angular acceleration
    double cogx;    //x-direction center of gravity coordinate
    double cogy;    //y-direction center of gravity coordinate 
    double mass;    //rigid body mass 
    double moi;     //rigid body moment of inertia
    double total;   //rigid body ptc num
}SPH_RIGID;

typedef struct 
{
    /* SPH Program Struct */
    SPH_PARTICLE *particle;
    SPH_RIGID *rigid;
    SPH_PAIR *pair;
    SPH_KERNEL *kernel;
    SPH_MESH mesh;
    //current time step
    int current_step;
    //total time steps
    int total_step;

    //current process flags
    int new_case_flag;  // if 1 then creat a new case,or continue to run the old case
    int init_impac_flag; //if 1 then run the init step,or run the impac step
    int save_last_flag; //if 1 then save the last step,or donnot save it

    //gravity acceleration
    double g;
    //artificial sound speed
    double c;
    //time step size
    double d_time;
    //to record the start and end time
    double avg_time;
}SPH;


#endif