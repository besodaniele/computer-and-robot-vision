#import "@preview/scholia:0.1.0": *
#import "@preview/lovelace:0.3.1": *
#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot
#import "utils/fig33-helpers.typ": fig-gaussian-transform
#import "utils/kalman-figure.typ": fig-kalman-filter
#import "utils/fig34-helpers.typ": fig-ekf-linearization
#import "utils/fig35-helper.typ": fig-ekf-uncertainty
#import "utils/fig36-helper.typ": fig-ekf-nonlinearity
#import "utils/fig37-helpers.typ": fig-ukf-linearization
#import "utils/fig38-helpers.typ": fig-ukf-uncertainty
#import "utils/fig39-helpers.typ": fig-ukf-nonlinearity
#import "utils/fig41-helpers.typ": fig-histogram-transform
#import "utils/fig43-helpers.typ": fig-particle-representation
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
- *the accuracy* of the robot’s *models*, thereby relieving the programmer from the insurmountable burden to come up with accurate models. 
- *the accuracy* of robotic *sensors* than those made by many reactive techniques, whose sole control input is the momentary sensor input. 
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
- In robot manipulation, the pose includes variables for the *configuration* of the robot’s *actuators*. 
  #example[For example, they might include the joint angles of revolute joints. Each degree of freedom in a robot arm is characterized by a one-dimensional configuration at any point in time, which is part of the kinematic state of the robot. The robot configuration is often referred to as *kinematic state*.]
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
	Perception is the process by which the robot uses its sensors to obtain information about the state of its environment. The result of such a perceptual interaction will be called *measurement*, although we will sometimes also call it observation or percept. 
]
#example[For example, a robot might take a camera image, a range scan, or query its tactile sensors to receive information about the state of the environment.]
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
being generated*. Again, if $x_t$ is complete, we have an important conditional independence:
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
@fig:HMM shows the evolution of states and measurements, defined
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
=== Bayes filter algorithm <sec:bayes_filter>
The most general algorithm for calculating beliefs is given by the Bayes filter algorithm. This algorithm calculates the belief distribution $"bel"$ from measurement and control data.
#figure(
pseudocode-list(line-gap: 1em)[
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
  It does so by calculating a belief over the state $x_t$ based on the prior belief over state $x_(t-1)$ and the control $u_t$. In particular, the belief  $overline("bel")(x_t)$ that the robot assigns to state $x_t$ is obtained by the integral (sum) of the product of two distributions: the prior assigned to $x_(t-1)$, and the probability that control $u_t$ induces a transition from $x_(t-1)$ to $x_t$.

- *Measurement update*:
  
  In line 4, the Bayes filter algorithm multiplies the belief $overline("bel")(x_t)$ by the probability that the measurement $z_t$ may have been observed. It does so for each hypothetical posterior state $x_t$. As will become apparent further below when actually deriving the basic filter equations, the resulting product is generally not a probability. It may not integrate to 1. Hence, the result is normalized, by virtue of the normalization constant $eta$.

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

	@eq:LinearStateTransition defines the state transition probability $p(x_t | u_t, x_(t-1))$. This probability is obtained by plugging @eq:LinearStateTransition into the definition of the multivariate normal distribution (see @eq:MultivariateNormalDistribution). 
	
	The mean of the posterior state is given by $A_t x_(t-1) + B_t u_t$ and the covariance by $R_t$:
	$ p(x_t | u_t, x_(t-1)) = & det(2pi R_t)^(-1/2) dot\ & exp(-1/2 (x_t - A_t x_(t-1) + B_t u_t)^T R_t^(-1) (x_t - A_t x_(t-1) + B_t u_t)) $
	1. The *measurement probability* $p(z_t | x_t)$ must also be *linear* in its arguments, with added Gaussian noise:
	$ z_t = C_t x_t + delta_t $<eq:LinearMeasurement>
	Here $C_t$ is a matrix of size $k times n$, where $k$ is the dimension of the measurement vector $z_t$. The vector $delta_t$ describes the measurement noise. The distribution of $delta_t$ is a multivariate Gaussian with zero mean and covariance $Q_t$.

	The measurement probability is thus given by the following multivariate normal distribution:
	$ p(z_t | x_t) =  det(2pi Q_t)^(-1/2) dot exp(-1/2 (z_t - C_t x_t)^T Q_t^(-1) (z_t - C_t x_t)) $
	2. The initial belief $"bel"(x_0)$ must be a Gaussian distribution.
  We will denote the mean of this belief by $mu_0$ and the covariance by $Sigma_0$:
	$ "bel"(x_0)=p(x_0)= det(2pi Sigma_0)^(-1/2) dot exp(-1/2 (x_0 - mu_0)^T Sigma_0^(-1) (x_0 - mu_0)) $
These three assumptions are sufficient to ensure that the posterior $"bel"(x_t)$ is always a Gaussian, for any point in time $t$. The proof is not trivial and will not be discussed here.
==== The algorithm
#figure(
pseudocode-list(line-gap: 1em)[
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
#fig-kalman-filter() <fig:kalman_filter_1d_example>
=== The extended Kalman filter
The assumptions that observations are linear functions of the state and that the next state is a linear function of the previous state are crucial for the correctness of the Kalman filter.
The observation that any linear transformation
of a Gaussian random variable results in another Gaussian random variable played an important role in the derivation of the Kalman filter algorithm.
The efficiency of the Kalman filter is then due to the fact that the parameters of the resulting Gaussian can be computed in closed form.

Throughout this and the following chapters, we will illustrate properties of different density representations using the transformation of a one-dimensional Gaussian random variable. 

@fig:gaussian_transform(a) shows the *linear* transformation of such variable. 
The graph on the lower right shod ws the density of the random variable $X ~ N (x; mu, sigma^2)$. Let us assume
that $X$ is passed through the linear function $y = a x + b$, shown in the upper right graph. The resulting random variable, $Y$ , is distributed according to a
Gaussian with mean $a mu + b$ and variance $a^a sigma^2$, this gaussian is shown as an orange area in the upper left corner. 
#fig-gaussian-transform()<fig:gaussian_transform>
#note[Unfortunately, state transitions and measurements are rarely linear in practice.
For example, a robot that moves with constant translational and rotational velocity typically moves on a circular trajectory, which cannot be described by linear state transitions.
This observation, along with the assumption of unimodal beliefs, renders plain Kalman filters, as discussed so
far, inapplicable to all but the most trivial robotics problems.]
The *extended Kalman filter*, or *EKF*, relaxes the linearity assumption of the Kalman filter.

Here the assumption is that the state transition probability and the measurement probabilities are governed by nonlinear functions $g$ and $h$, respectively:
- $x_t = g(u_t, x_(t-1))$
- $z_t = h(x_t) + delta_t$
This model strictly generalizes the linear Gaussian model underlying Kalman filters, as postulated in @eq:LinearStateTransition and @eq:LinearMeasurement. 
The function $g$ replaces the matrices $A_t$ and $B_t$ in @eq:LinearStateTransition, and the function $h$ replaces the matrix $C_t$ in @eq:LinearMeasurement. With arbitrary $h$ and $g$ the belief is no longer guaranteed to be Gaussian.
In fact, performing the belief update exactly is usually impossible for nonlinear functions g and h, and the Bayes filter does not possess a closed-form solution.
In figure @fig:gaussian_transform(b) we illustrate the effect of a nonlinear transformation on a Gaussian random variable. The upper right graph shows the nonlinear function $y = x^2$ and the lower right graph shows the density of the random variable $X ~ N (x; mu, sigma^2)$. The resulting random variable $Y$ is no longer Gaussian, as shown in the upper left graph.
#note[Since this density cannot be computed in closed form, it was estimated by drawing 500,000 samples according to $p(x)$, passing them through the function $g$, and then histogramming over the range of $g$.]
As can be seen, $Y $ is not a Gaussian because the non linearities in $g$ distort the density of $X$ in ways that destroy its Gaussian shape.

The extended Kalman filter (EKF) calculates a *Gaussian approximation to the true belief*. The dashed curve in the upper left graph of @fig:gaussian_transform(b) shows the Gaussian approximation to the density of the random variable $Y$.
Accordingly, EKFs represent the belief $"bel"(x_t)$ at time $t$ by a mean $mu_t$ and a
covariance $Sigma_t$. Thus, the EKF inherits from the Kalman filter the basic belief representation, but it differs in that this belief is only approximate, not exact as was the case in Kalman filters. The goal of the EKF is thus shifted from
computing the exact posterior to efficiently estimating its mean and covariance. However, since these statistics cannot be computed in closed form, the EKF has to resort to an additional approximation.
==== Linearization trough Taylor expansion
The key idea underlying the EKF approximation is called linearization. The basic idea is shown in @fig:ekf-linearization.
Linearization approximates the nonlinear function $g$ by a linear function that is tangent to $g$ at the mean of the Gaussian (dashed line in the upper right graph).
Projecting the Gaussian through this linear approximation results in a Gaussian density, as indicated by the dashed line in the upper left graph. The solid line in the upper left graph represents the mean and covariance of the Monte-Carlo approximation. 
The mismatch between these two Gaussians indicates the error caused
by the linear approximation of $g$.
#note[The key advantage of the linearization, however, lies in its efficiency.]
The Monte-Carlo estimate of the Gaussian was achieved by passing 500,000 points through $g$ followed by the computation of their mean and covariance.
The linearization applied by the EKF, on the other hand, only requires determination of the linear approximation followed by the closed-form computation of the resulting Gaussian. 
In fact, once $g$ is linearized, the mechanics of
the EKF’s belief propagation are equivalent to those of the Kalman filter.

This technique also is applied to the multiplication of Gaussians when a measurement function h is involved. Again, the EKF approximates $h$ by a linear function tangent to $h$, thereby retaining the Gaussian nature of the posterior belief.
#fig-ekf-linearization()<fig:ekf-linearization>
There are many techniques for linearizing nonlinear functions. EKFs
utilize a method called (first order) Taylor expansion. Taylor expansion constructs a linear approximation to a function $g$ from $g$’s value and slope.

The slope is given by the partial derivative
$ g'(u_t,x_(t-1)) := (partial g(u_t,x_(t-1)))/(partial x_(t-1)) $
Clearly, both the value of $g$ and its slope depend on the argument of $g$. 
A logical choice for selecting the argument is to choose the state deemed most likely at the time of linearization. For Gaussians, the most likely state is the mean of the posterior $mu_(t-1)$. In other words, $g$ is approximated by its
value at $mu_(t-1)$ (and at $u_t$), and the linear extrapolation is achieved by a term proportional to the gradient of $g$ at $mu_(t-1)$ and $u_t$:
$ g(u_t, x_(t-1)) approx & 
g(u_t,mu_(t-1)) + underbrace(g'(u_t,mu_(t-1)),=:G_t)(x_(t-1) - mu_(t-1)) \
 = & g(u_t,mu_(t-1)) + G_t (x_(t-1) - mu_(t-1)) 
$
Which written as a Gaussian it expands to:
$ 
p(x_t | u_t, x_(t-1)) &approx  det(2pi R_t)^(-1/2)\ &dot exp{-1/2 [x_t - g(u_t,mu_(t-1)) - G_t (x_(t-1) - mu_(t-1))]^T \ & R_t^(-1) [x_t - g(u_t,mu_(t-1)) - G_t (x_(t-1) - mu_(t-1))]}
$

Notice that $G_t$ is a matrix of size $n times n$, with $n$ denoting the dimension of the state. This matrix is often called the *Jacobian*. The value of the Jacobian depends on $u_t$ and $mu_(t-1)$, hence it differs for different points in time.

EKFs implement the exact same linearization for the measurement function $h$. Here the Taylor expansion is developed around $overline(mu)_t$, the state deemed most likely by the robot at the time it linearizes $h$:
$  
h(x_t) &approx h(overline(mu)_t) + underbrace(h'(overline(mu)_t),=:H_t)(x_t - overline(mu)_t) \
&= h(overline(mu)_t) + H_t (x_t - overline(mu)_t)
$
With $h'(x_t)=(partial h(x_t))/(partial x_t)$ written as a Gaussian we have:
$
p(z_t | x_t) approx & det(2pi Q_t)^(-1/2) dot \ &exp{-1/2 [z_t - h(overline(mu)_t) - H_t (x_t - overline(mu)_t)]^T Q_t^(-1) [z_t - h(overline(mu)_t) - H_t (x_t - overline(mu)_t)]}
$ 
==== The algorithm
#figure(
pseudocode-list(line-gap: 1em)[
	+ *Algorithm Extended_Kalman_filter*($mu_(t-1), Sigma_(t-1), u_t, z_t$):
		+ $overline(mu)_t = g(u_t, mu_(t-1))$
		+ $overline(Sigma)_t = G_t Sigma_(t-1) G_t^T + R_t$
		+ $K_t = overline(Sigma)_t H_t^T (H_t overline(Sigma)_t H_t^T + Q_t)^(-1)$
		+ $mu_t = overline(mu)_t + K_t (z_t - h(overline(mu)_t))$
		+ $Sigma_t = (I - K_t H_t) overline(Sigma)_t$
		+ *return* $mu_t,Sigma_t$
],caption:"The extended Kalman filter algorithm for nonlinear state transitions and measurements") <alg:extended_kalman_filter>
In many ways, this algorithm is similar to the Kalman filter algorithm. The most important differences are summarized by the following table:
#table(
	columns: (auto, auto, auto),
  inset: 10pt,
	align: horizon,
	table.header([],[Kalman filter],[Extended Kalman filter]),
	"state prediction (line 2)", $A_t mu_(t-1) + B_t u_t$, $g(u_t, mu_(t-1))$,
	"measurement prediction (line 5)", $C_t overline(mu)_t$, $h(overline(mu)_t)$
)
That is, the linear predictions in Kalman filters are replaced by their nonlinear generalizations in EKFs. Moreover, EKFs use Jacobians $G_t$ and $H_t$ instead of the corresponding linear system matrices $A_t$, $B_t$, and $C_t$ in Kalman filters.
The Jacobian $G_t$ corresponds to the matrices $A_t$ and $B_t$, and the Jacobian $H_t$ corresponds to $C_t$.
==== Practical considerations
The EKF has become just about the most popular tool for state estimation in robotics. Its strength lies in its simplicity and in its computational efficiency.
Each update requires time $O(k^2.4 +n^2)$, where $k$ is the dimension of the measurement vector $z_t$, and $n$ is the
dimension of the state vector $x_t$. Other algorithms, such as the particle filter discussed further below, may require time exponential in $n$.

The EKF owes its computational efficiency to the fact that it represents the belief by a multivariate Gaussian distribution. A Gaussian is a unimodal distribution, which can be thought of as a single guess annotated with an uncertainty ellipse. In many practical problems, Gaussians are robust estimators.

An important limitation of the EKF arises from the fact that it approximates state transitions and measurements using linear Taylor expansions. 
#note[In most robotics problems, state transitions and measurements are nonlinear.]
The goodness of the linear approximation applied by the EKF depends on two main factors: 
1. The *degree of uncertainty*
   
	The two graphs in @fig:ekf-uncertainty illustrate the dependency on the uncertainty. Here, two Gaussian random variables are passed through the same nonlinear function. While both Gaussians have the same mean, the variable shown in (a) has a higher uncertainty than the one in (b). Since the Taylor expansion only depends on the mean, both Gaussians are passed through the same linear approximation.

	The orange areas in the upper left plots of the two figures show the densities of the resulting random variable, computed by Monte-Carlo estimation. The density resulting from the wider Gaussian is far more distorted than the density resulting from the narrow, less uncertain Gaussian. The Gaussian approximations of these densities are given by the solid lines in the figures.

	The dashed graphs show the Gaussians estimated by the linearization. A comparison to the Gaussians resulting from the Monte-Carlo approximations illustrates the fact that higher uncertainty typically results in less accurate estimates of the mean and covariance of the resulting random variable.
2. The *degree of local nonlinearity* of the functions $g$ and $h$.
	Look at @fig:ekf-nonlinearity, there are two Gaussians with the same variance passed through the same nonlinear function. In Panel (a), the mean of the Gaussian falls into a more nonlinear region of the function $g$ than in Panel (b). 
	
	The mismatch between the accurate Monte-Carlo estimate of the Gaussian (solid line, upper left) and the Gaussian resulting from linear approximation (dashed line) shows that higher nonlinearities result in larger approximation errors. The EKF Gaussian clearly underestimates the spread of the resulting density.

Sometimes, one might want to pursue multiple distinct hypotheses. For example, a robot might have two distinct hypotheses as to where it is, but the arithmetic mean of these hypotheses is not a likely contender. Such situations require multi-modal representations for the posterior belief. EKFs, in the form described here, are incapable of representing such multimodal beliefs.
A common extension of EKFs is to represent posteriors using *mixtures, or sums, of Gaussians*. 

A mixture of Gaussians may be of the form
$ 
"bel"(x_t) = 1/(sum_l psi_(t,l)) sum_l psi_(t,l) det(2pi Sigma_(t,l))^(-1/2) dot exp{-1/2 (x_t - mu_(t,l))^T Sigma_(t,l)^(-1) (x_t - mu_(t,l))}
$
Where $psi_(t,l)$ are mixture parameters, with $psi_(t,l)>=0$.
These parameters serve as weights of the mixture components. They are estimated from the likelihoods of the observations conditioned on the corresponding Gaussians.
EKFs that utilize such mixture representations are called multi-hypothesis (extended) Kalman filters, or MHEKF.
#fig-ekf-uncertainty()<fig:ekf-uncertainty>
#fig-ekf-nonlinearity()<fig:ekf-nonlinearity>
=== The unscented Kalman filter
The Taylor series expansion applied by the EKF is only one way to linearize the transformation of a Gaussian.
Two other approaches have often been found to yield *superior results*. One is known as moments matching (and the resulting filter is known as *assumed density filter*, or ADF), in which the linearization is calculated in a way that preserves the true mean and the true covariance of the posterior distribution (which is not the case for EKFs.
Another linearization method is applied by the *unscented Kalman filter*, or UKF, which performs a stochastic linearization through the use of a weighted statistical linear regression process.
==== Linearization Via the Unscented Transform
Figure @fig:ukf-linearization illustrates the linearization applied by the UKF, called the *unscented transform*. 

Instead of approximating the function $g$ by a Taylor series
expansion, the UKF deterministically extracts so-called *sigma points* from the Gaussian and passes these through $g$.

In the general case, these sigma points
are located at the mean and symmetrically along the main axes of the covariance (two per dimension). 

#fig-ukf-linearization()<fig:ukf-linearization>


For an n-dimensional Gaussian with mean $mu$ and covariance $Sigma$, the resulting $2n + 1$ sigma points $cal(X)^[i]$ are chosen according to
the following rule:
$
cal(X)^[0] &= mu \ 
cal(X)^[i] &= mu + (sqrt((n + lambda) Sigma))_i quad  "for" i = 1, dots, n \
cal(X)^[i] &= mu - (sqrt((n + lambda) Sigma))_(i-n) quad  "for" i = n + 1, dots, 2n

$<eq:ukf-sigma-points>
Here $lambda = alpha 2(n+kappa)-n$, with $alpha$ and $kappa$ being scaling parameters that determine how far the sigma points are spread from the mean. Each sigma point $cal(X)^[i]$
has two weights associated with it. One weight, $w^[i]_m$
, is used when computing the mean, the other weight, $w^[i]_c$ , is used when recovering the covariance of the Gaussian.
$ 
w^[0]_m &= lambda/(n + lambda) \
w^[0]_c &= lambda/(n + lambda) + (1 - alpha^2 + beta) \
w^[i]_m &= w^[i]_c = 1/(2(n + lambda)) quad  "for" i = 1, dots, 2n
$
The parameter $beta$ can be chosen to encode additional (higher order) knowledge about the distribution underlying the Gaussian representation. If the distribution is an exact Gaussian, then $beta = 2$ is the optimal choice.

The sigma points are then passed through the function $g$, thereby probing how $g$ changes the shape of the Gaussian.
$
cal(Y)^[i] = g(cal(X)^[i])
$
The parameters $(mu′ Sigma′)$ of the resulting Gaussian are extracted from the mapped sigma points $cal(Y)^[i]$ according to
$
mu' &= sum_(i=0)^(2n) w_m^[i] cal(Y)^[i] \
Sigma' &= sum_(i=0)^(2n) w_c^[i] (cal(Y)^[i] - mu')(cal(Y)^[i] - mu')^T
$
@fig:ukf-uncertainty illustrates the dependency of the unscented transform on the uncertainty of the original Gaussian. For comparison, the results using the EKF Taylor series expansion are plotted alongside the UKF results.

@fig:ukf-nonlinearity  shows an additional comparison between UKF and EKF approximation, here in dependency of the local nonlinearity of the function $g$. As can be seen, the unscented transform is more accurate than the first order
Taylor series expansion applied by the EKF. In fact, it can be shown that the unscented transform is accurate in the first two terms of the Taylor expansion, while the EKF captures only the first order term. 
#fig-ukf-uncertainty()<fig:ukf-uncertainty>
#fig-ukf-nonlinearity()<fig:ukf-nonlinearity>
==== The algorithm

#figure(
pseudocode-list(line-gap: 1em)[
  + *Algorithm Unscented_Kalman_filter*($mu_(t-1), Sigma_(t-1), u_t, z_t$):
    + $cal(X)_(t-1) = (mu_(t-1), mu_(t-1) + gamma sqrt(Sigma_(t-1)), mu_(t-1) - gamma sqrt(Sigma_(t-1)))$
    + $cal(X)_t^[i] = g(u_t, cal(X)_(t-1)^[i])$
    + $overline(mu)_t = sum_(i=0)^(2n) w_m^[i] cal(X)_t^[i]$
    + $overline(Sigma)_t = sum_(i=0)^(2n) w_c^[i] (cal(X)_t^[i] - overline(mu)_t) (cal(X)_t^[i] - overline(mu)_t)^T + R_t$
    + $overline(cal(X))_t = (overline(mu)_t, overline(mu)_t + gamma sqrt(overline(Sigma)_t), overline(mu)_t - gamma sqrt(overline(Sigma)_t))$
    + $overline(cal(Z))_t = h(overline(cal(X))_t)$
    + $hat(z)_t = sum_(i=0)^(2n) w_m^[i] overline(cal(Z))_t^[i]$
    + $S_t = sum_(i=0)^(2n) w_c^[i] (overline(cal(Z))_t^[i] - hat(z)_t) (overline(cal(Z))_t^[i] - hat(z)_t)^T + Q_t$
    + $overline(Sigma)^(x,z)_t = sum_(i=0)^(2n) w_c^[i] (overline(cal(X))_t^[i] - overline(mu)_t) (overline(cal(Z))_t^[i] - hat(z)_t)^T$
    + $K_t = overline(Sigma)^(x,z)_t S_t^(-1)$
    + $mu_t = overline(mu)_t + K_t (z_t - hat(z)_t)$
    + $Sigma_t = overline(Sigma)_t - K_t S_t K_t^T$
    + *return* $mu_t,Sigma_t$
],caption:"The unscented Kalman filter algorithm") <alg:unscented_kalman_filter>
The UKF algorithm utilizing the unscented transform is presented in @alg:unscented_kalman_filter.
The input and output are identical to the EKF algorithm. 
- Line 2 determines the sigma points of the previous belief using @eq:ukf-sigma-points, with $gamma$ short for $sqrt(n) + lambda$. 
- These points are propagated through the noise-free state prediction in line 3.
- The predicted mean and variance are then computed from the resulting sigma points (lines 4 and 5). Rt in line 5 is added to the sigma point covariance in order to model the additional prediction noise uncertainty (compare to line 3 of the EKF algorithm @alg:kalman_filter).
	#note[The prediction noise Rt is assumed to be additive.]
- A new set of sigma points is extracted from the predicted Gaussian in line 6. This sigma point set $overline(cal(X))_t$ now captures the overall uncertainty after the prediction step.
- In line 7, a predicted observation is computed for each sigma point. The resulting observation sigma points $overline(cal(Z))_t$ are used to compute the predicted observation $hat(z)_t$ and its uncertainty, $S_t$. The matrix 	$Q_t$ is the covariance matrix of the additive measurement noise. #note[Note that $S_t$ represents the same uncertainty as $H_t overline(Sigma)_t H_t^T + Q_t$ in line 4 of the EKF algorithm in @alg:extended_kalman_filter.]
- Line 10 determines the cross-covariance between state and observation, which is then used in line 11 to compute the Kalman gain $K_t$. The cross-covariance $overline(Sigma)^(x,z)_t$ corresponds to the term $overline(Sigma)_t H_t^T$ in line 4 of the EKF algorithm. 
- With this in mind it is straightforward to show that the estimation update performed in lines 12 and 13 is of equivalent form to the update performed by the EKF algorithm.

The asymptotic complexity of the UKF algorithm is the same as for the EKF. In practice, the EKF is often slightly faster than the UKF. The UKF is still highly efficient, even with this slowdown by a constant factor. Furthermore, the UKF inherits the benefits of the unscented transform for linearization.
- For purely linear systems, it can be shown that the estimates generated by the UKF are identical to those generated by the Kalman filter.
- For non linear systems the UKF produces equal or better results than the EKF, where the improvement over the EKF depends on the nonlinearities and spread of the prior state uncertainty.
#note[In many practical applications, the difference
between EKF and UKF is negligible.]
Another advantage of the UKF is the fact that it does not require the computation of Jacobians, which are *difficult to determine in some domains*. 
#note[The UKF is thus often referred to as a *derivative-free* filter.]
=== The information filter
The dual of the Kalman filter is the information filter, or IF. Just like the KF and its nonlinear versions, the EKF and the UKF, the information filter represents the belief by a Gaussian.
Thus, the standard information filter is subject to the same assumptions underlying the Kalman filter. The key difference between the KF and the IF arises from the way the Gaussian belief is represented.

