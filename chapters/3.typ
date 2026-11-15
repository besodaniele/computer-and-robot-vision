#import "@preview/scholia:0.1.0": *
#import "@preview/lovelace:0.3.1": *
#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot
Robotics is the science of perceiving and manipulating the physical world through computer-controlled devices. 
Robotics systems are situated in the physical world, perceive information on their environments through sensors, and manipulate through physical forces.
== Uncertainty in robotics
In order to complete tasks of the real world, robots have to be able to accommodate the enormous
uncertainty that exists in the physical world. There is a number of factors
that contribute to a robot’s uncertainty.
First and foremost, robot environments are *inherently unpredictable*. While the degree of uncertainty in well-structured environments such as assembly lines is small, environments such as highways and private homes are highly dynamic and in many ways highly unpredictable. The uncertainty is particularly high for robots operating in the *proximity of people*.

Sensors are limited in what they can perceive. Limitations arise from several factors:
- The *range* and *resolution* of a sensor is subject to physical limitations. 
  
	For example, cameras cannot see through walls, and the spatial resolution of a camera image is limited. 
- *Noise*, which
  perturbs sensor measurements in unpredictable ways and hence limits the information that can be extracted.
- *Sensor failure*, detecting a faulty sensor can be extremely difficult.
Robot *actuation* involves motors that are, at least to some extent, *unpredictable*. 
Uncertainty arises from effects like control noise, wear-and-tear,and mechanical failure. Some actuators, such as heavy-duty industrial robot arms, are quite accurate and reliable. Others, like low-cost mobile robots, can
be extremely flaky.

Some uncertainty is caused by the robot’s software.
#note[All *internal models* of the world are approximate. ]
Models are *abstractions of the real world*.
As such, they only partially model the underlying physical processes of the robot and its environment. Model errors are a source of uncertainty that has often been ignored in robotics, despite the fact that most robotic models used in state-of-the-art robotics systems are rather crude.

Uncertainty is further created through *algorithmic approximations*. Robots are real-time systems. This limits the amount of computation that can be carried out. Many popular algorithms are approximate, achieving timely response through sacrificing accuracy.

The level of uncertainty depends on the application domain. In some
robotic applications, such as assembly lines, humans can cleverly engineer
the system so that uncertainty is only a marginal factor. 
In contrast, robots operating in residential homes or on other planets will have to cope with substantial uncertainty. Such robots are forced to act even though neither their sensors, nor their internal models, will provide it with sufficient information to make the right decisions with absolute certainty. As robotics is now moving into the open world, the issue of uncertainty has become a major stumbling block for the design of capable robot systems. Managing uncertainty is possibly the most important step towards robust real-world robot systems.
=== Probabilistic robotics
Probabilistic robotics is a relatively new approach to robotics that pays tribute to the uncertainty in robot perception and action. The key idea in probabilistic robotics is to represent uncertainty explicitly using the calculus of probability theory.
Put differently, instead of relying on a single “best guess” as to what might be the case, probabilistic algorithms represent information by probability distributions over a whole space of guesses. By doing so, they can represent ambiguity and degree of belief in a mathematically sound way.

Control choices can be made robust relative the uncertainty that remains, and probabilistic robotics can even actively chose to reduce their uncertainty when this appears to be the superior choice. Thus, probabilistic algorithms degrade gracefully in the face of uncertainty. As a result, they outperform alternative techniques in many real-world applications.
We shall illustrate probabilistic robotics with two motivating examples, regarding the two most important problems in robotics:
- robot perception
- planning and control.
=== Mobile robot localization (perception)
Robot localization is the problem of *estimating a robot’s coordinates relative to an external reference
frame*. The robot is given a map of its environment, but to localize itself relative to this map it needs to consult its sensor data. Observe the example in @fig:localization_example ,the environment is known to possess three indistinguishable doors. The task of the robot is to find out where it is, through sensing and motion.

This specific localization problem is known as *global localization*. In global
localization, a robot is placed somewhere in a known environment and has to
localize itself from scratch. 
The probabilistic paradigm represents the robot’s momentary *belief* by a probability density function over the space of all locations.
This is illustrated in diagram (a) in @fig:localization_example. 
This diagram shows a uniform distribution over all locations. Now suppose the robot takes a first sensor measurement and observes that it is next to a door. Probabilistic techniques exploit this information to update the belief. The ‘posterior’ belief is shown in diagram (b) in @fig:localization_example. It places an increased probability at places near doors, and lower probability near walls.
Notice that this distribution possesses three peaks, each corresponding to one of the indistinguishable doors in the environment. Thus, *by no means does the robot know where it is*. Instead, it now has three, distinct hypotheses which are each equally plausible given the sensor data. We also note that the robot assigns positive probability to places not next to a door.
This is the natural result of the inherent uncertainty in sensing: With a small, non-zero probability, the robot might have erred in its assessment of seeing a door.
#note[The ability to maintain low-probability hypotheses is essential for attaining robustness.]
Now suppose the robot moves. Diagram (c) in @fig:localization_example shows the effect
on a robot’s belief. The belief has been shifted in the direction of motion.
It also possesses a larger spread, which reflects the uncertainty that is introduced by robot motion.
Diagram (d) in @fig:localization_example depicts the belief after observing another door. This observation leads our algorithm to place most of the probability mass on a location near one of the doors, and the robot is now quite confident as to where it is. Finally, Diagram (e) shows a belief as the robot travels further down the corridor.

