---
title: 'Logging and analysis basics'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- How can I plot thermodynamic properties of my system?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Set up a logger
- Visualize the last snapshot
- Plot kinetic temperature

::::::::::::::::::::::::::::::::::::::::::::::::

## Plans



OK, now that we've run our first simulations, let's add in a bit more complexity.

Last time we did this:

    Turn on hoomd-blue, a simulation engine that works nicely in python
    Load in a configuration of randomly-packed spheres that has been created for us
    Define Lennard-Jones interaction rules and an NVT ensemble
        Bonus: We're going to set the initial velocities, too
    Step forward 10000 steps.
    Visualize the last snapshot.

This time we're going to :

    Turn on hoomd-blue, a simulation engine that works nicely in python
    Load in a configuration of randomly-packed spheres that has been created for us
    Define Lennard-Jones interaction rules and an NVT ensemble
        Bonus: We're going to set the initial velocities, too
    NEW: Set up a logger that will save simulation information we can use.
    Step forward 10000 steps.
    NEW: Visualize the last snapshot.
    NEW: Plot kinetic temperature



::::::::::::::::::::::::::::::::::::: keypoints 

- HOOMD simulation objects have "computes" and "writers", and we pass the same thermodynamic quantities to each that we want computed and written.

::::::::::::::::::::::::::::::::::::::::::::::::