Whereas in the Kalman filter family of algorithms, Gaussians are represented by their moments (mean, covariance), information filters represent Gaussians in their canonical parameterization, which is comprised of an information matrix and an information vector. 
The difference in parameterization leads to different update equations. In particular, what is computationally complex in one parameterization happens to be simple in the other (and vice versa). The canonical and the moments parameterizations are often considered dual to each other, and thus are the IF and the KF.
==== Canonical Parameterization
#definition[Canonical parameterization of a Gaussian][
	The canonical parameterization of a multivariate Gaussian is given by a matrix $Omega$ and a vector $xi$. The matrix $Omega$ is called the *information matrix*, (or sometimes the *precision matrix*) and the vector $xi$ is called the *information vector*. The information matrix is the inverse of the covariance matrix $Omega=Sigma^(-1)$, and the information vector is the product of the information matrix and the mean $xi = Omega mu$.
]
It is easy to see that $Omega$ and $xi$ are a complete parameterization of a Gaussian. In particular, the mean and covariance of the Gaussian can easily be obtained from the canonical parameterization by the inverse:
$
Sigma = Omega^(-1) \
mu = Omega^-1 xi
$
The canonical parameterization is often derived by multiplying out the exponent of a Gaussian.
In @eq:MultivariateNormalDistribution we said that 
$ p(x) = det(2pi Sigma)^(-1/2) exp( -1/2 (x - mu)^T Sigma^(-1) (x - mu) ) $
We can separate the exponent into two terms, one that does not depend on $x$ and one that does:
$ p(x) = underbrace(det(2pi Sigma)^(-1/2) exp(-1/2 mu^T Sigma^(-1) mu),"constant term") exp( -1/2 x^T Sigma^(-1) x + x^T Sigma^(-1) mu ) $
We can include the constant term into the normalization factor, and rewrite the Gaussian in canonical form:
$
p(x)= eta exp(-1/2 x^T Sigma^(-1) x + x^T Sigma^(-1) mu) = eta exp(-1/2 x^T Omega x + x^T xi)
$
In many ways, the canonical parameterization is more elegant than the moments parameterization. 