This example illustrates many aspects of the probabilistic paradigm.
#note[Stated probabilistically, the robot perception problem is a state estimation problem.]

#figure(
	image("../figures/3/localization.png"),caption:"Global robot localization problem"
)<fig:localization_example>
=== Coastal navigation (Planning and control)
Probabilistic algorithms can compute a robot’s momentary uncertainty. But they can also anticipate future uncertainty, and take such uncertainty into consideration when determining the right choice of control.

One such algorithm is called *coastal navigation*. An example of coastal navigation, such as the one shown in @fig:coastalNavigation.
This figure shows a 2-D map of an actual building. The top diagram compares an estimated path with an actual path:
The divergence is the result of the uncertainty in robot motion that we just discussed.
#note[Not all trajectories induce the same level of uncertainty.]

#figure(image("../figures/3/coastalNavigation.png"),caption:"Example of a coastal navigation problem")<fig:coastalNavigation>
The path in @fig:coastalNavigation (a) leads through relatively open space,
deprived of features that could help the robot to remain localized. The one shown in @fig:coastalNavigation (b) leads through a corridor with many features that can be used to localize the robot. This trajectory seeks a distinct corner, and then “hugs” the wall so as to stay localized. Not surprisingly, the uncertainty will be reduced for the latter path, hence chances of arriving at the goal location are actually higher.

This example illustrates one of the many ways proper consideration of uncertainty affects the robot’s controls. In our example, the anticipation of possible uncertainty along one trajectory makes the robot prefer a second, longer path, just so as to reduce the uncertainty. The new path is better, in the sense that the robot has a much higher chance of actually being at the goal when believing that it is.
In fact, the second path is an example of active information gathering. The robot has, through its probabilistic consideration, determined that the best choice of action is to seek information along its path, in its pursuit to reach a target location. Probabilistic planning techniques anticipate uncertainty and can plan for information gathering, and
probabilistic control techniques realize the results of such plans.
=== Implications for robotics
Probabilistic robotics seamlessly integrates models with sensor data, overcoming the limitations of both at the same time. These ideas are not just a matter of low-level control. They cut across all levels of robotic software, from the lowest to the highest.
In contrast with traditional programming techniques in robotics, such
as model-based motion planning techniques or reactive behavior-based
approaches, probabilistic approaches tend to be more robust in the face of
sensor limitations and model limitations.
This enables them to scale much better to complex real-world environments than previous paradigms, where uncertainty is of even greater importance.
#note[Certain probabilistic algorithms are currently the only known working solutions to hard robotic estimation problems, such as the localization problem]
In comparison to traditional model-based robotic techniques, probabilistic
algorithms have* weaker requirements on*: 
- *the accuracy* of the robot’s models, thereby relieving the programmer from the insurmountable burden to come up with accurate models. 
- *the accuracy* of robotic sensors than those made by many reactive techniques, whose sole control input is the momentary sensor input. 
Viewed probabilistically, the robot learning problem is a long-term estimation problem.
Thus, probabilistic algorithms provide a sound methodology for many flavors of robot learning.

However, these advantages come at a price. The two most frequently cited
limitations of probabilistic algorithms are:
- *Computational complexity*
  
  Probabilistic algorithms are inherently less efficient than their non-probabilistic counterparts. This is due to the fact that they consider entire probability densities instead of a single guess.
- *The need* to approximate. 

	This need arises from the fact that most robot worlds are continuous. Computing exact posterior distributions tends to be computationally intractable. Sometimes, one is fortunate in that the uncertainty can be approximated tightly with a compact parametric model (e.g., Gaussians). In other cases, such approximations are too crude to be of use, and more complicated representations must be employed.

