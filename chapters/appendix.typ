#import "@preview/scholia:0.1.0": *

= Rotation and translation in 3D space
Here we present some related mathematical concepts that are required for the course.
== Roto-translation
<sec:rotoTranslation>
#figure(
	image("../figures/appendix/Rigid_body_attached_frame.svg"),caption: [Rigid body attached frame. The position and orientation of a rigid body can be described by attaching a frame to it.]
)<fig:rigidBody>
Consider a rigid body as of figure @fig:rigidBody, rigid means that the points of the body do not change their relative position. The position and orientation of a rigid body can be described by attaching a frame to it. The coordinates of the points of the object are expressed in the attached frame $(x_b,y_b,z_b)$ and we would want to express them in the reference frame $(x_a,y_a,z_a)$.

In many scientific fields, the *degrees of freedom* of a system is the number of parameters of the system that may vary independently. For example, a point in the 3D space has three degrees of freedom for translation: its coordinates;
In 3D space, $n$ points have $3n$ degrees of freedom for translation. If the object is rigid, that is not the case, because the points of the object cannot move independently. In fact, a rigid body has 6 degrees of freedom: 3 for translation and 3 for rotation.

The position and orientation of a rigid body can be described by a roto-translation matrix $T$ that transforms the coordinates of the points of the object expressed in the attached frame $(x_b,y_b,z_b)$ to the reference frame $(x_a,y_a,z_a)$:
The union of the position and the orientation of a rigid body is called the *pose* of the rigid body.
== Euler angles
Euler angles describe the orientation of a rigid body in space through three successive intrinsic rotations:
- *Precession ($phi$):* Rotation around the initial $z$-axis by an angle $phi$. The system $(x,y,z)$ becomes $(x',y',z')$, with $z'=z$.
- *Nutation ($theta$):* Rotation around the intermediate $x'$-axis by an angle $theta$. The system becomes $(x'',y'',z'')$, with $x''=x'$.
- *Proper rotation ($psi$):* Rotation around the intermediate $z''$-axis by an angle $psi$. The final system is $(x''',y''',z''')$, with $z'''=z''$.
#figure(
	image("../figures/appendix/euler.png"),caption: [Euler angles. The orientation of a rigid body in space can be described through three successive intrinsic rotations: precession, nutation and proper rotation.]
)
== Roll, pitch and yaw angles
Roll, pitch and yaw angles describe the orientation of a rigid body in space through three successive extrinsic rotations: Roll, pitch and yaw.
#figure(
	image("../figures/appendix/roll_pitch_yaw.png",width: 60%),caption: [Roll, pitch and yaw angles.]
)
== Roto-translation matrix
Let's combine the translation and rotation of a rigid body in a single transformation matrix $T$ called roto-translation matrix, which represents the relative pose between the relative frame of the object and the reference frame.

Take for example a frame $O"-"z y x$, we rotate it around the $z$-axis by an angle $alpha$, we can say that $alpha$ is the value of one of the degrees of the change of orientation between the two frames.
$ x'= vec( cos alpha, sin alpha , 0 ) quad y'= vec( -sin alpha, cos alpha , 0 ) quad z'= vec( 0, 0, 1 ) $
Then, the rotation matrices are defined as:
$ R_z (alpha) = mat( cos alpha, -sin alpha, 0; sin alpha, cos alpha, 0; 0, 0, 1 )\ R_y (beta) = mat( cos beta, 0, sin beta; 0, 1, 0; -sin beta, 0, cos beta ) \ R_x (gamma) = mat( 1, 0, 0; 0, cos gamma, -sin gamma; 0, sin gamma, cos gamma ) $
We postmultiply the coordinates of a point expressed in the frame $O"-"z y x$ by the rotation matrix to obtain the coordinates of the point expressed in the rotated frame $O"-"z' y' x'$.
If we compose the rotations, we can compute one after the other, for example, we can first rotate around the $z$-axis and then around the $y$-axis:
$ vec( x'',y'',z'' ) = R_y (beta) R_z (alpha) vec( x,y,z ) $