In particular, the negative logarithm of the Gaussian is a quadratic function in $x$, with the canonical parameters $Omega$ and $xi$:
$
-log p(x) = 1/2 x^T Omega x - x^T xi + "constant"
$

Here “constant” is a constant. The reader may notice that we cannot use the symbol $eta$ to denote this constant, since negative logarithms of probabilities do not normalize to 1. The negative logarithm of our distribution $p(x)$ is
quadratic in $x$, with the quadratic term parameterized by $Omega$ and the linear term by $xi$. In fact, for Gaussians, $Omega$ must be positive semidefinite, hence $- log p(x)$ is a quadratic distance function with mean $mu = Omega^(-1) xi$.
#definition[Mahalanobis distance][
The matrix $Omega$ determines the rate at which the distance function increases in the different dimensions of the variable $x$. A quadratic distance that is weighted by a matrix $Omega$ is called a *Mahalanobis distance*.]
==== The algorithm
#figure(
pseudocode-list(line-gap: 1em)[
	+ *Algorithm Information_filter*($xi_(t-1), Omega_(t-1), u_t, z_t$):
		+ $overline(Omega)_t = (A_t Omega^(-1)_(t-1) A_t^T + R_t)^-1$
		+ $overline(xi)_t = overline(Omega)_t (A_t Omega^(-1)_(t-1) xi_(t-1) + B_t u_t)$
		+ $Omega_t = C_t^T Q_t^(-1) C_t + overline(Omega)_t$

		+ $xi_t =  C_t^T Q_t^(-1) z_t + overline(xi)_t$
		+ *return* $xi_t, Omega_t$
],caption:"The information filter algorithm for linear Gaussian state transitions and measurements") <alg:information_filter>
Its input is a Gaussian in its canonical parameterization $xi_(t-1)$ and $Omega_(t-1)$, representing the belief at time $t - 1$. Just like all Bayes filters, its input includes the control $u_t$ and the measurement $z_t$. The output are the parameters $xi_t$ and $Omega_t$ of the updated Gaussian.
The update involves matrices $A_t$, $B_t$, $C_t$, $R_t$, and $Q_t$. Those were defined in @eq:LinearStateTransition and @eq:LinearMeasurement, and are identical to the matrices used in the Kalman filter algorithm.
Here $R_t$ and $Q_t$ are the covariances of the zero-mean noise variables $epsilon_t$ and$delta_t$, respectively.