Recent advancement in computer hardware, which have become faster and cheaper, has certainly aided the field of probabilistic robotics. 
Further, recent research has successfully increased the computational efficiency of probabilistic algorithms, for a range of hard robotics problems. Nevertheless, computational challenges remain.
== Recursive state estimation
At the core of probabilistic robotics is the idea of estimating state from sensor data. State estimation addresses the problem of estimating quantities from sensor data that are not directly observable, but that can be inferred.
In most robotic applications, determining what to do is relatively easy if one only knew certain quantities.
Sensors carry only partial information about those quantities, and their measurements are corrupted by noise. State estimation seeks to recover state variables from the data. Probabilistic state estimation algorithms compute belief distributions over possible world states. For a review of the probability concepts underlying probabilistic robotics, see @appendix:appendixProbability.
=== Robot Environment Interaction
#figure(image("../figures/3/interaction.png"),caption:"Robot environment interaction")<fig:interaction>
@fig:interaction illustrates the interaction of a robot with its environment. The *environment*, or *world*, is a dynamical system that possesses *internal state*.
The robot can acquire information about its environment using its sensors.
However, sensors are noisy, and there are usually many things that cannot be sensed directly. As a consequence, the robot maintains an internal belief with regards to the state of its environment, depicted on the left in this figure.
The robot can also influence its environment through its actuators. The effect of doing so is often somewhat unpredictable. Hence, each control action affects both the environment state, and the robot’s internal belief with regards to this state. We now define these concepts more formally.
==== State
#definition[State][
	Environments are characterized by *state*.
	Think of the state as the collection of all aspects of the robot and its environment that can impact the future. Certain state variables tend to change over time. Others tend to remain static. State that changes will be called dynamic state, which distinguishes it from static state, or non-changing state. 
]
The state also includes variables regarding the robot itself, such as its pose, velocity, whether or not its sensors are functioning correctly, and so on.
The state at time $t$ will be denoted by $x_t$. Typical state variables used throughout this book are:
- The robot *pose*, which comprises its location and orientation relative to a global coordinate frame. Rigid mobile robots possess six such state variables, three for their Cartesian coordinates, and three for their angular orientation (pitch, roll, and yaw). For rigid mobile robots confined to planar environments, the pose is usually given by three variables, its two location coordinates in the plane and its heading direction (yaw).
- In robot manipulation, the pose includes variables for the *configuration* of the robot’s *actuators*. For example, they might include the joint angles of revolute joints. Each degree of freedom in a robot arm is characterized by a one-dimensional configuration at any point in time, which is part of the kinematic state of the robot. The robot configuration is often referred to as *kinematic state*.
- The robot *velocity* and the *velocities of its joints* are commonly referred to as *dynamic state*. A rigid robot moving through space is characterized by up to six velocity variables, one for each pose variables. Dynamic state will play only a minor role in the topics covered here.
- The *location and features of surrounding objects* in the environment are also state variables.  For many of the problems studied in this book, the location of objects in the environment will be static. In some problems, objects will assume the form of *landmarks*, which are distinct, stationary features of the environment that can be recognized reliably.
- The location and velocities of moving objects and people are also potential state variables. Often, the robot is not the only moving actor in its environment. Other moving entities possess their own kinematic and dynamic state.
#definition[Complete state][
	A state $x_t$ will be called complete if it is the best predictor of the future. Put differently, completeness entails that knowledge of past states, measurements, or controls carry no additional information that would help us predict the future more accurately.
]
It is important to notice that our definition of completeness does not require the future to be a deterministic function of the state. The future may be stochastic, but no variables prior to $x_t$ may influence the stochastic evolution of future states, unless this dependence is mediated through the state $x_t$.

Temporal processes that meet these conditions are commonly known as *Markov chains*.
The notion of state completeness is mostly of theoretical importance. In practice, it is impossible to specify a complete state for any realistic robot system. A complete state includes not just all aspects of the environment that may have an impact on the future, but also the robot itself, the content of its computer memory, the brain dumps of surrounding people, etc.
Some of those are hard to obtain. Practical implementations therefore single out a small subset of all state variables, such as the ones listed above. Such a state is called *incomplete state*.

In most robotics applications, the state is continuous, meaning that $x_t$ is defined over a continuum, sometimes, the state is discrete. State spaces that contain both continuous and discrete variables are called hybrid state spaces.
==== Environment Interaction
There are two fundamental types of interactions between a robot and its environment: 
- The robot can influence the state of its environment through its actuators.
- It can gather information about the state through its sensors.
#definition[Environment sensor measurement][
	Perception is the process by which the robot uses its sensors to obtain information about the state of its environment. For example, a robot might take a camera image, a range scan, or query its tactile sensors to receive information about the state of the environment. The result of such a perceptual interaction will be called *measurement*, although we will sometimes also call it observation or percept. 
]
Typically, sensor measurements arrive with some delay. Hence they provide information about the state a few moments ago.
#definition[Control actions][ Actions that change the state of the world. They do so by actively asserting forces on the robot’s environment. 
]
Even if the robot does not perform any action itself, state usually changes. Thus, for consistency, we will assume that the robot always executes a control action, even if it chooses not to move any of its motors. In practice, the robot continuously executes controls and measurements are made concurrently.

Hypothetically, a robot may keep a record of all past sensor measurements and control actions. We will refer to such a collection as *the data* (regardless of whether they are being memorized or not). In accordance with the two types of environment interactions, the robot has access to two different data streams:
- *Environment measurement data* provides information about a momentary state of the environment. For most parts, we will simply ignore small timing effects. The measurement data at time t will be denoted $z_t$, we simply assume that the robot takes exactly one measurement at a time.
- *Control data* carry information about the change of state in the environment. Control data will be denoted $u_t$. The variable $u_t$ will always correspond to the change of state in the time interval $(t - 1; t]$. As before, we will denote sequences of control data by $u_(t_1:t_2)$, for $t_1 <= t_2$.

Since the environment may change even if a robot does not execute a
specific control action, the fact that time passed by constitutes, technically speaking, control information. We therefore assume that there is exactly one control data item per time step $t$, and include as legal action “do-nothing”.

