#include "SPH.cuh"
#include <assert.h>
#include <string>
#include <iostream>
#include <fstream>
#include <iomanip>
#include <vtkUnstructuredGridReader.h>
#include <vtkSmartPointer.h>
#include <vtkType.h>
#include <vtkUnstructuredGrid.h>
#include <vtkPointSet.h>
#include <vtkDataSetReader.h>
#include <vtkPointData.h>
#include <vtkDataArray.h>
#include <vtkDoubleArray.h>

using namespace std;

int new_rigid_num(SPH *);
void rigid_ptc_generate(SPH *);
void rigid_init(SPH *);
void check_type(SPH *);


int main(int argc,char *argv[])
{
    SPH_ARG arg;
    SPH_RIGID rigid;
    SPH_PARTICLE particle;
    SPH sph;
    sph.host_arg = &arg;
    sph.host_rigid = &rigid;
    sph.particle = &particle;

    SPH_ARG tmp_arg;
    SPH_RIGID tmp_rigid;
    SPH_PARTICLE tmp_particle;
    SPH tmp_sph;
    tmp_sph.host_arg = &tmp_arg;
    tmp_sph.host_rigid = &tmp_rigid;
    tmp_sph.particle = &tmp_particle;

    assert(argc == 3);
    sph.host_arg->case_dir = argv[1];
    //tmp_sph.host_arg->case_dir = argv[2];

    sph_read_info(&sph);
    particle.x = (double *)calloc(arg.ptc_num,sizeof(double));
    particle.y = (double *)calloc(arg.ptc_num,sizeof(double));
    particle.vx = (double *)calloc(arg.ptc_num,sizeof(double));
    particle.vy = (double *)calloc(arg.ptc_num,sizeof(double));
    particle.accx = (double *)calloc(arg.ptc_num,sizeof(double));
    particle.accy = (double *)calloc(arg.ptc_num,sizeof(double));
    particle.density = (double *)calloc(arg.ptc_num,sizeof(double));
    particle.pressure = (double *)calloc(arg.ptc_num,sizeof(double));
    particle.type = (int *)calloc(arg.ptc_num,sizeof(int));
    sph_read_vtk(&sph);

    memcpy(&tmp_arg,&arg,sizeof(SPH_ARG));
    memcpy(&tmp_rigid,&rigid,sizeof(SPH_RIGID));

    tmp_sph.host_arg->case_dir = argv[2];
    tmp_arg.rigid_ptc_num = new_rigid_num(&tmp_sph);
    
    //tmp_arg.pair_volume = (int)(64*tmp_arg.ptc_num/tmp_arg.mesh_num);
    //tmp_arg.pair_volume = 1024;
    tmp_arg.pair_list_num = 64*arg.ptc_num;
    tmp_arg.pair_mesh_num = arg.mesh_num;
    tmp_arg.pair_volume = (int)(arg.pair_list_num/arg.pair_mesh_num);

    tmp_arg.ptc_num = tmp_arg.fluid_ptc_num + tmp_arg.wall_ptc_num + tmp_arg.rigid_ptc_num;
    tmp_particle.x = (double *)calloc(tmp_arg.ptc_num,sizeof(double));
    tmp_particle.y = (double *)calloc(tmp_arg.ptc_num,sizeof(double));
    tmp_particle.vx = (double *)calloc(tmp_arg.ptc_num,sizeof(double));
    tmp_particle.vy = (double *)calloc(tmp_arg.ptc_num,sizeof(double));
    tmp_particle.accx = (double *)calloc(tmp_arg.ptc_num,sizeof(double));
    tmp_particle.accy = (double *)calloc(tmp_arg.ptc_num,sizeof(double));
    tmp_particle.density = (double *)calloc(tmp_arg.ptc_num,sizeof(double));
    tmp_particle.pressure = (double *)calloc(tmp_arg.ptc_num,sizeof(double));
    tmp_particle.type = (int *)calloc(tmp_arg.ptc_num,sizeof(int)); 

    for(int i=0;i<arg.ptc_num;i++)
    {
        if(particle.type[i] != 1)
        {
            tmp_particle.x[i] = particle.x[i];
            tmp_particle.y[i] = particle.y[i];
            tmp_particle.vx[i] = particle.vx[i];
            tmp_particle.vy[i] = particle.vy[i];
            tmp_particle.accx[i] = particle.accx[i];
            tmp_particle.accy[i] = particle.accy[i];
            tmp_particle.density[i] = particle.density[i];
            tmp_particle.pressure[i] = particle.pressure[i];
            tmp_particle.type[i] = particle.type[i];
        }
    }
    rigid_ptc_generate(&tmp_sph);
    rigid_init(&tmp_sph);
    tmp_sph.host_arg->case_dir = argv[1];
    sph_save_last(&tmp_sph);

    int flag = 1;    
    while (flag)
    {
        check_type(&tmp_sph);

        sph_save_last(&tmp_sph);

        cout << "save file!!!(0 to exit,1 to continue) "<< endl;
        cin >> flag;
    }


    
    return 0;
}