Just like the Kalman filter, the information filter is updated in two steps, a prediction step and a measurement update step.
- The prediction step is implemented in lines 2 and 3. The parameters $overline(xi)_t	$ and $overline(Omega)_t$ describe the Gaussian belief over $x_t$ after incorporating the control $u_t$, but before in corporating the measurement $z_t$.
- The latter is done through lines 4 and 5. Here the belief is updated based on the measurement $z_t$.

#note[These two update steps can be vastly different in complexity, especially if the state space possesses many dimensions.]
- The prediction step involves the inversion of two matrices of the size $n times n$, where $n$ is the dimension of the state space. In Kalman filters, the update step is additive and requires at most $O(n^2)$ time; it requires less time if only a subset of variables is affected by a control, or if variables transition independently of each other. 
- These roles are reversed for the measurement update step. Measurement updates are additive in the information filter. They require at most $O(n^2)$ time, and they are even more efficient if measurements carry only information about a subset of all state variables at a time. 
- The measurement update is the difficult step in Kalman filters. It requires matrix inversion whose worst case complexity is $O(n^2.4)$. 
This illustrates the dual character of Kalman and information filters.
==== The extended information filter
The extended information filter, or EIF, extends the information filter to the nonlinear case, very much in the same way the EKF is the non-linear extension of the Kalman filter.
#figure(
	pseudocode-list(line-gap: 1em)[
	+ *Algorithm Extended_information_filter*($xi_(t-1), Omega_(t-1), u_t, z_t$):
		+ $mu_(t-1) = Omega_(t-1)^(-1) xi_(t-1)$
		+ $overline(Omega)_t = (G_t Omega^(-1)_(t-1) G_t^T + R_t)^(-1)$
		+ $overline(xi)_t = overline(Omega)_t g(u_t,mu_(t-1))$
		+ $overline(mu)_t = g(u_t,mu_(t-1))$
		+ $Omega_t = overline(Omega)_t + H_t^T Q_t^(-1) H_t$
		+ $xi_t = overline(xi)_t + H_t^T Q_t^(-1) (z_t - h(overline(mu)_t) + H_t overline(mu)_t)$
		+ *return* $xi_t, Omega_t$
	]
)
The prediction is realized in lines 2 through 4, and the measurement update in lines 5 through 7.
These update equations are largely analog to the linear information filter, with the functions $g$ and $h$ (and their Jacobian $G_t$ and $H_t$) replacing the parameters of the linear model $A_t$, $B_t$, and $C_t$. As before, $g$ and $h$ specify the nonlinear state transition function and measurement function, respectively. 