The distinction between measurement and control is a crucial one, as both types of data play fundamentally different roles in the material yet to come. Environment perception provides information about the environment’s state, hence it tends to increase the robot’s knowledge. Motion, on the other hand, tends to induce a loss of knowledge due to the inherent noise in robot actuation and the stochasticity of robot environments.
==== Probabilistic Generative Laws
The evolution of state and measurements is governed by probabilistic laws.
In general, the state $x_t$ is generated stochastically from the state $x_(t-1)$. Then, we need to define the probability distribution in which $x_t$ is generated.
At first glance, the emergence of state $x_t$ might be conditioned on all past states, measurements, and control.
Hence, the probabilistic law characterizing the evolution of state might be given by a probability distribution of the following form: $ p(x_t | x_(0:t-1), z_(1:t-1), u_(1:t)) $
#remark[
	If the state $x$ is *complete* then it is a sufficient summary of all that happened in previous time steps. In particular, $x_(t-1)$ is a sufficient statistic of all previous controls and measurements up to this point in time, that is, $u_(1:t-1)$ and $z_(1:t-1)$. From all the variables in the expression above, only the control $u_t$ matters if we know the state $x_(t-1)$. 
	
	In probabilistic terms, this insight is expressed by the following equality:  $ p(x_t | x_(0:t-1), z_(1:t-1), u_(1:t)) = p(x_t | x_(t-1), u_(t)) $
]
The property expressed by this equality is an example of conditional independence. It states that certain variables are independent of others if one knows the values of a third group of variables, the *conditioning variables*. This condition is one of the main reason why the algorithms discussed are computationally tractable.

One might also want to model the process by which *measurements are
being generated*. Again, if xt is complete, we have an important conditional independence:
$ p(z_t | x_(0:t), z_(1:t-1), u_(1:t)) = p(z_t | x_(t)) $
In other words, the state $x_t$ is sufficient to predict the (potentially noisy) measurement $z_t$.
#remark[
Knowledge of any other variable, such as past measurements, controls, or even past states, is irrelevant if $x_t$ is complete
]
But what are the probabilities that we discussed?
- $p(x_t | x_(t-1), u_t)$ is the *state transition probability*
  
  It specifies how environmental state evolves over time as a function of robot controls $u_t$. Robot environments are stochastic, which is reflected by the fact that $p(x_t | x_(t-1), u_t)$ is a probability distribution, not a deterministic function. Sometimes the state transition distribution does not depend on the time index $t$, in which case we may write it as $p(x' | u, x)$, where $x'$ is the successor and $x$ the predecessor state.
- $p(z_t | x_t)$ is called the *measurement probability*
  
  It also may not depend on the time index $t$, in which case it shall be written as $p(z | x)$. The measurement probability specifies the probabilistic law according to which measurements $z$ are generated from the environment state $x$. It is appropriate to think of measurements as noisy projections of the state.
The state transition probability and the measurement probability together describe the dynamical stochastic system of the robot and its environment.
#figure(image("../figures/3/HMM.png",width:80%),caption:"Probabilistic generative laws")<fig:HMM>
@fig:HMM shows the evolution of states and measurements, dened
through those probabilities. The state at time $t$ is stochastically dependent on the state at time $t - 1$ and the control $u_t$. The measurement $z_t$ depends
stochastically on the state at time $t$. Such a temporal generative model is also known as *hidden Markov model* (HMM) or *dynamic Bayes network* (DBN).
==== Belief Distributions
Another key concept in probabilistic robotics is that of a *belief*.
A belief reflects the robot’s internal knowledge about the state of the environment. We already discussed that state cannot be measured directly, for example the robot's pose cannot be measured directly, so we must infer it by data.
We therefore distinguish the true state from its internal belief with regards to that state. 

Synonyms for belief in the literature are the terms state of knowledge and information state (not to be confused with the information vector and information matrix discussed below).

Probabilistic robotics represents beliefs through conditional probability distributions. A belief distribution assigns a probability (or density value) to each possible hypothesis with regards to the true state. Belief distributions are posterior probabilities over state variables conditioned on the available
data. We will denote belief over a state variable $x_t$ by $"bel"(x_t)$, which is an abbreviation for the posterior
$ "bel"(x_t) = p(x_t | z_(1:t), u_(1:t)) $
This posterior is the probability distribution over the state $x_t $at time $t$, conditioned on all past measurements $z_(1:t)$ and all past controls $u_(1:t)$. This measurement is done after reading $z_t$. We can also calculate belief before (this is sometimes useful), which we will denote
$ overline("bel")(x_t) = p(x_t | z_(1:t-1), u_(1:t)) $
This probability distribution is often referred to as *prediction* in the context of probabilistic filtering. This terminology reflects the fact that $overline("bel")(x_t)$ predicts the state at time $t$ based on the previous state posterior, before incorporating the measurement at time $t$. Calculating $"bel"(x_t)$ from $overline("bel")(x_t)$ is called *correction or the measurement update*.
=== Bayes filter algorithm
The most general algorithm for calculating beliefs is given by the Bayes filter algorithm. This algorithm calculates the belief distribution $"bel"$ from measurement and control data.
#figure(
pseudocode-list[
+ *Algorithm Bayes_filter*($"bel"(x_(t-1)), u_t, z_t$):
		+ $forall x_t$ *do*:
			+ $overline("bel")(x_t) = integral p(x_t | x_(t-1), u_t) dot "bel"(x_(t-1)) d x_(t-1)$
			+ $"bel"(x_t) = eta dot p(z_t | x_t) dot overline("bel")(x_t)$
		+ *return* $"bel"(x_t)$
],caption:"The general algorithm for bayes filter")<alg:bayes_filter>
The algorithm showns in @alg:bayes_filter is recursive, $"bel"(x_t)$ at time $t$ is calculated from the belief $"bel"(x_(t-1))$ at time $t-1$. Its input is the previous belief $"bel"(x_(t-1))$, the most recent control $u_t$ and the measurement $z_t$, and its output is the new belief $"bel"(x_t)$.
The Bayes filter algorithm possesses two essential steps:
- *Prediction*:
  
  In line 3 it processes the control $u_t$.
  It does so by calculating a belief over the state $x_t$ based on the prior belief over state $x_(t-1)$ and the control $u_t$. In particular, the belief $overline("bel")(x_t)$ that the robot assigns to state $x_t$ is obtained by the integral (sum) of the product of two distributions: the prior assigned to $x_(t-1)$, and the probability that control $u_t$ induces a transition from $x_(t-1)$ to $x_t$.
