---
title: 'Varying parameters'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- How can I vary thermodynamic quantities and observe the effects of these changes?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Vary thermodynamic quantities
- Analyze different trajectories for differences this causes

::::::::::::::::::::::::::::::::::::::::::::::::

## Plans

We are ready to build on the previous example and learn how to vary thermodynamic parameters
in HOOMD-blue and observe how these changes can affect the behavior of our systems.

Last time we did this:

1. Turn on hoomd-blue, a simulation engine that works nicely in python
1. Load in a configuration of randomly-packed spheres that has been created for us
1. Define Lennard-Jones interaction rules and an **NVT** ensemble
1. Set up a logger that will save simulation information we can use.
1. Step forward 10000 steps.
1. Plot kinetic temperature

This time we are going to:

1. Turn on hoomd-blue, a simulation engine that works nicely in python
1. Load in a configuration of randomly-packed spheres that has been created for us
1. Define Lennard-Jones interaction rules and an **NPT** ensemble
    a. We are going to vary the integrator parameters and evaluate thermodynamic observables
1. Set up a logger that will save simulation information we can use.
1. Step forward 10,0000 steps.
1. Analyze output

Just like before, first we need to grab our tools:

```python
import hoomd
import gsd.hoomd
from day1_utils import arrays_from_gsd
import matplotlib.pyplot as plt
```
The simulation setup works the same as before, but this time we are specifying a T and P combination.
This also requires us to use the NPT integration scheme, as opposed to NVT before.
Once we create and specify the NPT object, telling the integrator about it is exactly the same, too.

```python
#This is steps 1-3 from before
# Attach to CPU and create simulation
cpu = hoomd.device.CPU()
sim = hoomd.Simulation(device=cpu,seed=0)
sim.create_state_from_gsd(filename='random.gsd') #N and V are set here

#Potential and integrator setup
integrator = hoomd.md.Integrator(dt=0.005)
cell = hoomd.md.nlist.Cell(buffer = 0.4)
lj_potential = hoomd.md.pair.LJ(nlist=cell)
lj_potential.params[('A','A')] = dict(epsilon=1,sigma=1)
lj_potential.r_cut[('A','A')]=2.5
T,P = 1.5, 3.0 #NEW
ensemble = hoomd.md.methods.NPT(kT=T,filter=hoomd.filter.All(),tau=.1, tauS=0.1, S=P, couple = 'xyz') #NEW
integrator.forces.append(lj_potential)
integrator.methods.append(ensemble)
sim.operations.integrator = integrator

# Set the simulation state 
sim.state.thermalize_particle_momenta(filter=hoomd.filter.All(), kT=1.5)
```

Alright, with that difference sorted, now we can set up our logger again.

```python
# We need to define which atoms participate in logging, what is logged, and where to store that info.
selection = hoomd.filter.All() # "which atoms"
logger = hoomd.logging.Logger() # will be used for "what is logged"
trajfile = 'traj3.gsd'
writer = hoomd.write.GSD(filename=trajfile, # "where to store"
                             trigger=hoomd.trigger.Periodic(100), #when to store
                             mode='wb',
                             filter=selection) #filter=hoomd.filter.Null() to only store log

thermo_props = hoomd.md.compute.ThermodynamicQuantities(filter=selection) # What to store
logger.add(thermo_props)
logger.add(sim,quantities=['timestep','walltime','tps'])
writer.log = logger #need to tell our write which logger to use when it is logging info

sim.operations.computes.append(thermo_props) #tell our simulation to *compute* the thermo properties
sim.operations.writers.append(writer) # tell our simulation which writer(s) to use
```

Now we call run again and we can open up the log to check out some properties.

```python
# Run  the simulation  (a few seconds)
sim.run(1e5)

# Use the log to analyze properties
traj = gsd.hoomd.open(trajfile,'rb')
traj[0].log #let us see what things we can access in the log
```

```
{'md/compute/ThermodynamicQuantities/kinetic_temperature': array([1.35531094]),
 'md/compute/ThermodynamicQuantities/pressure': array([5.48293575]),
 'md/compute/ThermodynamicQuantities/pressure_tensor': array([ 6.16431824, -0.0800075 ,  0.15555493,  5.66618896,  0.29488547,
         4.61830004]),
 'md/compute/ThermodynamicQuantities/kinetic_energy': array([518.40643306]),
 'md/compute/ThermodynamicQuantities/translational_kinetic_energy': array([518.40643306]),
 'md/compute/ThermodynamicQuantities/rotational_kinetic_energy': array([0.]),
 'md/compute/ThermodynamicQuantities/potential_energy': array([-1130.50699638]),
 'md/compute/ThermodynamicQuantities/degrees_of_freedom': array([765.]),
 'md/compute/ThermodynamicQuantities/translational_degrees_of_freedom': array([765.]),
 'md/compute/ThermodynamicQuantities/rotational_degrees_of_freedom': array([0.]),
 'md/compute/ThermodynamicQuantities/num_particles': array([256]),
 'md/compute/ThermodynamicQuantities/volume': array([318.64920867]),
 'Simulation/timestep': array([10100]),
 'Simulation/walltime': array([0.321906]),
 'Simulation/tps': array([307.54319584])}
```

Great! Since we ran in the NPT ensemble, the simulation box size is allowed to vary in order to maintain
the target pressure value on average. Here we will plot what that looks like:

```python
x = 'timestep'
y = 'volume'
[xd,yd] = arrays_from_gsd(trajfile,keys=[x,y])
plt.plot(xd,yd)
plt.xlabel(x)
plt.ylabel(y)
plt.show()
```

![](fig/volume_plot.png "Plot of system volume over time."){alt="Plot of our simulation box volume over time,
showing oscillation around the average value of about 340."}

Now, while we lack direct access to the value of the system density at each time step, we can still
calculate it, since we know N and V at each step. Here is how a plot of density looks:

```python
import numpy
def calc_density(filename):
    with gsd.hoomd.open(filename,'rb') as traj:
        N = len(traj[0].particles.position)
        step = []
        vol = []
        for frame in traj:
                step.append(frame.configuration.step)
                vol.append(frame.log['md/compute/ThermodynamicQuantities/volume'][0])
        return numpy.array(step), numpy.array(vol)/N 

step, density = calc_density(trajfile)
plt.plot(step,density)
plt.xlabel("timestep")
plt.ylabel("density")
plt.show()

```

![](fig/density_plot.png "Plot of system density over time."){alt="Plot of the density of our simulation
over time, showing oscillation around the average value of about 1.32"}

If our density fluctuates too greatly, we know something unexpected is happening, like the integration scheme failing.
If that is the case, we cannot trust that any analysis from this trajectory is meaningful, so it is always a good idea to check.
Here we can check the magnitude of density fluctuations with the standard deviation:

```python

print(T, P, density.mean(), density.std())

```

```
1.5 3.0 1.32202089047001 0.02347698751080215
```



::::::::::::::::::::::::::::::::::::: keypoints 

- With HOOMD we can quickly vary different parameters of a simulation
- We can use python functions to calculate and plot thermodynamic derived quantities not directly measured in HOOMD.
- Verifying that our integration scheme worked as expected is a good practice to avoid sinking time analyzing bogus data. 

::::::::::::::::::::::::::::::::::::::::::::::::