#note[Unfortunately, both g and h require a state as an input. This mandates the recovery of a state estimate $mu$ from the canonical parameters.]
The recovery takes place in line 2, in which the state $mu_(t-1)$ is calculated from $Omega_(t-1)$ and $xi_(t-1)$ in the obvious way. 
Line 5 computes the state $overline(mu)_t$ using the equation familiar from the EKF.
==== Practical considerations
When applied to robotics problems, the information filter possesses several advantages over the Kalman filter.

- Representing global uncertainty is simple in the information filter: simply set $Omega = 0$. When using moments, such global uncertainty amounts to a covariance of infinite magnitude. This is especially problematic when sensor measurements carry information about a strict subset of all state variables, a situation often encountered in robotics. Special provisions have to be made to handle such situations in EKFs. 
- The information filter tends to be numerically more stable than the Kalman filter in many of the applications that will be discussed later.
- The information filter and several extensions enable a robot to integrate information without immediately resolving it into probabilities. This can be of great advantage in complex estimation problems, involving hundreds or even millions of variables. For such large problems, the integration á la Kalman filter induces severe computational problems, since any new piece of information requires propagation through a large system of variables. The information filter, with appropriate modification, can side-step this issue by simply adding the new information locally into the system. However, this is not a property yet of the simple information filter discussed here.
- Multi-robot problems often involve the integration of sensor data collected decentrally. Such integration is commonly performed through Bayes rule. When represented in logarithmic form, Bayes rule becomes an addition. As noted above, the canonical parameters of information filters represent a probability in logarithmic form. Thus, information integration is achieved by summing up information from multiple robots. Addition is commutative. Because of this, information filters can often integrate information in arbitrary order, with arbitrary delays, and in a completely decentralized manner. While the same is possible using the moments parameterization—after all, they represent the same information, the necessary overhead for doing so is much higher. Despite this advantage, the use of information filters in multi-robot systems remains largely under explored. 