- *Measurement update*:
  
  In line 4, the Bayes filter algorithm multiplies the belief $"bel"(x_t)$ by the probability that the measurement $z_t$ may have been observed. It does so for each hypothetical posterior state $x_t$. As will become apparent further below when actually deriving the basic filter equations, the resulting product is generally not a probability. It may not integrate to 1. Hence, the result is normalized, by virtue of the normalization constant $eta$.

To compute the posterior belief recursively, the algorithm requires an initial belief $"bel"(x_0)$ at time $t = 0$ as boundary condition (base case of recursion).

If one knows the value of $x_0$ with certainty, $"bel"(x_0)$ should be initialized with a point mass distribution that centers all probability mass on the correct value of $x_0$, and assign zero probability to all other values. 

If one is entirely ignorant about the initial value $x_0$, $"bel"(x_0)$ may be initialized using a uniform distribution over
the domain of $x_0$. Partial knowledge of the initial value $x_0$ can be expressed by non-uniform distributions; however, the two cases of full knowledge and full ignorance are the most common ones in practice.
#note[The algorithm Bayes filter can only be implemented in the form stated here for very simple estimation problems. In particular, we either need to be able to carry out the integration in line 3 and the multiplication in line 4 in closed form, or we need to restrict ourselves to finite state spaces, so that the integral in line 3 becomes a (finite) sum.]
==== The markov assumption 
The *Markov assumption*, or the *complete state assumption*, plays a fundamental role in the material presented here.
#proposition[Markov assumption][Past and future data are independent if one knows the current state $x_t$.]
To see how severe an assumption this
is, let us consider our example of mobile robot localization. In mobile robot localization, $x_t$ is the robot’s pose, and Bayes filters are applied to estimate the pose relative to a fixed map. The following factors may have a systematic effect on sensor readings.
Thus, they induce violations of the Markov assumption:
- Unmodeled dynamics in the environment not included in $x_t$ (e.g., moving people and their effects on sensor measurements in our localization example),
- inaccuracies in the probabilistic models $p(z_t | x_t)$ and $p(x_t | u_t, x_(t-1))$ (e.g., an error in the map for a localizing robot),
- approximation errors when using approximate representations of belief functions (e.g., grids or Gaussians), and
- software variables in the robot control software that influence multiple controls (e.g., the variable “target location” typically influences an entire sequence of control commands)
In principle, many of these variables can be included in state representations.

However, incomplete state representations are often preferable to more complete ones to reduce the computational complexity of the Bayes filter algorithm. 
#note[In practice, Bayes filters have been found to be surprisingly robust to such violations.]
#remark[As a general rule of thumb, however, one should exercise care when defining the state $x_t$, so that the effect of unmodeled state variables has close-to-random effects.]
==== Representation and Computation
In probabilistic robotics, Bayes filters are implemented in several different ways. Many different techniques derive from Bayes filters. Each of those relies on different assumptions regarding the measurement and state transition probabilities an the initial belief.
These assumptions then give rise to different types of posterior distributions, and the algorithms for computing them have different computational characteristics.
#remark[As a general rule of thumb, exact techniques for calculating beliefs exist only for highly specialized cases; in general robotics problems, beliefs have to be approximated.]
The nature of the approximation has important ramifications on the complexity of the algorithm. Finding a suitable approximation is usually a challenging problem, with no unique best answer for all robotics problems.

When choosing an approximation, one has to trade off a range of properties:

1. *Computational efficiency*: 
  
	Some approximations, such as linear Gaussian approximations, make it possible to calculate beliefs in time polynomial in the dimension of the state space. Others may require exponential time. Particle-based techniques, discussed further below, have an any-time characteristic, enabling them to trade off accuracy with computational efficiency.
2. *Accuracy of the approximation*:
  
	Some approximations can approximate a wider range of distributions more tightly than others. For example, linear Gaussian approximations are limited to unimodal distributions, whereas histogram representations can approximate multi-modal distributions, albeit with limited accuracy. Particle representations can approximate a wide array of distributions, but the number of particles needed to attain a desired accuracy can be large.
3. *Ease of implementation*:
  
	The difficulty of implementing probabilistic algorithms depends on a variety of factors, such as the form of the measurement probability $p(z_t | x_t)$ and the state transition probability $p(x_t |u_t, x_(t-1))$. Particle representations often yield surprisingly simple implementations for complex nonlinear systems (one of the reasons for their recent popularity).
