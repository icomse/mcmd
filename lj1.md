---
title: "Your First simulation"
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- How can I turn on hoomd and run a simulation?

::::::::::::::::::::::::::::::::::::::::::::::::


::::::::::::::::::::::::::::::::::::: objectives

- Turn on the simulation software
- Use an initial configuration
- Define interaction rules and the simulation ensemble (NVT)
- Set initial velocities
- Execute 10000 steps
- Visualize the last snapshot

::::::::::::::::::::::::::::::::::::::::::::::::

## Introduction


This week we'll be building up your understanding of molecular simulation techniques, starting with MD simulations and moving to MC simulations. 

As we do, we'll be *fading in* more complexity. 


At it's core, running a molecular simulation consists of 5 parts:
1. "Turning on" the simulation software
1. Creating an initial configuration 
1. Define the rules of our model
1. Performing a number of "steps" forward in time
1. Analyzing the simulation data

These steps are not always performed sequentially, but they're always there.

In our first simulation example we're going to:
1. Turn on hoomd-blue, a simulation engine that works nicely in python
1. Load in a configuration of randomly-packed spheres that has been created for us
1. Define Lennard-Jones interaction rules and an NVT ensemble
    1. Bonus: We're going to set the initial velocities, too
1. Step forward 10000 steps.
1. Visualize the last snapshot.


And text


```python
import hoomd
```


::::::::::::::::::::::::::::::::::::: keypoints 

- hoomd can run simulations entirely within a python interface

::::::::::::::::::::::::::::::::::::::::::::::::