The advantages of the information filter are offset by *important limitations*. A primary disadvantage of the extended information filter is the need to recover a state estimate in the update step, when applied to nonlinear systems. This step, if implemented as stated here, requires the inversion of the information matrix. Further matrix inversions are required for the prediction step of the information filter. In many robotics problems, the EKF does not involve the inversion of matrices of comparable size. For high dimensional state spaces, the information filter is generally believed to be computation ally inferior to the Kalman filter. In fact, this is one of the reasons why the EKF has been vastly more popular than the extended information filter.

These limitations do not necessarily apply to problems in which the information matrix possesses structure. In many robotics problems, the interaction of state variables is local; as a result, the *information matrix may be sparse*. #note[Such sparseness does not translate to sparseness of the covariance]
== Non parametric filtering
A popular alternative to Gaussian techniques are nonparametric filters.
Non-parametric filters do not rely on a fixed functional form of the posterior, such as Gaussians. Instead, they approximate posteriors by a finite number of values, each roughly corresponding to a region in state space.
Some non-parametric Bayes filters rely on a decomposition of the state space, in which each such value corresponds to the cumulative probability of the posterior density in a compact subregion of the state space.
Others approximate the state space by random samples drawn from the posterior distribution.

In all cases, the number of parameters used to approximate the posterior can be varied.
#note[The quality of the approximation depends on the number of parameters used to represent the posterior.As the number of parameters goes to infinity, nonparametric techniques tend to converge uniformly to the correct posterior, under specific smoothness assumptions.]

This chapter discusses two nonparametric approaches for approximating posteriors over continuous spaces with finitely many values. 
- The first decomposes the state space into finitely many regions, and represents the posterior by a *histogram*. A histogram assigns to each region a single cumulative probability; they are best thought of as piecewise constant approximations to a continuous density. 
- The second technique represents posteriors by finitely many samples. The resulting filter is known as *particle filter* and has become immensely popular in robotics.
Both types of techniques, histograms and particle filters, do not make strong parametric assumptions on the posterior density. In particular, they are well-suited to represent complex multimodal beliefs. For this reason, they are often the method of choice when a robot has to cope with phases of global uncertainty, and when it faces hard data association problems that yield separate, distinct hypotheses. 
#note[However, the representational power of these techniques comes at the price of added *computational complexity*.]
Fortunately, both nonparametric techniques described in this chapter make it possible to adapt the number of parameters to the (suspected) complexity of the posterior:
- When the posterior is of low complexity (e.g., focused on a single state with a small margin of uncertainty), they use only small numbers of parameters. 
- For complex posteriors, e.g., posteriors with many modes scattered across the state space, the number of parameters grows larger.
#definition[Resource adaptive techniques][
	Techniques that can adapt the number of parameters to represent the posterior online are called *adaptive*. They are called *resource-adaptive* if they can adapt based on the computational resources available for belief computation.]
Resource-adaptive techniques play an important role in robotics. They enable robots to make decisions in real time, regardless of the computational resources available. Particle filters are often implemented as a resource-adaptive algorithm, by adapting the number of particles online based on the available computational resources.
=== The Histogram filter (discrete Bayes filter)
Histogram filters decompose the state space into finitely many regions and represent the cumulative posterior for each region by a single probability value. When applied to finite spaces, such filters are known as discrete Bayes filters; when applied to continuous spaces, they are commonly called histogram filters. We will first describe the discrete Bayes filter and then discuss its use in continuous state spaces.

Discrete Bayes filters apply to problems with finite state spaces, where the random variable $X_t$ can take on finitely many values.
We already presented Bayes filters in @sec:bayes_filter.

Some of the robotic mapping problems discussed in later chapters also involve discrete random variables.
For example, occupancy grid mapping algorithms assume that each location in the environment is either occupied or free. The corresponding random variable is binary. It can take on two different values. Thus, finite state spaces play an important role in robotics.
==== The algorithm
For the algorithm, we just have to replace the continuous state space $X_t$ by a finite set of values. The belief $"bel"(x_t)$ is then represented by a vector of probabilities, one for each possible value of $x_t$. The update equations are identical to those of the Bayes filter, except that the integrals are replaced by sums over the finite state space.
The algorithm is therefore identical to the one in @alg:bayes_filter, except that the integrals are replaced by sums. The resulting algorithm is presented in @alg:discrete_bayes_filter.
#figure(
	pseudocode-list(line-gap: 1em)[
		+ *Algorithm Discrete_Bayes_filter*(${p_(k,t-1)}, u_t, z_t$):
			+ $ overline(p)_(k,t) = sum_i p(X_t = k | u_t, X_(t-1) = x_i) p_(i,t-1)$
			+ $p_(k,t) = eta p(z_t | X_t = k) overline(p)_(k,t)$
			+ *return* ${p_(k,t)}$
	],caption:"The discrete Bayes filter algorithm") <alg:discrete_bayes_filter>
