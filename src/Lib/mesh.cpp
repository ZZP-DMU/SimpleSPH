#include "Lib.H"
using namespace std;

void mesh_process(SPH_PARTICLE *particle,unsigned ***mesh)
{
    unsigned int head;
    //#pragma omp parallel
    //{
        //#pragma omp for
        for(unsigned int i=0;i<PTC_TOL_NUM;i++)
        {
            head = mesh[(unsigned int)(particle->y[i]/MESH_SPACING)][(unsigned int)(particle->x[i]/MESH_SPACING)][MESH_PTC_NUM-1];
            mesh[(unsigned int)(particle->y[i]/MESH_SPACING)][(unsigned int)(particle->x[i]/MESH_SPACING)][head] = i;        
            mesh[(unsigned int)(particle->y[i]/MESH_SPACING)][(unsigned int)(particle->x[i]/MESH_SPACING)][MESH_PTC_NUM-1]++;
        }
    //}
}