== Gaussian filters
In this section we present a family of recursive state estimators, called *Gaussian filters*. These filters are the earliest tractable implementations of the Bayes filter for continuous spaces.
They are still the most common technique, despite their shortcoming.
Gaussian techniques all share the basic idea that beliefs are represented by multivariate normal distributions (see @eq:MultivariateNormalDistribution).
This density over the variable $x$ is characterized by two sets of parameters:
- *mean* $mu$: a vector that possesses the same dimensionality as the state $x$
- *covariance* $Sigma$: a quadratic matrix that is symmetric and positive-semidefinite. Its dimension is the dimensionality of the state $x$ squared.
#remark[The number of elements in the covariance matrix depends quadratically on the number of elements in the state vector.]
The commitment to represent the posterior by a Gaussian has important ramifications. Most importantly, Gaussians are *unimodal*; they possess a single maximum. Such a posterior is characteristic of many tracking problems in robotics, in which the posterior is focused around the true state with a
small margin of uncertainty. Gaussian posteriors are a poor match for many global estimation problems in which many distinct hypotheses exist, each of which forms its own mode in the posterior.

The parameterization of a Gaussian by its mean and covariance is called the *moments parameterization*. This is because the mean and covariance are the first and second moments of a probability distribution; all other moments are zero for normal distributions.

Here we will also discuss another parameterization, called *canonical parameterization*, or sometimes natural parameterization. Both parameterization, the moments and the canonical parameterization, are functionally equivalent in that a bijective mapping exists that transforms one into the other. However, they lead to filter algorithms with somewhat different computational characteristics.

As we shall see, the canonical and the natural parameterization are best thought of as duals: what appears to be computationally easy in one parameterization is involved in the other, and vice versa.
=== The Kalman filter
Probably the best studied technique for implementing Bayes filters is the Kalman filter, or (KF).
It was first invented as a technique for filtering and prediction in linear Gaussian systems, which will be defined here.

#note[The Kalman filter implements belief computation for continuous states. It is not applicable to discrete or hybrid state spaces.]
The Kalman filter represents beliefs by the moments parameterization: At time $t$, the belief is represented by the the mean $mu_t$ and the covariance $Sigma_t$.
==== Conditions for Gaussian posteriors
Posteriors are Gaussian if the following three properties hold, in addition to the Markov assumptions of the Bayes filter.
1. The *state transition probability* $p(x_t | u_t, x_(t-1))$ must be a *linear function* in its arguments with added Gaussian noise.
  
  This is expressed by the following equation:
  $ x_t = A_t x_(t-1) + B_t u_t + epsilon t $<eq:LinearStateTransition>
	Where $
	x_t = vec(x_(1,t), x_(2,t), dots.v, x_(n,t)) 
	x_(t-1) = vec(x_(1,t-1), x_(2,t-1), dots.v, x_(n,t-1)) 
	u_t = vec(u_(1,t), u_(2,t), dots.v, u_(m,t)) $ 
	are respectively the state vector at time $t$ and time $t-1$, and the control vector at time $t$.
	$A_t in mat_(n times n)$ and $B_t in mat_(n times m)$ are matrices.
	By multiplying the state and control vector with the matrices $A_t$ and $B_t$, respectively, the state transition function becomes linear in its arguments. Thus, Kalman filters assume linear system dynamics.

	The random variable $epsilon t$ is a Gaussian random vector that models the *uncertainty introduced by the state transition*. It is of the same dimension as the state vector. Its mean is zero, and its covariance will be denoted $R_t$.
	
	A state transition probability of the form shown in @eq:LinearStateTransition is called a *linear Gaussian*, to reflect the fact that it is linear in its arguments with additive Gaussian noise.

	Equation @eq:LinearStateTransition defines the state transition probability $p(x_t | u_t, x_(t-1))$. This probability is obtained by plugging Equation @eq:LinearStateTransition into the definition of the multivariate normal distribution @eq:MultivariateNormalDistribution. 
	
	The mean of the posterior state is given by $A_t x_(t-1) + B_t u_t$ and the covariance by $R_t$:
	$ p(x_t | u_t, x_(t-1)) = & det(2pi R_t)^(-1/2) dot\ & exp(-1/2 (x_t - A_t x_(t-1) + B_t u_t)^T R_t^(-1) (x_t - A_t x_(t-1) + B_t u_t)) $
	2. The *measurement probability* $p(z_t | x_t)$ must also be *linear* in its arguments, with added Gaussian noise:
	$ z_t = C_t x_t + delta_t $
	Here $C_t$ is a matrix of size $k times n$, where $k$ is the dimension of the measurement vector $z_t$. The vector $delta_t$ describes the measurement noise. The distribution of $delta_t$ is a multivariate Gaussian with zero mean and covariance $Q_t$.

	The measurement probability is thus given by the following multivariate normal distribution:
	$ p(z_t | x_t) =  det(2pi Q_t)^(-1/2) dot exp(-1/2 (z_t - C_t x_t)^T Q_t^(-1) (z_t - C_t x_t)) $
	3. The initial belief $"bel"(x_0)$ must be a Gaussian distribution.
  We will denote the mean of this belief by $mu_0$ and the covariance by $Sigma_0$:
	$ "bel"(x_0)=p(x_0)= det(2pi Sigma_0)^(-1/2) dot exp(-1/2 (x_0 - mu_0)^T Sigma_0^(-1) (x_0 - mu_0)) $