The variables $x_i$ and $x_k$ denote individual states, of which
there may only be finitely many. The belief at time $t$ is an assignment of a probability to each state $x_k$, denoted $p_(k,t)$.

Thus, the input to the algorithm is a discrete probability distribution ${p_(k,t-1)}$, along with the most recent control
$u_t$ and measurement $z_t$. 
- Line 3 calculates the prediction, the belief for the new state based on the control alone. 
- This prediction is then updated in line 4, so as to incorporate the measurement.
The discrete Bayes filter algorithm is popular in many areas of signal processing, where it is often referred to as the *forward pass of a hidden Markov model*, or HMM.

Of particular interest will be the use of discrete Bayes filters as an *approximate inference tool for continuous state spaces*. As noted above, such filters are called histogram filters.
@fig:histogram-transform shows how a histogram filter represents a random variable and its nonlinear transform. Shown there is the projection of a histogrammed Gaussian through a nonlinear function. The original Gaussian distribution possesses 10 bins. So does the projected probability distribution, but in two of the resulting bins the probability is so close to zero that they cannot be seen in this figure.
#fig-histogram-transform()<fig:histogram-transform>
Histogram filters decompose a continuous state space into finitely many bins, or regions:
$ "dom"(X_t) = x_(1,t) union x_(2,t) union ... union x_(k,t) $
Here $X_t$ is the familiar random variable describing the state of the robot at time $t$. The function $"dom"( X_t )$ denotes the state space, which is the universe of possible values that $X_t$ might assume.

Each $x_(k,t)$ describes a convex region.
These regions together form a partitioning of the state space, that is:
$ forall i,j: i eq.not j => x_(i,t) inter x_(j,t) = emptyset  " and " union_k x_(k,t) = "dom"(X_t) $
A straightforward decomposition of a continuous state space is a multidimensional grid, where each $x_(k,t)$ is a grid cell. Through the granularity of the decomposition, we can trade off accuracy and computational efficiency.
#note[Fine-grained decompositions infer smaller approximation errors than coarse ones, but at the expense of increased computational complexity.]
As we already discussed, the discrete Bayes filter assigns to each region $x_(k,t)$ a probability, $p(x_(k,t))$ . Within each region, the discrete Bayes filter carries no further information on the belief distribution. Thus, the posterior becomes a piecewise constant PDF, which assigns a uniform probability to each state $x_t$ within each region $x_(k,t)$ :
$ p(x_t) = p_(k,t)/(|x_(k,t)|) $
where $|x_(k,t)|$ denotes the volume (or area, in 2D) of the region $x_(k,t)$.

If the state space is *truly discrete*, the conditional probabilities $p(x_(k,t) | x_(i,t-1), u_t)$ and $p(z_t | x_(k,t)$ are well-defined, and the algorithm can be implemented as stated.

In continuous state spaces, one is usually given the
densities $p(x_t | u_t , x_(t-1) )$ and $p(z_t | x_t )$, which are defined for individual states (and not for regions in state space). 
#note[For cases where each region $x_(k,t)$
is small and of the same size, these densities are usually approximated by substituting  $x_(k,t)$ with a representative of this region.]
For example, we might use the mean state in $x_(k,t)$.
$ hat(x)_(k,t) = |x_(k,t)|^(-1) integral_(x_(k,t)) x_t space d x $
Then we simply replace
$
p(z_t | x_(k,t)) &approx p(z_t | hat(x)_(k,t)) \
p(x_(k,t) | x_(i,t-1), u_t) &approx eta |x_(k,t)|p(hat(x)_(k,t) | hat(x)_(i,t-1), u_t)
$
These approximations are the result of the piecewise uniform interpretation of the discrete Bayes filter that will be discussed later //TODO: mettere ref 
and a Taylor-approximation analogous to the one used by EKFs.
=== Binary Bayes Filters with Static State
Certain problems in robotics are best formulated as estimation problems with *binary state* that does not change over time. Those problems are addressed by the *binary Bayes filter*.

Problems of this type arise if a robot estimates a fixed binary quantity in the environment from a sequence of sensor measurements. For example, a robot might want to know if a door is open or closed, in a context where the door state does not change during sensing.
Another example of binary Bayes filters with static state are *occupancy grid maps*.

When the state is static, the belief is a function only of the measurements:
$ "bel"_t(x)= p(x|z_(1:t),u_(1:t))=p(x|z_(1:t)) $
where the state is chosen from two possible values, denoted by $x$ and $not x$.
In particular, we have $"bel"_t (not x) = 1 − "bel"_t (x)$. The lack of a time index for the
state $x$ reflects the fact that the state does not change
#note[Naturally, binary estimation problems of this type can be tackled using the discrete Bayes filter shown in @alg:discrete_bayes_filter. However, the belief is commonly implemented as a log odds ratio.]
#definition[Odds][
The *odds of a state* $x$ is defined as the ratio of the
probability of this event divided by the probability of its negate
$ p(x)/p(not x) = p(x)/1-p(x) $
The *log odds* is the logarithm of the odds:
$ l(x) := log p(x)/(1-p(x)) $
]
#remark[Log odds assume values from $-infinity$ to $infinity$.]
#remark[The Bayes filter for updating beliefs in log odds representation is computationally elegant. It avoids truncation problems that arise for probabilities close to 0 or 1.]
#figure(
	pseudocode-list(line-gap: 1em)[
		+ *Algorithm Binary_Bayes_filter*($l_(t-1), z_t$):
			+ $l_t = l_(t-1) + log p(z_t | x)/(1-p(x|z_t)) - log p(x)/(1-p(x))$
			+ *return* $l_t$
	],caption:"The binary Bayes filter algorithm"
)<alg:binary_bayes_filter>
In @alg:binary_bayes_filter we show the basic update rule.
This algorithm is additive; in fact, any algorithm that increments and decrements a variable in response to measurements can be interpreted as a Bayes filter in log odds form.


