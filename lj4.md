---
title: 'Performance tuning'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- How can I check on the computational performance of my simulations?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Find the average timesteps per second (TPS) of a HOOMD simulation
- Find the total walltime of a HOOMD simulation
- Compare these performance metrics across several simulations of varying sizes

::::::::::::::::::::::::::::::::::::::::::::::::

## Plans

Now that we have learned how to set up and run individual HOOMD-blue simulations,
we can take a moment to investigate how this type of simulation scales with size.
How much longer does a simulation take when we double the number of particles?
First, we set up our simulation just as we did before.

```python
import hoomd
import gsd.hoomd
import itertools
import numpy as np

def get_density(filename):
    with gsd.hoomd.open(filename,'rb') as traj:
        N = len(traj[0].particles.position)
        step = []
        vol = []
        for frame in traj:
                step.append(frame.configuration.step)
                vol.append(frame.log['md/compute/ThermodynamicQuantities/volume'][0])
        return np.array(step), np.array(vol)/N 
```

```python
# key variables
m = 4 #increase for more atoms
N_particles = 4 * m**3
Temperature = 0.5
tau = 0.1
Pressure = 3.2
tauS = 0.1
trajfile = 'npt.gsd'
write_period = 1e5 
maxtime = 5e6

# This is steps 1-3 from before
# Attach to CPU and create simulation
cpu = hoomd.device.CPU()
sim = hoomd.Simulation(device=cpu,seed=0)

#let's add some system initialization here:
#initial condition setup with snapshots
spacing = 1.3
K = math.ceil(N_particles**(1 / 3))
L = K * spacing
x = numpy.linspace(-L / 2, L / 2, K, endpoint=False)
position = list(itertools.product(x, repeat=3))

snapshot = gsd.hoomd.Snapshot()
snapshot.particles.N = N_particles
snapshot.particles.position = position[0:N_particles]
snapshot.particles.typeid = [0] * N_particles
snapshot.configuration.box = [L, L, L, 0, 0, 0]
snapshot.particles.types = ['C']
sim.create_state_from_snapshot(snapshot) #may need debugging

#Potential and integrator setup
integrator = hoomd.md.Integrator(dt=0.005)
cell = hoomd.md.nlist.Cell(buffer = 0.4)
lj_potential = hoomd.md.pair.LJ(nlist=cell)
lj_potential.params[('C','C')] = dict(epsilon=1,sigma=1)
lj_potential.r_cut[('C','C')]=2.5
ensemble = hoomd.md.methods.NPT(kT=Temperature,filter=hoomd.filter.All(),tau=tau, tauS=tauS, S=Pressure, couple = 'xyz') #NEW
integrator.forces.append(lj_potential)
integrator.methods.append(ensemble)
sim.operations.integrator = integrator

# Set the simulation state 
sim.state.thermalize_particle_momenta(filter=hoomd.filter.All(), kT=Temperature)

# We need to define which atoms participate in logging, what's logged, and where to store that info.
selection = hoomd.filter.All() # "which atoms"
logger = hoomd.logging.Logger() # will be used for "what's logged"
writer = hoomd.write.GSD(filename=trajfile, # "where to store"
                             trigger=hoomd.trigger.Periodic(int(write_period)), #when to store
                             mode='wb',
                             filter=selection) #filter=hoomd.filter.Null() to only store log

thermo_props = hoomd.md.compute.ThermodynamicQuantities(filter=selection) # What to store
logger.add(thermo_props)
logger.add(sim,quantities=['timestep','walltime','tps'])
writer.log = logger #need to tell our write which logger to use when it's logging info
sim.operations.computes.append(thermo_props) #tell our simulation to *compute* the thermo properties
sim.operations.writers.append(writer) # tell our simulation which writer(s) to use


```

Okay, now we are ready to check on the time scaling with respect to system size.
We will measure this by running several simulations and plotting the wall time and TPS vs N.

```python

# TODO: write this function, do these plots

TPS_arr, walltime_arr = [], []
M_vals = list(range(4, 40, 4))
for M in M_vals:
    TPS, walltime = do_simulation(M)
    TPS_arr.append(TPS)
    walltime_arr.append(walltime)

plt.figure()
plt.plot(TPS_arr, M_vals, label='TPS')
plt.xlabel('M')
plt.ylabel('TPS')
plt.tight_layout()
plt.show()

plt.figure()
plt.plot(walltime_arr, M_vals, label='Walltime')
plt.xlabel('M')
plt.ylabel('Walltime')
plt.tight_layout()
plt.show()

```

::::::::::::::::::::::::::::::::::::: keypoints 

- TODO

::::::::::::::::::::::::::::::::::::::::::::::::