These three assumptions are sufficient to ensure that the posterior $"bel"(x_t)$ is always a Gaussian, for any point in time $t$. The proof is not trivial and will not be discussed here.
==== The algorithm
#figure(
pseudocode-list[
  + *Algorithm Kalman_filter*($mu_(t-1), Sigma_(t-1), u_t, z_t$):
	+ $overline(mu)_t = A_t mu_(t-1) + B_t u_t$
	+ $overline(Sigma)_t = A_t Sigma_(t-1) A_t^T + R_t$
	+ $K_t = overline(Sigma)_t C_t^T (C_t overline(Sigma)_t C_t^T + Q_t)^(-1)$
	+ $mu_t = overline(mu)_t + K_t (z_t - C_t overline(mu)_t)$
	+ $Sigma_t = (I - K_t C_t) overline(Sigma)_t$

	+ *return* $mu_t,Sigma_t$
],caption:"The Kalman filter algorithm for linear Gaussian state transitions and measurements") <alg:kalman_filter>
Kalman filters represent the belief $"bel"(x_t)$ at time $t$ by the mean $mu_t$ and the covariance $Sigma_t$.

The input of the Kalman filter is the belief at time $t - 1$, represented by $mu_(t-1)$ and $Sigma_(t-1)$.
To update these parameters, Kalman filters require the control $u_t$ and the measurement $z_t$. The output is the belief at time $t$, represented by $mu_t$ and $Sigma_t$.
- In lines 2 and 3, the predicted belief $overline(mu)_t$ and $overline(Sigma)_t$ is calculated representing the belief $"bel"(x_t)$ one time step later, but before incorporating the measurement $z_t$. This belief is obtained by incorporating the control $u_t$. 

	- The mean is updated using the deterministic version of the state transition function, with the mean $mu_(t-1)$ substituted for the state $x_(t-1)$.
	- The update of the covariance considers the fact that states depend on previous states through the linear matrix $A_t$. This matrix is multiplied twice into the covariance, since the covariance is a quadratic matrix.

- The belief $"bel"(x_t)$ is subsequently transformed into 	the desired belief $"bel"(x_t)$ in lines 4 through 6, by incorporating the measurement $z_t$. 
 
  The variable $K_t$, computed in line 4 is called *Kalman gain*, which specifies the degree to which the measurement is incorporated into the new state estimate.
- Line 5 manipulates the mean, by adjusting it in proportion to the Kalman gain $K_t$ and the deviation of the actual measurement, $z_t$, and the measurement predicted according to the measurement probability. The key concept here is the *innovation*, which is the difference between the actual measurement $z_t$ and the expected measurement $C_t overline(mu)_t$ in line 5.
- Finally, the new covariance of the posterior belief is calculated in line 6, adjusting for the information gain resulting from the measurement.

#note[The Kalman filter is computationally quite efficient. For today’s best algorithms, the complexity of matrix inversion is approximately $O(d^(2.4))$ for a matrix of size $d times d$.]
#remark[Each iteration of the Kalman filter algorithm, as stated here, is lower bounded by (approximately) $O(k^(2.4))$, where $k$ is the dimension of the measurement vector $z_t$. This (approximate) cubic complexity stems from the
matrix inversion in line 4.]
Even for certain sparse updates, it is also at least in $O(n^2)$, where $n$ is the dimension of the state space, due to the multiplication in line 6 (the matrix $K_t C_t$ may be sparse).

In many applications, such as the robot mapping applications, the measurement space is much lower dimensional than the state space, and the update is dominated by the $O(n^2)$ operations.
==== 1D Kalman filter example
@fig:kalman_filter_1d_example illustrates the Kalman filter algorithm for a simplistic one-dimensional localization scenario. Suppose the robot moves along the horizontal axis in each diagram in @fig:kalman_filter_1d_example. 
1. Let the prior over the robot location be given by the normal distribution shown in @fig:kalman_filter_1d_example(a). 
2. The robot queries its sensors on its location (e.g., a GPS system), and those return a measurement that is centered at the peak of the red Gaussian in @fig:kalman_filter_1d_example(b). This red Gaussian illustrates this measurement: Its peak is the value predicted by the sensors, and its width (variance) corresponds to the uncertainty in the measurement. 
3. Combining the prior with the measurement, via lines 4 through 6 of the Kalman filter algorithm, yields the bold Gaussian in @fig:kalman_filter_1d_example(c). 
   
	This belief’s mean lies between the two original means, and its uncertainty radius is smaller than both contributing Gaussians. The fact that the residual uncertainty is smaller than the contributing Gaussians may appear counter-intuitive, but it is a general characteristic of information integration in Kalman filters.
4. Next, assume the robot moves towards the right. Its uncertainty grows due to the fact that the state transition is stochastic. 
5. Lines 2 and 3 of the Kalman filter provide us with the Gaussian shown in bold in @fig:kalman_filter_1d_example(d). This Gaussian is shifted by the amount the robot moved, and it is also wider for the reasons just explained.
6. The robot receives a second measurement illustrated by the red Gaussian in @fig:kalman_filter_1d_example(e), which leads to the posterior shown in bold in @fig:kalman_filter_1d_example(f). 