We can easily recover the belief $"bel"_t(x)$ using log odds ratio $l_t$:
$
"bel"_t (x) = 1- 1/(1 + exp(l_t))
$
==== Inverse measurement model
This binary Bayes filter uses an *inverse measurement model* $p(x | z_t )$, instead of the familiar forward model $p(z_t | x)$. The inverse measurement model specifies a distribution over the (binary) state variable as a function of the measurement $z_t$.
#note[Inverse models are often used in situations where measurements are more complex than the binary state.] 
#example[An example of such a situation is the problem of estimating whether or not a door is closed from camera images.
Here the state is extremely simple, but the space of all measurements is huge.
It is easier to devise a function that calculates a probability of a door being closed from a camera image, than describing the distribution over all camera images that show a closed door. In other words, it is easier to implement an inverse than a forward sensor model.]
=== The particle filter
The *particle filter* is an alternative nonparametric implementation of the Bayes filter. Just like histogram filters, particle filters approximate the posterior by a finite number of parameters. However, they differ in the way these parameters are generated, and in which they populate the state space.
#note[The key idea
of the particle filter is to represent the posterior $"bel"(x_t )$ by a set of random state samples drawn from this posterior.]
#fig-particle-representation()<fig:particle-representation>
@fig:particle-representation illustrates this idea for a Gaussian. Instead of representing the distribution by a parametric form, which would have been the exponential function that defines the density of a normal distribution, particle filters represent a distribution by a set of samples drawn from this distribution.
Such a representation is approximate, but it is nonparametric, and therefore can represent a much broader space of distributions than, for example, Gaussians. Another advantage of the sample based representation is its ability to model nonlinear transformations of random variables, as shown in @fig:particle-representation. 
#definition[particle][
In particle filters, the samples of a posterior distribution are called *particles* and are denoted
$ cal(X)_t := x_t^([1]), x_t^([2]), dots, x_t^([M]) $
Each particle $x_t^([m])$ (with $1 <= m <= M $) is a concrete instantiation of the state at time $t$.

Put differently, a particle is a *hypothesis* as to what the true world state may be at time $t$.
]
Here $M$ denotes the number of particles in the particle
set $cal(X)_t$ . In practice, the number of particles $M$ is often a large number, e.g., $M = 1,000$. In some implementations $M$ is a function of $t$ or other quantities related to the belief $"bel"(x_t )$.
#note[The intuition behind particle filters is to approximate the belief $"bel"(x_t )$ by the set of particles $cal(X)_t$.
]
Ideally, the likelihood for a state hypothesis $x_t$ to be included in the particle set $cal(X)_t$ shall be proportional to its Bayes filter posterior $"bel"(x_t )$:
$
x_t^([m]) tilde "bel"(x_t )
$<eq:particle-filter-approximation>
#remark[As a consequence of @eq:particle-filter-approximation, the denser a subregion of the state space is populated by samples, the more likely it is that the true state falls into this region.]
#remark[ @eq:particle-filter-approximation holds only asymptotically for $M arrow.t infinity $ for the standard particle filter algorithm. For finite $M$, particles are drawn from a slightly different distribution.] 
In practice, this difference is negligible as long as the number of particles is not too small (e.g., $M >= 100$).

Just like all other Bayes filter algorithms discussed thus far, the particle filter algorithm constructs the belief $"bel"(x_t )$ recursively from the belief $"bel"(x_(t-1))$ one time step earlier.
Since beliefs are represented by sets of particles, this means that particle filters construct the particle set $cal(X)_t$ recursively from the set $cal(X)_(t-1)$.
#figure(
	pseudocode-list(line-gap: 1em)[
	+ *Algorithm Particle_filter*($cal(X)_(t-1), u_t, z_t$)
		+ $overline(cal(X)_(t))= cal(X)_(t-1) = emptyset$
		+ *for* $m = 1$ to $M$:
			+ sample $x_t^([m]) tilde p(x_t|u_t, x_(t-1)^([m]))$
			+ $w_t^([m]) = p(z_t|x_t^([m]))$
			+ $overline(cal(X)_(t)) = overline(cal(X)_(t)) + <x_t^([m]), w_t^([m])>$
		+ *for* $m = 1$ to $M$:
			+ draw $i$ with probability $prop w_t^([i])$
			+ add $x_t^([i])$ to $cal(X)_(t)$
		+ return $cal(X)_(t)$  
  	],caption:"The particle filter algorithm"
)<alg:particle_filter>
In @alg:particle_filter we show the most basic variant of the particle filter algorithm.

The input of this algorithm is the particle set $cal(X)_(t-1)$ , along with the most recent control $u_t$ and the most recent measurement $z_t$ . The algorithm then first constructs a temporary particle set $overline(cal(X)_(t))$ that represented the belief $"bel"(x_t )$. It
does this by systematically processing each particle $x_(t-1)^([m])$ in the input particle
set $cal(X)_(t-1)$. Subsequently, it transforms these particles into the set $cal(X)_(t)$, which
approximates the posterior distribution $"bel"(x_t )$.

In detail:
1. Line 4 generates a hypothetical state $x_t^([m])$ for time $t$ based on the particle $x_(t-1)^([m])$ and the control $u_t$. The resulting sample is indexed by $m$, indicating that it is generated from the $m$-th particle in $cal(X)_(t-1)$.
   
   This step involves sampling from the state transition distribution $p(x_t | u_t, x_(t-1))$. 

   To implement this step, one needs to be able to sample from this distribution. The set of particles obtained after $M$ iterations is the filter’s representation of $"bel"(x_t )$.
2. Line 5 calculates for each particle $x_t^([m])$ the so-called *importance factor*, denoted $w_t^([m])$. Importance factors are used to incorporate the measurement $z_t$ into the particle set. 
   
   The importance, thus, is the probability of the measurement $z_t$ under the particle $x_t^([m])$, given by $w_t^([m]) = p(z_t | x_t^([m]))$. If we interpret $w_t^([m])$ as the weight of a particle, the set of weighted particles represents (in approximation) the Bayes filter posterior $"bel"(x_t )$.
3. The real “trick” of the particle filter algorithm occurs in lines 8 through 11, where we perform the *resampling* or *importance sampling*. The algorithm draws with replacement $M$ particles from the temporary set $overline(cal(X)_(t))$. The probability of drawing each particle is given by its importance weight. Resampling transforms a particle set of $M$ particles into another particle set of the same size.
	
	By incorporating the importance weights into the resampling process, the distribution of the particles change, whereas before the resampling step, they were distributed according to $overline("bel")(x_t)$, after the resampling they are distributed (approximately) according to the posterior $"bel"(x_t)=eta p(z_t|x_t^([m]))overline("bel")(x_t)$. In fact, the resulting sample set usually possesses many duplicates, since particles are drawn with replacement. More important are the particles not contained in $cal(X)_t$, those tend to be the particles with lower importance weights.
#remark[The resampling step has the important function to force particles back to the posterior $"bel"(x_t)$.]
#remark[The resampling step is a probabilistic implementation of the Darwinian idea of survival of the fittest: It refocuses the particle set to regions in state space with high posterior probability. By doing so, it focuses the computational resources of the filter algorithm to regions in the state space where they matter the most]