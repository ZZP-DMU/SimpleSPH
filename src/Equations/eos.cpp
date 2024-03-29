#include "Equations.H"

void ptc_fluid_pressure(SPH *sph)
{
    SPH_PARTICLE *particle;
    particle = sph->particle;
    
    double c = sph->c; //ariti_sound_velocity

    #ifdef LINEAR_EOS
    for(unsigned int i=0;i<particle->total;i++)
    {
        if(particle->type[i]==0)
        {
            /* the formula is $p=c \times (\rho-\rho_{ref})$ */
            particle->pressure[i] = c*c*(particle->density[i]-REF_DENSITY); 
        }
    }
    #else
    for(unsigned int i=0;i<particle->total;i++)
    {
        if(particle->type[i]==0)
        {
            particle->pressure[i] = (pow(ART_SOUND_VEL,2)*REF_DENSITY/7)*(pow(particle->density[i]/REF_DENSITY,7)-1);
        }
    }
    #endif
}