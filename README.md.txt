# Overview
Vorbiter is an orbital-physics based arcade game with a meditative tone and an emphasis on high-scoring competition. Its stylistic influences include Geometry Wars, N+, and Outer Wilds.

Vorbiter's design philosophy is comprised of three key elements.

1. Satisfying moment-to-moment gameplay.
2. Hypnotizing visuals and sound
3. A rewarding sense of discovery from Universe to Universe.

# Structure
There are two game objects that run the gameplay logic. obj_game manages sector saving/loading and user inputs. obj_projectile contains the logic for projectile physics. Both objects run scripts held in scripts/utility_functions game_functions graphics_functions menu_functions and sim_functions. I will admit the line defining what function goes in which file is a bit blurry, this is just an organizational convention I've developed to deal with the classless nature of GameMaker's proprietary language.

sim_functions generally holds all of the physics code. 

game_functions contains input management and game logic. 

utility_functions holds saving/loading and struct creation functions. 

graphics_functions and menu_functions should be self explanatory. graphics_functions largely holds functions used for manually setting vertices for the 3d gravity well stuff.

# Gameplay
The player's goal in Vorbiter is to strike the target with enough projectiles to reduce its actual radius to the target radius. Projectiles launched by the player are influenced by gravitational fields created by the Target and Obstacles in the play area which have mass.

The gravitational force calculation. "f" is the gravitational force, "m1" and "m2" are the interacting object masses and "d" is the distance between the two bodies.

f = (m1∗m2∗g)/d2​​ 

Projectiles increase in size continuously as they move through the play area. The amount of damage that is caused to the target scales linearly with projectile radius, whereas the number of points received per impact scales geometrically with the area of the projectile. Thus, the optimal play strategy is to maximize the ratio of points to damage. This incentivizes long, looping projectile trajectories.

The projectile growth calculation. "r" is the projectile radius, "p" is the physics timestep and "s" is the overall simulation rate, which may be a nonzero integer within defined bounds.

dr=((0.2∗r)/p)∗s

The damage calculation

d=r/10

When the projectile passes within a close distance of an obstacle or the target circle, a multiplier is applied to the point calculation on target impact. The overall point calculation is as follows where "pt" is the number of points, "r" is the projectile radius, and "m" is the current multiplier.

pt=pi∗r

The game is broken up into non-linear groups of "Regions" that are each comprised of ten sectors. Each region has its own high score leaderboard, with sub leaderboards for each sector within. These regions are then divided up into different Universes, which have different physical laws.

# Glossary
Body - Any of the fixed objects which act as gravitational field generators.

Shooter - The point from which the player launches projectiles.

Target - The circle that the player must hit with projectiles in order to progress.

Obstacle - Objects that occur in the play area that interfere with projectile trajectories.

Projectile - Objects launched by the player that are subject to the gravitational fields present in the play area.

Universe - A collection of Regions with consistent physical operating laws

Region - A collection of Sectors with a coherent set of Obstacle types and challenges.

Special Ability - Abilities that can be unlocked by the player that allow further interaction with projectiles after they are wlaunched. Examples include increasing or decreasing projectile velocity at the expense of projectile radius, or reversing the simulation rate.