int new_rigid_num(SPH *sph)
{
    string filename = sph->host_arg->case_dir; 
    unsigned int tol=0;

    vtkSmartPointer<vtkUnstructuredGridReader> reader = vtkSmartPointer<vtkUnstructuredGridReader>::New();
    reader->SetFileName(filename.c_str());
    reader->Update();
    double x[3];
    
    vtkUnstructuredGrid *vtkdata;
    vtkdata = reader->GetOutput();
    for(vtkIdType i=0;i<vtkdata->GetNumberOfPoints();i++)
    {
        vtkdata->GetPoint(i,x);
        if(x[2]==0)
        {
            tol++;
        }
    }
    return tol;
}

void rigid_ptc_generate(SPH *sph)
{
    SPH_ARG *arg;
    SPH_PARTICLE *particle;
    SPH_RIGID *rigid;
    arg = sph->host_arg;
    particle = sph->particle;
    rigid = sph->host_rigid;

    std::string filename = arg->case_dir;

    double x[3];
    int index = arg->fluid_ptc_num + arg->wall_ptc_num;

    vtkSmartPointer<vtkUnstructuredGridReader> reader = vtkSmartPointer<vtkUnstructuredGridReader>::New();
    reader->SetFileName(filename.c_str());
    reader->Update();
    
    vtkUnstructuredGrid *vtkdata;
    vtkdata = reader->GetOutput();
    for(vtkIdType i=0;i<vtkdata->GetNumberOfPoints();i++)
    {
        vtkdata->GetPoint(i,x);
        if(x[2]==0)
        {
            particle->x[index] = x[0] + arg->fluid_x/2.0;
            particle->y[index] = x[1] + arg->fluid_y*1.1;
            particle->type[index] = 1;
            index++;
        }
    }
    assert(index == arg->ptc_num);
}

void rigid_init(SPH *sph)
{
    SPH_ARG *arg;
    SPH_PARTICLE *particle;
    SPH_RIGID *rigid;
    arg = sph->host_arg;
    particle = sph->particle;
    rigid = sph->host_rigid;

    double tmp_cogx = 0.0;
    double tmp_cogy = 0.0;
    double tmp_r = 10000.0;

    for(int i=0;i<arg->ptc_num;i++)
    {
        if(particle->type[i] == 1)
        {
            tmp_cogx += particle->x[i];
            tmp_cogy += particle->y[i];
        }
    }
    tmp_cogx /= (double)arg->rigid_ptc_num;
    tmp_cogy /= (double)arg->rigid_ptc_num;

    for(int i=0;i<arg->ptc_num;i++)
    {
        if(particle->type[i] == 1)
        {
            if(tmp_r >= (pow((particle->x[i]-tmp_cogx),2)+pow((particle->y[i]-tmp_cogy),2)) )
            {
                tmp_r = pow((particle->x[i]-tmp_cogx),2)+pow((particle->y[i]-tmp_cogy),2);
                rigid->cog_ptc_id = i;
            }
        }
    }
    rigid->cogx = particle->x[rigid->cog_ptc_id];
    rigid->cogy = particle->y[rigid->cog_ptc_id];

    for(int i=0;i<arg->ptc_num;i++)
    {
        if(particle->type[i] == 1)
        {
            rigid->moi += (arg->m/rigid->mass)*(pow((particle->x[i]-rigid->cogx),2)+pow((particle->y[i]-rigid->cogy),2));
        }
    }

    double dx = 0.0;
    double dy = 0.0;
    double r = 0.0;
    double q = 0.0;
    int tmp_pair[arg->ptc_num] = {0,};
    int tmp_avg = 0;
    for(int i=0;i<arg->ptc_num;i++)
    {
        if(particle->type[i] == 1)
        {
            for(int j=0;j<arg->ptc_num;j++)
            {
                if(particle->type[j] == 1)
                {
                    dx = particle->x[i] - particle->x[j];
                    dy = particle->y[i] - particle->y[j];
                    r = sqrt(dx*dx+dy*dy);
                    q = r/arg->h;
                    if(q <= 2.0)
                    {
                        tmp_pair[i] ++ ;
                        tmp_pair[j] ++ ;
                        tmp_avg += 2;
                    }
                }
            }
        }
    }
    tmp_avg /= arg->rigid_ptc_num;
    tmp_avg *= 0.75;
    for(int i=0;i<arg->ptc_num;i++)
    {
        if(particle->type[i] == 1)
        {
            if(tmp_pair[i] < tmp_avg)
            {
                particle->type[i] =2;
            }
        }
    }
}

void check_type(SPH *sph)
{
    SPH_ARG *arg;
    SPH_PARTICLE *particle;
    SPH_RIGID *rigid;
    arg = sph->host_arg;
    particle = sph->particle;
    rigid = sph->host_rigid;

    int flag = 1;
    int tmp_id = 0;
    int tmp_type = 0;
    cout << "You Should Open the Vtk File!!" << endl;
    while (flag == 1)
    {
        cout << "Type the PTC Id:(-1 to exit)" << endl;
        cin >> tmp_id;
        cout << "Type the PTC Type:" << endl;
        cin >> tmp_type;

        if(tmp_id >= 0 && tmp_id < arg->ptc_num)
        {
            if(particle->type[tmp_id] == 1 || particle->type[tmp_id] == 2)
            {
                if(tmp_type == 1 || tmp_type == 2)
                {
                    particle->type[tmp_id] = tmp_type;
                }
            }
        }
        else
        {
            flag = 0;
        }
    }
}