We can represent translation and rotation in a single transformation matrix $T$ called roto-translation matrix, which represents the relative pose between the relative frame of the object and the reference frame.
To do this, we can use homogeneous coordinates, which allow us to represent both rotation and translation in a single matrix.
So given a point $p=vec(x,y,z)$ we have $tilde(p) = vec(w_1,w_2,w_3,w_4)$ with $ w_1 = x/w_4, w_2 = y/w_4, w_3 = z/w_4 $ and we can express the roto-translation as:
$ tilde(p)^0 = A_1^0 tilde(p)^1 $
with $ A_1^0 = mat( R_1^0, o_1^0; 0^T, 1 ) $
where $R_1^0$ is the rotation matrix from frame 1 to frame 0, and $o_1^0$ is the translation vector of the origin of frame 1 with respect to frame 0.
The rotation gives three degrees of freedom, while the translation gives three more degrees of freedom, for a total of six degrees of freedom for a rigid body.
#pagebreak()
= Review of probability theory
<appendix:appendixProbability>
In probabilistic robotics, quantities such as
sensor measurements, controls, and the states of a robot and its environment are all modeled as *random variables*. 
#definition[Random variable][Random variables can take on multiple values, and they do so according to specific probabilistic laws.]
Probabilistic inference is the process of calculating these laws for random variables that are derived from other random variables and the observed data.

Let $X$ denote a random variable and $x$ denote a specific value that $X$ might assume. A standard example of a random variable is a coin flip, where $X$ can take on the values heads or tails. If the space of all values that $X$ can take on is discrete, as is the case if $X$ is the outcome of a coin flip, we write $p(X = x)$ 
to denote the probability that the random variable X has value x. For example, a fair coin is characterized by $p(X = "head") = p(X = "tail") = 1$.

- Discrete probabilities sum to one, that is, $sum_x p(X = x) = 1$.
- Probabilities are always non-negative, that is, $p(X = x) >= 0 , forall x $.
#note[To simplify the notation, we will usually omit explicit mention of the random variable whenever possible, and instead use the common abbreviation $p(x)$ instead of writing $p(X = x)$.]
Most techniques discussed here address estimation and decision making in continuous spaces. Continuous spaces are characterized by random variables that can take on a continuum of values. 

Unless explicitly stated, we assume that all continuous random variables possess probability density functions (PDFs). 
== Normal distributions
A common density function is that of the one-dimensional
*normal distribution* with mean $mu$ and variance $sigma^2$. The PDF of a normal distribution is given by the following *Gaussian* function:
$ p(x)= (2 pi sigma^2)^(1/2) exp( -1/2 (x - mu)^2 / sigma^2 ) $
Normal distributions are central in topics that will be covered, we often abbreviate them as $cal(N)(x; mu, sigma^2) $, which denotes the value of the Gaussian PDF with mean $mu$ and variance $sigma^2$ at $x$. The element $x$ can be a scalar or a vector, and the mean $mu$ and variance $sigma^2$ can be scalars, vectors, or matrices, depending on the dimensionality of $x$.
Normal distributions over vectors are called multivariate. Multivariate normal distributions are characterized by density functions of the following form:
$ p(x) = det(2pi Sigma)^(-1/2) exp( -1/2 (x - mu)^T Sigma^(-1) (x - mu) ) $
Here $mu$ is the mean vector. $Sigma$ is a positive semidefinite and symmetric matrix called the covariance matrix.
The argument in the exponent in this PDF is quadratic in $x$, and the parameters of this quadratic function are $mu$ and $Sigma$.

Continuous probabilities integrate to one, that is, $integral p(X = x) d x = 1$, but unlike discrete probabilities, they can sum up to more than one.