As this example illustrates, the Kalman filter alternates a measurement update step (lines 5-7), in which sensor data is integrated into the present belief, with a prediction step (or control update step), which modifies the belief in accordance to an action. The update step decreases and the prediction step increases uncertainty in the robot’s belief.
// 1D Gaussian PDF
#let gaussian(x, mu, var) = {
  1 / calc.sqrt(2 * calc.pi * var) * calc.exp(-((x - mu) * (x - mu)) / (2 * var))
}

// High-contrast, colorblind-friendly palette
#let col-belief      = rgb("#005AB5") // Vivid blue: active / resulting belief
#let col-measurement = rgb("#DC3220") // Vermilion red: new measurement
#let col-prior       = rgb("#7A869A") // Muted slate: prior belief
#let col-prior-meas  = rgb("#E07A5F") // Soft coral (dashed): prior measurement

#let st-belief      = (paint: col-belief, thickness: 1.6pt)
#let st-measurement = (paint: col-measurement, thickness: 1.6pt)
#let st-prior       = (paint: col-prior, thickness: 1.0pt)
#let st-prior-meas  = (paint: col-prior-meas, thickness: 1.0pt, dash: "dashed")

// Helper for a single subplot panel
#let kf-panel(label, curves) = {
  grid(
    columns: (auto, 1fr),
    column-gutter: 4pt,
    align: (top, top),
    text(weight: "bold", size: 9.5pt)[#label],
    {
      set text(size: 6.5pt)
      cetz.canvas({
        plot.plot(
          size: (4.9, 3.35),
          x-min: 0,
          x-max: 30,
          y-min: 0,
          y-max: 0.25,
          x-tick-step: 5,
          y-tick-step: 0.05,
          x-label: none,
          y-label: none,
          {
            for c in curves {
              plot.add(
                domain: (0, 30),
                samples: 200,
                style: (stroke: c.stroke),
                x => gaussian(x, c.mu, c.var),
              )
            }
          },
        )
      })
    },
  )
}

// Exact 1D Kalman filter parameters matching the original figure
#let mu0 = 8.0
#let var0 = 16.0

#let z1 = 6.0
#let var-z1 = 4.0

#let k1 = var0 / (var0 + var-z1) // 0.8
#let mu1 = mu0 + k1 * (z1 - mu0) // 6.4
#let var1 = (1 - k1) * var0 // 3.2

#let u = 15.0
#let var-u = 9.0
#let mu2-pred = mu1 + u // 21.4
#let var2-pred = var1 + var-u // 12.2

#let z2 = 25.0
#let var-z2 = 9.0
#let k2 = var2-pred / (var2-pred + var-z2) // ~0.5755
#let mu2 = mu2-pred + k2 * (z2 - mu2-pred) // ~23.4717
#let var2 = (1 - k2) * var2-pred // ~5.1792

// Legend swatch helper
#let swatch(stroke-style, label) = box[
  #box(width: 14pt, height: 6pt, baseline: 1pt, line(length: 14pt, stroke: stroke-style))
  #h(3pt)#label
]

#figure(
  block(width: 13.4cm)[
    // Compact color legend above the grid
    #align(center)[
      #set text(size: 8pt)
      #swatch(st-belief)[Active / updated belief]
      #h(10pt)
      #swatch(st-measurement)[New measurement]
      #h(10pt)
      #swatch(st-prior)[Prior belief]
      #h(10pt)
      #swatch(st-prior-meas)[Prior measurement]
    ]
    #v(4pt)
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 18pt,
      row-gutter: 12pt,
      // (a) Initial belief
      kf-panel("(a)", (
        (mu: mu0, var: var0, stroke: st-belief),
      )),
      // (b) Measurement with associated uncertainty
      kf-panel("(b)", (
        (mu: mu0, var: var0, stroke: st-prior),
        (mu: z1, var: var-z1, stroke: st-measurement),
      )),
      // (c) Belief after integrating the measurement
      kf-panel("(c)", (
        (mu: mu0, var: var0, stroke: st-prior),
        (mu: z1, var: var-z1, stroke: st-prior-meas),
        (mu: mu1, var: var1, stroke: st-belief),
      )),
      // (d) Belief after motion to the right
      kf-panel("(d)", (
        (mu: mu1, var: var1, stroke: st-prior),
        (mu: mu2-pred, var: var2-pred, stroke: st-belief),
      )),
      // (e) New measurement with associated uncertainty
      kf-panel("(e)", (
        (mu: mu2-pred, var: var2-pred, stroke: st-prior),
        (mu: z2, var: var-z2, stroke: st-measurement),
      )),
      // (f) Resulting belief
      kf-panel("(f)", (
        (mu: mu2-pred, var: var2-pred, stroke: st-prior),
        (mu: z2, var: var-z2, stroke: st-prior-meas),
        (mu: mu2, var: var2, stroke: st-belief),
      )),
    )
  ],
  caption: [
    Illustration of Kalman filters: *(a)* initial belief (blue), *(b)* a measurement (red) with the associated uncertainty alongside the prior belief (gray), *(c)* belief after integrating the measurement into the belief using the Kalman filter algorithm (blue), *(d)* belief after motion to the right (blue), which introduces uncertainty, *(e)* a new measurement (red) with associated uncertainty, and *(f)* the resulting belief (blue).
  ],
)<fig:kalman_filter_1d_example>
=== The extended Kalman filter