Throughout this notes, we will use the terms probability, probability density, and probability density function interchangeably. We will silently assume that all continuous random variables are measurable, and we also assume that all continuous distributions actually possess densities.
== Relation between random variables
#definition[Joint distribution][The joint distribution of two random variables X and Y is given by $ p(x, y) = p(X=x "and" Y=y) $
This expression describes the probability of the event that the random variable X takes on the value x and that Y takes on the value y.]
#definition[Independence of variables][
If X and Y are independent, we have
$ p(x, y) = p(x) p(y) $
]
#definition[Conditional distribution][The conditional distribution of a random variable X given another random variable Y is given by $ p(x | y) = p(X=x | Y=y) $
If the random variables X and Y are independent, then $ p(x | y) = p(x) $
otherwise if $p(x)>0$, then $ p(x | y) = p(x, y) / p(y) $
]
An interesting fact, which follows from the definition of conditional probability and the axioms of probability measures, is often referred to as Theorem of total probability:
#theorem[Theorem of total probability][
Let $X$ and $Y$ be two random variables. Then, for any value $x$ of $X$, we have
$ p(x) &= sum_x p(x | y) p(y) &&"(discrete case)" \
p(x) &= integral p(x | y) p(y) d y &&"(continuous case)"
$
If $p(x | y)$ or $p(y)$ are zero, we define the product $ p(x | y) p(y)$ to be zero, regardless of the value of the remaining factor.
]
== Bayes rule
Equally important is Bayes rule, which relates a conditional of the type $p(x |y)$ to its “inverse,” $p(y | x)$. 
#definition[Bayes rule][
The rule, as stated here, requires $p(y) > 0$:
$
p(x | y) & = (p(y | x) p(x) )/ p(y) = (p(y | x) p(x)) / (sum_x p(y | x') p(x')) &&"(discrete case)" \
p(x | y) & = (p(y | x) p(x)) / p(y) = (p(y | x) p(x)) / (integral p(y | x') p(x') d x) &&"(continuous case)"
$
]	
Bayes rule plays a predominant role in probabilistic robotics (and probabilistic inference in general).
#definition[Prior and posterior distributions][
If x is a quantity that we would like to infer from y,
- the probability p(x) will be referred to as *prior probability *distribution, and *y is called the data* (e.g., a sensor measurement).
  
  The distribution p(x) summarizes the knowledge we have regarding X prior to incorporating the data y.
- The probability $p(x | y)$ is called the *posterior probability * distribution over $X$.
]
Bayes rule provides a convenient way to compute a posterior $p(x | y)$ using the “inverse” conditional probability $p(y | x)$ along with the prior probability $p(x)$. In other words, if we are interested in inferring a quantity $x$ from sensor data $y$, Bayes rule allows us to do so through the inverse probability, which specifies the probability of data y assuming that $x$ was the case. 
#definition[Generative model][In robotics, the probability $p(y | x)$ is often coined *generative model*, since it describes at some level of abstraction how state variables $X$ cause sensor measurements $Y$.]
== Statistics of random variables
A number of probabilistic algorithms require us to compute features, or statistics, of probability distributions.
#definition[Expectation][The expectation of a function $f(X)$ of a random variable $X$ is defined as
$ E[X]&= sum_x x p(x) &&"(discrete case)" \
E[X] &= integral x p(x) d x &&"(continuous case)" $
The covariance of $X$ is obtained as the expectation of the outer product of the deviation of $X$ from its mean:
$ "Cov"[X] = E[X - E[X]]^2 = E[X^2] - E[X]^2 $
]
Not all random variables possess finite expectations; however, those that do not are of no relevance to the material presented in this work.
#remark[Expectation is linear]
The covariance measures the squared expected deviation from the mean. As stated above, the mean of a multivariate normal distribution $N (x; mu, Sigma)$ is $mu$, and its covariance is $Sigma$.
== Entropy
#definition[Entropy][The entropy of a probability distribution is given by the following expression:
$ 
H_p(X) & = E[- log_2 p(X)] &&"which resolves to:" \
H_p(X) & = - sum_x p(x) log_2 p(x) &&"(discrete case)" \
H_p(X) & = - integral p(x) log_2 p(x) d x &&"(continuous case)" $
]
The concept of entropy originates in information theory. The entropy is the expected information that the value of $x$ carries. In the discrete case, $log_2 p(x)$ is the number of bits required to encode x using an optimal encoding, assuming that $p(x)$ is the probability of observing $x$. Here, entropy will be used in robotic information gathering, so as to express the information a robot may receive upon executing specific actions.
